# Zone 04 — The Substation (Implementation)

**Status:** Assessments + door progression + MG SUCCESSFUL **placeholder** + **floor ambient characters** **IMPLEMENTED**.  
**Real mini-game mechanics:** DEFERRED.  
**Canonical badge (when awarded later):** **Spark Emblem** (`asset/sprites/Environment/zone 4/ui_badge_spark_emblem.png`).  
**Important:** Placeholder SUCCESSFUL sets `zone04_minigame_successful` for map unlock but must **not** set `zone04_badge_earned` — Badge Screen stays locked for Spark Emblem until a real MG awards it.  
**Badge UI:** Shared Status Bar / Badge Screen on zone floors (not on future Z04 MG). See `Docs/SCENE_IMPLEMENTATION.md`.  
**Ambient upgrade guide:** `Docs/AMBIENT_CHARACTERS.md`

## Authoritative structure (4 floors only)

```
World Map → Zone04_Exterior (Guide=Volt)
  Guide dialogue → “Enter Door 1” (player walks to Door 1 manually)
  Door1 → Floor1 Professor Mira → Exterior (Door2 unlock)
  Door2 → Floor2 Echo → Exterior (Door3 unlock)
  Door3 → Floor3 Professor Nadia → Exterior (Door4 unlock)
  Door4 → Floor4 Engineer Farid → MiniGameArea PLAY placeholder
```

Do **not** create Floor 5 / Door 5 / capstone floor for this phase.

## Exterior guide

| Node | Name | Asset |
|------|------|-------|
| `NPCs/Guide` | Volt | `res://asset/sprites/character/zone 4/volt.png` |

- Auto proximity InteractionArea → DialoguePanel intro only
- Does **not** start a quiz, open Door 1, or teleport the player
- Re-arms on `body_exited`

## Mini-game placeholder (progression connected)

After Floor 4 quiz: **PLAY MINI-GAME 1** → **SUCCESSFUL** → `mark_minigame_successful(ZONE_04)` → unlocks Zone 05 on World Map → **RETURN TO THE WORLD MAP**.

Sets `zone04_minigame_successful` + `zone04_complete`. Real mini-game mechanics deferred. Canonical badge name when ceremony exists: **Spark Emblem**.

## Characters

| Floor | Name | Asset |
|-------|------|-------|
| 1 | Professor Mira | `res://asset/sprites/character/zone 4/Professor_Mira.png` |
| 2 | Echo | `res://asset/sprites/character/zone 4/Echo.png` |
| 3 | Professor Nadia | `res://asset/sprites/character/zone 4/Professor_Nadia.png` |
| 4 | Engineer Farid | `res://asset/sprites/character/zone 4/Engineer_Farid.png` |

No exterior floor assessor reuse — Volt is exterior-only. Floor cast remains Mira / Echo / Nadia / Farid.

## Ambient characters (floors)

Floor Supervisors = assessment NPCs above. Additional character sprites use **AmbientProximity** (auto dialogue, no E/F) + body collision. Full list:

| Floor | Ambient nodes |
|-------|----------------|
| 1 | `Supervisor1`, `Interactions/ExteriorExit/LabAssistant2`, `…/Worker5` |
| 2 | `NPCs/Worker5`, ExteriorExit `Supervisor1` / `Worker7` / `RinaForntView` |
| 3 | `Worker1`, `Worker2`, BoundLeft `Worker5` / `Worker6` |
| 4 | Background `Worker4` / `Worker2` / `Worker7`, `Karim` (`PlayerBackview` ignored) |

Do not wire ambient into quizzes, doors, or MiniGameArea SUCCESSFUL flow. See `Docs/AMBIENT_CHARACTERS.md`.

## Environment

| Scene | Texture |
|-------|---------|
| Exterior | `substation_entry.png` |
| Floor 1 | `substation_bay1_fundamentals.png` |
| Floor 2 | `substation_bay2_circuits.png` |
| Floor 3 | `substation_bay3_ohmslaw.png` |
| Floor 4 | `substation_bay4_diagnostics.png` |

Unused this phase: `substation_bay5_judgment.png`, `substation_capstone_core.png`, `substation_mg1_generator_workshop.png` (MG art deferred with real MG).

## Assessment rules

- Auto proximity (`InteractionArea` Area2D) → DialoguePanel → QuizPanel (no E/F on NPC)
- Exactly 10 unique questions / attempt from bank via `QuizController`
- 80% pass (8/10); retry = fresh random set
- Continue sets only the matching `zone04_floorN_passed` flag
- Floors 1–3: ExteriorExit → Exterior return spawn markers
- Floor 4: opens MiniGameArea placeholder UI; does **not** auto-return

## GameState

- `zone04_floor1_passed` … `zone04_floor4_passed`
- `zone04_exterior_spawn_marker`
- `zone04_complete` / `zone04_badge_earned` — complete is set by `mark_minigame_successful` on PLAY SUCCESSFUL; dedicated badge-ceremony flag may remain unset

## Door unlock (monotonic)

| Door | Unlocks when |
|------|----------------|
| 1 | Always |
| 2 | `zone04_floor1_passed` (or later floors / complete) |
| 3 | `zone04_floor2_passed` (or later) |
| 4 | `zone04_floor3_passed` (or later) |

Never re-lock a previously unlocked door.

## Mini-game placeholder (detail)

- `MiniGameArea` (Area2D + CollisionShape2D)
- PLAY MINI-GAME 1 → SUCCESSFUL (temporary demo — not real generator MG)
- Calls `mark_minigame_successful(ZONE_04)` → Zone 05 map pin unlock
- Canonical badge name: **Spark Emblem** (`ui_badge_spark_emblem.png`); ceremony UI may remain light

## Dialogue note

`Docs/Physics_Quest_Zone_04_Revised_NPC_Dialogue.md` still describes the old 5-floor Asha/Imran/… cast.  
This implementation uses **minimal placeholder** lines for Mira/Echo/Nadia/Farid until approved dialogue is authored for the current cast.

## Verifiers

```
Godot --headless -s res://scripts/tools/verify_zone04_exterior.gd
Godot --headless -s res://scripts/tools/verify_zone04_floors.gd
Godot --headless -s res://scripts/tools/verify_ambient_characters.gd
```

## Manual editor tuning

Tune in editor (do not rewrite from code): door positions, LockedVisual, NPC scale/position, InteractionAreas, ambient BodyCollision / AmbientProximity shapes, camera, collisions, return spawns, MiniGameArea.
