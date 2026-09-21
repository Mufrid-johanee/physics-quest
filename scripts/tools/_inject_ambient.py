#!/usr/bin/env python3
"""Inject AmbientProximity (+ body collision for Sprite2D) into Zone floor scenes.

Does NOT move/scale existing character nodes. Idempotent if AmbientProximity already present.
Canonical rules / inventory: Docs/AMBIENT_CHARACTERS.md
Prefer editor edits for one-offs; keep this script in sync with the doc inventory when bulk-wiring.
"""
from __future__ import annotations

import re
import uuid
from pathlib import Path

ROOT = Path(r"d:\capstone 2")
SCENES = ROOT / "scenes"

# Final ambient list: (relative scene path, parent node path for ambient host, speaker, kind)
# kind: "npc" = CharacterBody2D instance → enable_collision + AmbientProximity
# kind: "sprite" = Sprite2D → StaticBody2D + AmbientProximity
AMBIENT: list[tuple[str, str, str, str]] = [
    # Zone 01
    ("zone01/Zone01_Floor1.tscn", "NPCs/Workers/Worker_01", "Worker", "npc"),
    ("zone01/Zone01_Floor1.tscn", "NPCs/Workers/Worker_02", "Worker", "npc"),
    ("zone01/Zone01_Floor1.tscn", "NPCs/Workers/Worker_03", "Worker", "npc"),
    ("zone01/Zone01_Floor2.tscn", "NPCs/LabAssistant", "Lab Assistant", "npc"),
    ("zone01/Zone01_Floor3.tscn", "NPCs/Workers/Worker_01", "Worker", "npc"),
    ("zone01/Zone01_Floor3.tscn", "NPCs/Workers/Worker_02", "Worker", "npc"),
    # Worker5/Worker7 under Worker_01/02 are decorative overlays — skipped
    ("zone01/Zone01_Floor4.tscn", "LabAssistant2", "Lab Assistant", "sprite"),
    ("zone01/Zone01_Floor4.tscn", "Worker7", "Worker", "sprite"),
    # Zone 02 — Floor1 has no ambient; LabAssistant1 under Farah is decorative
    ("zone02/Zone02_Floor3.tscn", "Worker1", "Worker", "sprite"),
    ("zone02/Zone02_Floor3.tscn", "Worker7", "Worker", "sprite"),
    ("zone02/Zone02_Floor4.tscn", "NPCs/Worker5", "Worker", "sprite"),
    # Zone 03
    ("zone03/Zone03_Floor1.tscn", "RinaForntView", "Rina", "sprite"),
    ("zone03/Zone03_Floor1.tscn", "Interactions/ExteriorExit/Worker7", "Worker", "sprite"),
    ("zone03/Zone03_Floor2.tscn", "Interactions/ExteriorExit/Supervisor1", "Coworker", "sprite"),
    ("zone03/Zone03_Floor2.tscn", "Interactions/ExteriorExit/Worker7", "Worker", "sprite"),
    ("zone03/Zone03_Floor3.tscn", "Worker1", "Worker", "sprite"),
    ("zone03/Zone03_Floor3.tscn", "Worker2", "Worker", "sprite"),
    ("zone03/Zone03_Floor3.tscn", "Collision/BoundLeft/Worker5", "Worker", "sprite"),
    ("zone03/Zone03_Floor4.tscn", "Background/Worker4", "Worker", "sprite"),
    ("zone03/Zone03_Floor4.tscn", "Background/Worker2", "Worker", "sprite"),
    ("zone03/Zone03_Floor4.tscn", "MiniGameArea/Worker5", "Worker", "sprite"),
    # Zone 04
    ("zone04/Zone04_Floor1.tscn", "Interactions/ExteriorExit/LabAssistant2", "Lab Assistant", "sprite"),
    ("zone04/Zone04_Floor1.tscn", "Interactions/ExteriorExit/Worker5", "Worker", "sprite"),
    ("zone04/Zone04_Floor1.tscn", "Supervisor1", "Coworker", "sprite"),
    ("zone04/Zone04_Floor2.tscn", "NPCs/Worker5", "Worker", "sprite"),
    ("zone04/Zone04_Floor2.tscn", "Interactions/ExteriorExit/Supervisor1", "Coworker", "sprite"),
    ("zone04/Zone04_Floor2.tscn", "Interactions/ExteriorExit/Worker7", "Worker", "sprite"),
    ("zone04/Zone04_Floor2.tscn", "Interactions/ExteriorExit/RinaForntView", "Rina", "sprite"),
    ("zone04/Zone04_Floor3.tscn", "Worker1", "Worker", "sprite"),
    ("zone04/Zone04_Floor3.tscn", "Worker2", "Worker", "sprite"),
    ("zone04/Zone04_Floor3.tscn", "Collision/BoundLeft/Worker5", "Worker", "sprite"),
    ("zone04/Zone04_Floor3.tscn", "Collision/BoundLeft/Worker6", "Worker", "sprite"),
    ("zone04/Zone04_Floor4.tscn", "Background/Worker4", "Worker", "sprite"),
    ("zone04/Zone04_Floor4.tscn", "Background/Worker2", "Worker", "sprite"),
    ("zone04/Zone04_Floor4.tscn", "Background/Worker7", "Worker", "sprite"),
    ("zone04/Zone04_Floor4.tscn", "Karim", "Coworker", "sprite"),
]

# Supervisor display_name updates (Manager → Supervisor only)
SUPERVISOR_DISPLAY = [
    ("zone01/Zone01_Floor1.tscn", "NPCs/Manager", "Supervisor"),
    ("zone01/Zone01_Floor2.tscn", "NPCs/Manager", "Supervisor"),
    ("zone01/Zone01_Floor3.tscn", "NPCs/Manager", "Supervisor"),
]


def next_ext_id(text: str, prefix: str = "amb") -> str:
    used = set(re.findall(r'id="([^"]+)"', text))
    i = 1
    while f"{prefix}{i}" in used:
        i += 1
    return f"{prefix}{i}"


def ensure_ext_resource(text: str, path: str, res_type: str = "Script") -> tuple[str, str]:
    m = re.search(rf'\[ext_resource[^\]]*path="{re.escape(path)}"[^\]]*\]', text)
    if m:
        id_m = re.search(r'id="([^"]+)"', m.group(0))
        return text, id_m.group(1)
    eid = next_ext_id(text)
    line = f'[ext_resource type="{res_type}" path="{path}" id="{eid}"]\n'
    # insert after last ext_resource
    lasts = list(re.finditer(r"^\[ext_resource[^\]]*\]\n", text, re.M))
    if lasts:
        pos = lasts[-1].end()
        text = text[:pos] + line + text[pos:]
    else:
        text = line + text
    return text, eid


def ensure_subresource(text: str, sid: str, size: str) -> str:
    if f'id="{sid}"' in text and "RectangleShape2D" in text:
        # may already exist
        if re.search(rf'\[sub_resource type="RectangleShape2D" id="{re.escape(sid)}"\]', text):
            return text
    block = f'\n[sub_resource type="RectangleShape2D" id="{sid}"]\nsize = Vector2({size})\n'
    # insert before first [node
    first_node = text.find("\n[node ")
    if first_node < 0:
        text += block
    else:
        text = text[:first_node] + block + text[first_node:]
    return text


def find_node_block_end(text: str, parent_path: str, node_name: str) -> int | None:
    """Return index after the [node ...] header line for the target node."""
    if parent_path == ".":
        pattern = rf'^\[node name="{re.escape(node_name)}"[^\]]*\]\n'
    else:
        pattern = (
            rf'^\[node name="{re.escape(node_name)}"[^\]]*parent="{re.escape(parent_path)}"[^\]]*\]\n'
        )
    m = re.search(pattern, text, re.M)
    if not m:
        # try parent without exact match (instance lines)
        pattern2 = (
            rf'^\[node name="{re.escape(node_name)}"[^\]]*parent="{re.escape(parent_path)}"[^\]]*\].*\n'
        )
        m = re.search(pattern2, text, re.M)
    return m.end() if m else None


def split_host_path(host_path: str) -> tuple[str, str]:
    if "/" not in host_path:
        return ".", host_path
    parent, name = host_path.rsplit("/", 1)
    return parent, name


def already_has_ambient(text: str, host_path: str) -> bool:
    return (
        f'[node name="AmbientProximity" type="Area2D" parent="{host_path}"]' in text
    )


def inject_ambient_under_npc(text: str, host_path: str, speaker: str, amb_id: str) -> str:
    parent, name = split_host_path(host_path)
    # enable_collision = true on the NPC instance property block
    end = find_node_block_end(text, parent, name)
    if end is None:
        print(f"  MISSING NPC node {host_path}")
        return text

    # Flip enable_collision / can_interact in the property section until next [node
    next_node = text.find("\n[node ", end)
    props = text[end:next_node] if next_node >= 0 else text[end:]
    new_props = props
    if "enable_collision = false" in new_props:
        new_props = new_props.replace("enable_collision = false", "enable_collision = true", 1)
    elif "enable_collision = true" not in new_props:
        # insert after display-ish props
        new_props = "enable_collision = true\n" + new_props
    if "can_interact = true" in new_props:
        new_props = new_props.replace("can_interact = true", "can_interact = false", 1)

    if already_has_ambient(text, host_path):
        text = text[:end] + new_props + (text[next_node:] if next_node >= 0 else "")
        print(f"  skip ambient (exists), updated collision: {host_path}")
        return text

    sid_prox = f"Rect_amb_prox_{uuid.uuid4().hex[:8]}"
    text = ensure_subresource(text, sid_prox, "110, 130")
    # re-find after subresource insert
    end = find_node_block_end(text, parent, name)
    next_node = text.find("\n[node ", end)
    props = text[end:next_node] if next_node >= 0 else text[end:]
    new_props = props
    if "enable_collision = false" in new_props:
        new_props = new_props.replace("enable_collision = false", "enable_collision = true", 1)
    elif "enable_collision = true" not in new_props:
        new_props = "enable_collision = true\n" + new_props
    if "can_interact = true" in new_props:
        new_props = new_props.replace("can_interact = true", "can_interact = false", 1)

    insert = (
        f'{new_props}'
        f'\n[node name="AmbientProximity" type="Area2D" parent="{host_path}"]\n'
        f"collision_layer = 0\n"
        f"collision_mask = 1\n"
        f"monitoring = true\n"
        f'monitorable = false\n'
        f'script = ExtResource("{amb_id}")\n'
        f'speaker_name = "{speaker}"\n'
        f'\n[node name="CollisionShape2D" type="CollisionShape2D" parent="{host_path}/AmbientProximity"]\n'
        f"position = Vector2(0, -10)\n"
        f'shape = SubResource("{sid_prox}")\n'
    )
    if next_node >= 0:
        text = text[:end] + insert + text[next_node:]
    else:
        text = text[:end] + insert
    print(f"  + ambient NPC {host_path}")
    return text


def inject_ambient_under_sprite(text: str, host_path: str, speaker: str, amb_id: str) -> str:
    parent, name = split_host_path(host_path)
    if already_has_ambient(text, host_path):
        print(f"  skip ambient (exists): {host_path}")
        return text
    end = find_node_block_end(text, parent, name)
    if end is None:
        print(f"  MISSING sprite node {host_path}")
        return text

    sid_body = f"Rect_amb_body_{uuid.uuid4().hex[:8]}"
    sid_prox = f"Rect_amb_prox_{uuid.uuid4().hex[:8]}"
    text = ensure_subresource(text, sid_body, "36, 20")
    text = ensure_subresource(text, sid_prox, "120, 140")
    end = find_node_block_end(text, parent, name)
    next_node = text.find("\n[node ", end)
    props = text[end:next_node] if next_node >= 0 else text[end:]

    insert = (
        f"{props}"
        f'\n[node name="BodyCollision" type="StaticBody2D" parent="{host_path}"]\n'
        f"collision_layer = 4\n"
        f"collision_mask = 0\n"
        f'\n[node name="CollisionShape2D" type="CollisionShape2D" parent="{host_path}/BodyCollision"]\n'
        f"position = Vector2(0, 24)\n"
        f'shape = SubResource("{sid_body}")\n'
        f'\n[node name="AmbientProximity" type="Area2D" parent="{host_path}"]\n'
        f"collision_layer = 0\n"
        f"collision_mask = 1\n"
        f"monitoring = true\n"
        f"monitorable = false\n"
        f'script = ExtResource("{amb_id}")\n'
        f'speaker_name = "{speaker}"\n'
        f'\n[node name="CollisionShape2D" type="CollisionShape2D" parent="{host_path}/AmbientProximity"]\n'
        f"position = Vector2(0, 0)\n"
        f'shape = SubResource("{sid_prox}")\n'
    )
    if next_node >= 0:
        text = text[:end] + insert + text[next_node:]
    else:
        text = text[:end] + insert
    print(f"  + ambient sprite {host_path}")
    return text


def update_supervisor_display(text: str, host_path: str, new_name: str) -> str:
    parent, name = split_host_path(host_path)
    end = find_node_block_end(text, parent, name)
    if end is None:
        print(f"  MISSING supervisor {host_path}")
        return text
    next_node = text.find("\n[node ", end)
    props = text[end:next_node] if next_node >= 0 else text[end:]
    if 'display_name = "Manager"' in props:
        props = props.replace('display_name = "Manager"', f'display_name = "{new_name}"', 1)
        print(f"  display_name -> {new_name} on {host_path}")
    if next_node >= 0:
        return text[:end] + props + text[next_node:]
    return text[:end] + props


def main() -> None:
    by_scene: dict[str, list[tuple[str, str, str]]] = {}
    for scene, host, speaker, kind in AMBIENT:
        by_scene.setdefault(scene, []).append((host, speaker, kind))

    for scene, items in by_scene.items():
        path = SCENES / scene
        print(f"=== {scene} ===")
        text = path.read_text(encoding="utf-8")
        text, amb_id = ensure_ext_resource(text, "res://scripts/npc/AmbientProximity.gd")
        for host, speaker, kind in items:
            if kind == "npc":
                text = inject_ambient_under_npc(text, host, speaker, amb_id)
            else:
                text = inject_ambient_under_sprite(text, host, speaker, amb_id)
        path.write_text(text, encoding="utf-8")

    for scene, host, new_name in SUPERVISOR_DISPLAY:
        path = SCENES / scene
        print(f"=== supervisor rename {scene} ===")
        text = path.read_text(encoding="utf-8")
        text = update_supervisor_display(text, host, new_name)
        path.write_text(text, encoding="utf-8")

    print("DONE")


if __name__ == "__main__":
    main()
