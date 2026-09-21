# Ambient Characters — Architecture & Upgrade Guide

**Status:** IMPLEMENTED (Zone 01–04 floors)  
**Last updated:** 2026-09-20  
**Related:** `Docs/PROGRESS.md`, `Docs/SCENE_IMPLEMENTATION.md`, `Docs/MASTER_GAME_SPEC.md`

This document is the **authoritative guide** for future ambient / Supervisor work. Keep assessment and ambient systems separate.

---

## Two character types (do not merge)

| Type | Purpose | Trigger | Script / nodes |
|------|---------|---------|----------------|
| **Supervisor** | Floor assessment | Existing `InteractionArea` → dialogue → quiz | Floor `*.gd` + assessor NPC |
| **Ambient** | Environmental flavor | Auto proximity (no E/F) → one random line | `AmbientProximity.gd` |

**Never** wire ambient characters into quiz / question banks / door unlock / mini-game flags.  
**Never** replace Supervisor assessment with ambient dialogue pools.

---

## Core scripts

| File | Role |
|------|------|
| `scripts/npc/AmbientProximity.gd` | Area2D auto dialogue; re-arms on leave/re-enter |
| `scripts/npc/AmbientDialoguePools.gd` | Short factory-flavor line pools (not quiz content) |
| `scripts/ui/DialoguePanel.gd` | Shared UI — **reuse only**; do not add a second panel |
| `scripts/tools/verify_ambient_characters.gd` | Headless structural verify |

Verify:

```
D:\Download\Godot_v4.7.1-stable_win64_console.exe --path "d:\capstone 2" --headless --script res://scripts/tools/verify_ambient_characters.gd
```

---

## Identification rules (when adding characters)

1. **Player** / `PlayerBackview` → ignore  
2. Floor **assessment NPC** (Manager node, Director, Nabila, Farah, Karim, Farid, Shirin, Tania, Anwar, Mira, Echo, Nadia, …) → **Supervisor** (assessment only)  
3. Other **human/character** Sprite2D or `NPC.tscn` instances → **ambient candidates**  
4. Skip props: machines, furniture, signs, boxes, trees, walls, decorative child overlays on Supervisors/workers (`TeacherIdle`, Farah’s `LabAssistant1`, Manager/Director child sprites, Z01 F3 `Worker5`/`Worker7` under workers)

Do **not** depend on a group named `AmbientCharacters` / `Workers` / `Characters`. Inspect hierarchy + texture paths + scripts.

---

## Inventory (current)

### Supervisors

| Zone | F1 | F2 | F3 | F4 |
|------|----|----|----|-----|
| 01 | Manager → display **Supervisor** | Manager → **Supervisor** | Manager → **Supervisor** | Director |
| 02 | Nabila | Farah | Karim | Director |
| 03 | Farid | Shirin | Tania | Anwar |
| 04 | Mira | Echo | Nadia | Farid |

### Ambient

| Scene | Nodes |
|-------|--------|
| Zone01_Floor1 | `NPCs/Workers/Worker_01…03` |
| Zone01_Floor2 | `NPCs/LabAssistant` |
| Zone01_Floor3 | `NPCs/Workers/Worker_01`, `Worker_02` |
| Zone01_Floor4 | `LabAssistant2`, `Worker7` |
| Zone02_Floor1 | *(none)* |
| Zone02_Floor2 | *(none)* |
| Zone02_Floor3 | `Worker1`, `Worker7` |
| Zone02_Floor4 | `NPCs/Worker5` |
| Zone03_Floor1 | `RinaForntView`, `Interactions/ExteriorExit/Worker7` |
| Zone03_Floor2 | `Interactions/ExteriorExit/Supervisor1`, `…/Worker7` |
| Zone03_Floor3 | `Worker1`, `Worker2`, `Collision/BoundLeft/Worker5` |
| Zone03_Floor4 | `Background/Worker4`, `Background/Worker2`, `MiniGameArea/Worker5` |
| Zone04_Floor1 | `Supervisor1`, `Interactions/ExteriorExit/LabAssistant2`, `…/Worker5` |
| Zone04_Floor2 | `NPCs/Worker5`, ExteriorExit `Supervisor1` / `Worker7` / `RinaForntView` |
| Zone04_Floor3 | `Worker1`, `Worker2`, BoundLeft `Worker5` / `Worker6` |
| Zone04_Floor4 | Background `Worker4` / `Worker2` / `Worker7`, `Karim` |

---

## How to add a new ambient character

1. Confirm it is a character asset (not a prop).  
2. **Do not** move/scale/flip the existing sprite or NPC transform.  
3. NPC instance (`NPC.tscn`): set `enable_collision = true`, `can_interact = false`, add child `AmbientProximity` + `CollisionShape2D`.  
4. Sprite2D: add child `BodyCollision` (StaticBody2D, **collision_layer = 4**) + `CollisionShape2D`, plus `AmbientProximity` + shape.  
5. Set `speaker_name` on `AmbientProximity` (pools pick lines from the name). Optional: set `lines` export to override the pool.  
6. Extend `AmbientDialoguePools.gd` if you need new pools — keep lines short; **never** copy quiz bank text.  
7. Update this inventory table + `verify_ambient_characters.gd` expected paths.  
8. Run the ambient verifier.

Helper (optional): `scripts/tools/_inject_ambient.py` — use carefully; prefer editor for one-offs.

---

## Collision layers (authoritative)

| Layer | Use |
|-------|-----|
| 1 | Player body |
| 2 | World / walls / environment StaticBody |
| 4 | NPC / ambient character bodies |
| 8 | Interaction / detect areas (non-solid) |

Player `collision_mask` must include **2 | 4** (`Player.tscn` / `PlayerController._ready`).  
Ambient proximity Area2D: `collision_layer = 0`, `collision_mask = 1` (detect player).

---

## Manual transform authority

Runtime must **never** overwrite:

- Character / NPC / Sprite2D position, scale, flip  
- AmbientProximity / BodyCollision / CollisionShape transforms authored in the scene  
- PlayerSpawn, cameras, doors, Supervisor InteractionAreas  

Tune proximity and body shapes in the editor if a floor feels too tight/loose.

---

## School context

`SchoolOpening.gd`:

- `TEACHER_LINE` — existing welcome / 80% rule  
- `TEACHER_LINE_SUPERVISOR` — additive: Supervisors on factory floors  
- `STUDENT_LINE` — unchanged  

Do not rewrite the full Teacher script or School → World Map transition when extending dialogue.

---

## Future upgrade notes

| Upgrade | Guidance |
|---------|----------|
| Zone 05 floors | Reuse `AmbientProximity` + pools; classify Supervisors vs ambient with the same rules; extend verifier |
| Richer ambient dialogue | Expand `AmbientDialoguePools` or per-node `lines`; still one DialoguePanel |
| Named ambient casts | Set `speaker_name`; optional custom `lines`; do not turn them into assessors |
| Item | Doc |
|------|-----|
| Real mini-games | Ambient must not start MG or set MG flags; Supervisors stay assessment-only. Current real MGs: Z01 Emergency Brake, Z03 Fiber Escape — see `Docs/MINIGAME_IMPLEMENTATION.md` |
| Quiz / banks | Untouched by ambient system |
| Saving / quests | Out of scope — do not bolt onto AmbientProximity |
| Exterior guides (Guard, Rina, Milon, Volt) | Separate from floor ambient; keep their existing auto-dialogue |

---

## Explicit non-goals

- Second dialogue framework  
- E/F or click for ambient  
- Quiz / assessment on ambient characters  
- Runtime-generated collision  
- Random spawn / AI roaming (unless a later phase explicitly requests it)

---

**EXISTING FLOOR GAMEPLAY FLOWS WERE NOT CHANGED.**  
**SUPERVISOR ASSESSMENT FLOW WAS NOT CHANGED.**
