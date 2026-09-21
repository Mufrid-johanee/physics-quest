#!/usr/bin/env python3
"""Read-only audit of character-like nodes on Zone 01-04 floors."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / "scenes"
CHAR_RE = re.compile(
    r"(Worker|Lab|Assistant|Manager|Director|Supervisor|Nabila|Farah|Karim|"
    r"Farid|Shirin|Tania|Anwar|Mira|Echo|Nadia|Rina|Teacher|PlayerBack|Player|"
    r"Volt|Milon|Guard)",
    re.I,
)

# Assessment NPC node names by scene (from floor scripts)
SUPERVISORS = {
    "Zone01_Floor1.tscn": "Manager",
    "Zone01_Floor2.tscn": "Manager",
    "Zone01_Floor3.tscn": "Manager",
    "Zone01_Floor4.tscn": "Director",
    "Zone02_Floor1.tscn": "Nabila",
    "Zone02_Floor2.tscn": "Farah",
    "Zone02_Floor3.tscn": "Karim",
    "Zone02_Floor4.tscn": "Director",
    "Zone03_Floor1.tscn": "Farid",
    "Zone03_Floor2.tscn": "Shirin",
    "Zone03_Floor3.tscn": "Tania",
    "Zone03_Floor4.tscn": "Anwar",
    "Zone04_Floor1.tscn": "Mira",
    "Zone04_Floor2.tscn": "Echo",
    "Zone04_Floor3.tscn": "Nadia",
    "Zone04_Floor4.tscn": "Farid",
}

DECORATIVE_HINTS = (
    "PlayerBackview",
    "PlayerBack",
    "TeacherIdle",  # child overlay under assessor
)

NODE_RE = re.compile(r'^\[node name="([^"]+)"([^\]]*)\]', re.M)


def classify(scene: str, name: str, parent: str, typ: str, is_instance: bool) -> str:
    if name in ("Player", "MainPlayer") or name.startswith("Player"):
        if "Back" in name:
            return "IGNORE (player decorative)"
        return "IGNORE (Player)"
    if SUPERVISORS.get(scene) == name:
        return "SUPERVISOR"
    # Child sprites under supervisor InteractionArea or under supervisor itself
    if parent.endswith(f"/{SUPERVISORS.get(scene, '___')}") or parent.endswith(
        f"/{SUPERVISORS.get(scene, '___')}/InteractionArea"
    ):
        if name != SUPERVISORS.get(scene):
            return "IGNORE (decorative child of supervisor)"
    if name in DECORATIVE_HINTS or "Backview" in name:
        return "IGNORE (decorative)"
    if "TeacherIdle" in name:
        return "IGNORE (decorative)"
    # Character-like?
    if not CHAR_RE.search(name) and not is_instance:
        return "SKIP"
    # Sprite2D / NPC instance that looks like a person
    if typ in ("Sprite2D", "CharacterBody2D", "") or is_instance:
        return "AMBIENT"
    return "REVIEW"


def main() -> None:
    floors = sorted((ROOT).glob("zone0*/Zone0*_Floor*.tscn"))
    for f in floors:
        text = f.read_text(encoding="utf-8")
        print(f"==== {f.parent.name}/{f.name} ====")
        for m in NODE_RE.finditer(text):
            name = m.group(1)
            attrs = m.group(2)
            parent_m = re.search(r'parent="([^"]+)"', attrs)
            parent = parent_m.group(1) if parent_m else "."
            type_m = re.search(r'type="([^"]+)"', attrs)
            typ = type_m.group(1) if type_m else ""
            is_instance = "instance=" in attrs
            if not (CHAR_RE.search(name) or is_instance):
                continue
            # skip collision / interaction utility names
            if name in ("CollisionShape2D", "CollisionShape2D2", "Interactable", "InteractionArea", "Label"):
                continue
            chunk = text[m.end() : m.end() + 500]
            dn_m = re.search(r'display_name = "([^"]+)"', chunk)
            en_m = re.search(r"enable_collision = (true|false)", chunk)
            role = classify(f.name, name, parent, typ, is_instance)
            if role == "SKIP":
                continue
            dn = dn_m.group(1) if dn_m else "-"
            coll = en_m.group(1) if en_m else "-"
            print(
                f"  [{role:40}] {name:24} parent={parent:45} "
                f"type={typ or 'inst':16} dn={dn:20} coll={coll}"
            )
        print()


if __name__ == "__main__":
    main()
