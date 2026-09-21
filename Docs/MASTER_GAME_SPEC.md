# PHYSICS QUEST — MASTER GAME SPEC

**Document type:** High-level permanent specification for this fresh Godot project  
**Project root:** `d:\capstone 2`  
**Engine:** Godot 4.7.1 (GDScript)  
**Assets:** `asset/` → `res://asset/`  
**Source docs (read-only inventory):** `Docs/PHYSICS_QUEST_MASTER.md`, `Docs/zone01_minigame_implementation_spec.md`, zone 02–05 GDDs  
**Living status:** `Docs/PROGRESS.md`  
**Last updated:** 2026-09-21 (Zone 01 Emergency Brake + Zone 03 Fiber Escape real MGs; badges; profile save/load; ambient)

---

## Game title

**Physics Quest**

---

## Overall game concept

Educational 2D top-down / 2.5D-flavored interactive learning experience. A secondary-school student receives a physics assignment in class, then travels through themed industrial/scientific sites on a world map. At each site the player faces dialogue, assessments, and hands-on mini-games (where implemented). Completing a zone’s Floor 4 assessment **and** mini-game success unlocks the next map location (`floor4_passed AND minigame_successful`).

**Educational framing (from supplied docs):** Contextual physics aligned with Bangladesh Class 9–10 syllabus ideas; pass threshold commonly **≥ 80%** on assessments. Formal evaluation instruments from the proposal are **not** in scope for this project phase.

---

## Core gameplay loop (documented target)

1. **Main Menu** → New Game (profile) or Load Game → Classroom opening → assignment briefing (Teacher mentions floor Supervisors)  
2. World Map → select unlocked zone  
3. Zone exploration (exterior → floors / rooms)  
4. Ambient worker dialogue + Supervisor assessment (and later mini-games)  
5. Floor 4 quiz → zone mini-game (real or temporary SUCCESSFUL) → World Map → next zone unlocks  

**Living status:** `Docs/PROGRESS.md` · Scene tracking: `Docs/SCENE_IMPLEMENTATION.md` · Ambient upgrade guide: `Docs/AMBIENT_CHARACTERS.md`

---

## Scene progression (current development target)

```
Main Menu (New / Load / Save tip / Quit)
        ↓
School Opening Scene  (or loaded saved scene)
        ↓
World Map
        ↓
Zone 01–04 (Exterior → Floors 1–4 → Floor4 mini-game gate)
        ↓
Zone 05 map pin (“coming soon” — no scene yet)
```

**Mini-game status (this rebuild):**
- Zone 01: **real** Emergency Brake → unlocks Zone 02
- Zone 02: temporary PLAY → SUCCESSFUL placeholder → unlocks Zone 03
- Zone 03: **real** Fiber Escape (2 stages) → unlocks Zone 04
- Zone 04: temporary PLAY → SUCCESSFUL placeholder → unlocks Zone 05 map pin

---

## World structure

| Zone | Location (docs) | Badge (canonical) | Status this project |
|------|-----------------|-------------------|---------------------|
| 01 | Mechanics Factory | **Momentum Crest** | **Implemented** — Exterior + F1–4 + real Emergency Brake MG |
| 02 | Energy Refinery / Assessment Wing | **Radiant Crest** | **Implemented** — assessments + MG SUCCESSFUL placeholder |
| 03 | Signal Station | **Spectrum Crest** | **Implemented** — Exterior + F1–4 + real Fiber Escape MG |
| 04 | The Substation | **Spark Emblem** | **Implemented** — 4 floors + Volt guide + MG SUCCESSFUL placeholder |
| 05 | Not fully locked in docs | — | Map pin only after Z04 SUCCESSFUL; scene **deferred** |

### Zone badges (canonical names + art)

| Zone | Badge name | Asset path |
|------|------------|------------|
| 01 | Momentum Crest | `asset/sprites/Environment/zone 1/badge_momentum_crest (1).png` |
| 02 | Radiant Crest | `asset/sprites/Environment/zone 2/crest radiant.png` |
| 03 | Spectrum Crest | `asset/sprites/Environment/zone 3/spectrum badge.png` |
| 04 | Spark Emblem | `asset/sprites/Environment/zone 4/ui_badge_spark_emblem.png` |

Do **not** use superseded Map A names (Flux Badge, Lens Token, or Spark Emblem-as-Zone-02). Unlock authority is `GameState.mark_minigame_successful` + `sync_world_map_unlocks()`, not badge UI alone.

---

## Zone 01 structure

Documented flow:

```
Factory Exterior / Yard (+ road + gate + guard)
        ↓
Floor 1 (Supervisor/Manager node + 3 ambient workers + assessment)
        ↓
Floor 2 (Supervisor + Lab Assistant ambient)
        ↓
Floor 3 (Supervisor + 2 ambient workers)
        ↓
Floor 4 (Director Supervisor + ambient sprites + Emergency Brake mini-game)
        ↓
World Map unlock Zone 02 (after MG success)
```

**Floor 2 cast:** Player + Supervisor (Manager node) + Lab Assistant. Lab Assistant is **ambient** (auto proximity), not an assessor. See `Docs/AMBIENT_CHARACTERS.md`.

World Map art on disk: `worldmap_background.png` + landmark props including Zone 01 `factory.png`.

---

## Player requirements

Must support:

- Movement (WASD / arrows)
- Idle / walking animation
- Facing direction (up / down / left / right)
- Collision (never walk through solid objects)
- Scene transitions
- Interaction (E / F planned)
- Scripted movement when required (classroom exit sequence)

### Player asset decision (Phase 1 audit)

| Asset | Size | Role |
|-------|------|------|
| `asset/sprites/animation/player animation.png` | 1407×768 | Primary walk sheet: 3×3 grid — DOWN, UP, RIGHT (label LEFT RIGHT) |
| `player left view.png` | 208×365 | Dedicated left-facing idle/static available |
| `player right view.png` | 214×392 | Dedicated right-facing static |
| `player front or down.png` / `player backview.png` | — | Directional statics |
| `player seated.png` | 363×450 | Seated student (+ desk) for classroom; reusable ambient instances |

**Decision:** Use `player animation.png` for roam idle/walk. Horizontal flip of the RIGHT row for left-facing walk. Dedicated left static available if idle quality needs it later. Do **not** duplicate animation PNGs.

---

## NPC requirements

Reusable NPC scene/component with:

- Sprite
- Editable position / scale / rotation
- Optional collision
- Optional interaction + dialogue hook
- Optional movement (only when required)
- Scene-specific configuration via exports / scene tree

Placement is **deterministic and editor-editable**. No random spawn on start.

### Supervisor vs ambient (Zones 01–04)

| Role | Behavior |
|------|----------|
| **Supervisor** | Floor assessment NPC — existing InteractionArea → dialogue → quiz. Zone 01 Managers use display name **Supervisor**. |
| **Ambient** | Other character-like NPCs/sprites — `AmbientProximity` auto dialogue (no E/F). Not assessors. |

Full inventory and upgrade steps: **`Docs/AMBIENT_CHARACTERS.md`**.

### Character assets available (Zone 01 relevant)

- Teacher: `teacher_idle.png`
- Guard: `guard 1.png`, `guard_shee (1).png` (sheet; prefer dedicated idle when wiring)
- Managers (Supervisor role): `manager 1 fornt.png`, `manager 2 front.png`, `manager 3 front.png`
- Lab assistants: `lab assistant 1.png`, `lab assistant 2.png`, `lab assistant 3.png`
- Director: `director 1.png`
- Supervisor art: `supervisor 1.png` (also used as ambient coworker sprites on some floors)
- Workers: `worker 1/2/4/5/6/7.png`
- Named cast (later zones): farah, karim, nabila, rina, Zone 3 / Zone 4 folders

Ambient classroom students: instances of `player seated.png` under an `AmbientStudents` node — **not** the main player. Separate from factory-floor ambient workers.

---

## Collision requirements

- Collision shapes live in scenes; editable in Godot editor
- Footprint-aligned shapes for desks, machinery, boundaries — not one giant arbitrary box when it hurts movement
- **Do not** regenerate collision transforms from code every frame / every load from a hidden coordinate table that fights the editor
- Player collision layers/masks configured once; walls on a separate layer
- **Layers (authoritative):** 1 = player, 2 = world/walls, 4 = NPC/ambient bodies, 8 = interaction detect areas  
- Player `collision_mask` = `2 | 4` so character bodies block movement

---

## Manual override architecture (CRITICAL)

Hierarchy:

```
DEFAULT CONFIGURATION
        ↓
SCENE-SPECIFIC OVERRIDE (scene tree / exported values on instance)
        ↓
FINAL RUNTIME VALUE
```

Rules:

1. First implementation may ship sensible **defaults** on scripts (`@export` values).
2. Placing or editing a node in a `.tscn` **is** the scene-specific override.
3. Runtime code must **not** overwrite `position`, `scale`, `rotation`, or collision shape extents when those were authored in the scene, unless an explicit “force defaults” / debug tool is opted into.
4. Prefer reading authored scene values. Use defaults only when a property is unset / zero-sentinel **and** a documented fallback applies.
5. Future feature code changes functionality (signals, dialogue, gates) without destroying manual layout.

Documented in scene work via `docs/SCENE_IMPLEMENTATION.md`.

---

## Asset usage rules

- Use supplied assets; do not replace with generated placeholders when real art exists
- Do not alter original asset files
- Do not rename source assets without a compelling technical reason
- Prefer files **without** Windows duplicate suffixes `(2)`; treat `(1)` names as the available file when that is the only copy
- Mini-game-only art stays unused until mini-game phase
- Do not bake ambient students into `classroom.png`

---

## Manual-editing rules

Developer must be able to edit in the editor without fighting code:

- NPC position / scale / flip / visibility
- Player spawn
- Collision position / size
- Interaction points / trigger areas
- Waypoints / door positions
- Ambient student instances

---

## Current development scope (Phase 1)

**Implement now:**

1. Project foundation  
2. Documentation system  
3. Asset audit (recorded)  
4. Reusable player foundation  
5. Reusable NPC foundation  
6. Reusable collision approach (scene-authored)  
7. Scene transition foundation  
8. School / World Map / Zone 01 **architecture placeholders** (not polished gameplay)

**Do not implement yet (historical Phase 1 list — partially superseded):**

- Full Zone 01 MG2–MG5 chain / Momentum Crest ceremony UI  
- Zones 02 & 04 **real** mini-game mechanics (still PLAY→SUCCESSFUL placeholders)  
- Zone 05 gameplay scene  

**Implemented since Phase 1 (see living docs):** Zone 01–04 assessments, ambient characters, profile save/load, Zone 01 Emergency Brake, Zone 03 Fiber Escape.

---

## Mini-game scope (current)

Authoritative: `Docs/MINIGAME_IMPLEMENTATION.md`.

| Zone | Current gate |
|------|----------------|
| 01 | Real Emergency Brake → Zone 02 |
| 02 | PLAY → SUCCESSFUL placeholder → Zone 03 |
| 03 | Real Fiber Escape (Server Room 55° → Transoceanic 68°) → Zone 04 |
| 04 | PLAY → SUCCESSFUL placeholder → Zone 05 pin |

Older five-MG Factory Emergency order (Brake → Gear → Balance → Pressure → Pulley → Momentum Crest) remains **reference-only**.

---

## Important constraints

- Fresh implementation — do not blindly recreate prior `final-godot` runtime layout generators
- Scenes remain Godot-editable
- Inspect assets before inventing sizes/placements
- Least-assumptive choices; document decisions; TODO when unknown
- Update `docs/PROGRESS.md` after every meaningful implementation task

---

## Decisions made during implementation

| ID | Decision | Rationale |
|----|----------|-----------|
| D1 | GDScript + Godot 4.7.1 | Matches available engine on machine and master doc engine note |
| D2 | Project root = workspace root; assets stay at `asset/` | Assets already present; avoid moving/renaming |
| D3 | Autoloads: `GameState`, `SceneTransition`, `SaveManager` | Progression + fades + profile JSON under `user://profiles/` |
| D4 | Player walk from `player animation.png` + flip for left | Sheet documents LEFT RIGHT as shared; left static PNG reserved |
| D5 | Collision authored in scenes, not JSON regenerate | Manual override rule |
| D6 | Floor 2 cast locked to Manager + Lab Assistant | Explicit user requirement |
| D7 | Mini-games deferred | Explicit phase boundary |
| D8 | World Map substitutes school→factory overworld walk | Master doc: schoolyard road scene MISSING; map is the available path |
| D9 | Ambient students = instanced `player seated.png` under `AmbientStudents` | User requirement; editable instances |
| D10 | Boot test scene verifies foundation before polished School | Phase 1 workflow |
| D11 | Main scene = `scenes/ui/MainMenu.tscn` | Profile New/Load/Save/Quit; New Game → SchoolOpening |
| D12 | 8 ambient seated students (not all 12 desks) | Density without overcrowding |
| D13 | Opening dialogue from master §1.2 verbatim | Do not invent story |
| D14 | Waypoints are Marker2D; script never rewrites them | Manual override rule |
| D15 | Minimal DialoguePanel only | No full dialogue framework yet |
| D16 | World Map uses fixed Camera2D zoom 0.93 | Map 1376×768 fits 1280×720; no follow-cam needed |
| D17 | Zone 01 map entry via Interactable E/F | Reuse Phase 1 interact; no click-map UI system |
| D18 | Z02–05 landmarks dimmed non-interactive | Map structure without unlock gameplay |
| D19 | Exterior Guard uses `guard 1.png` | Clean idle; `guard_shee` is a full sheet |
| D20 | Yard grass has no collider | Grass must stay walkable |
| D21 | 8 exterior workers; 3 facing conversation pairs | Occupied yard without overcrowding |
| D22 | Floor 1 fixed camera zoom 0.667 | Fit 1296×1080 art height into 720p viewport |
| D23 | Floor 1 NPCs = Manager 1 + 3 workers | Matches docs Floor 1 manager; light density |
| D24 | MG1_Handoff → stub only on Floor 1 | Phase 5 stop; no mini-game physics |
| D25 | Floor 2 uses Manager 2 + Lab Assistant 1 | Docs Floor 2 manager + locked cast |
| D26 | Floor 2 has exactly two NPCs | User lock: no ambient extras |
| D27 | Floor 3 Manager = `manager 3 front.png` | Docs Floor 3 manager |
| D28 | Floor 3 ambient = 2 workers; no lab/director | Density without contradicting Floor2/4 casts |
| D29 | Floor 4 cast = Director only (`director 1.png`) | Docs Floor 4 Director office |
| D30 | Floor 4 MiniGameHandoff is stub-only | Physical foundation complete; MG later |
| D31 | Floor assessment role = Supervisor | Zone 01 Manager display_name/speaker → Supervisor; named assessors keep names |
| D32 | Ambient ≠ assessment | Separate `AmbientProximity` system; no E/F; no quiz banks |
| D33 | Player mask includes NPC layer 4 | Character bodies block; walls remain layer 2 |
| D34 | Teacher additive Supervisor line | School context only; School→Map unchanged |
| D35 | Ambient guide doc | `Docs/AMBIENT_CHARACTERS.md` is upgrade authority |
| D36 | Profile save/load | `SaveManager` + `user://profiles/`; manual **S** after checkpoint; no autosave |
| D37 | Menu art hotspots | `load game screen.png`; UI reaches SaveManager via `/root/SaveManager` |
| D38 | Zone MG gates | Z01 Emergency Brake + Z03 Fiber Escape are real; Z02/Z04 placeholders; no `MiniGameBase` |
| D39 | Canonical badges | Momentum Crest / Radiant Crest / Spectrum Crest / Spark Emblem |

---

## Unknown / TODO (do not guess)

- Exact classroom desk collision footprints relative to painted BG — calibrate in editor after School scene build  
- Guard sheet vs `guard 1.png` for exterior — prefer cleaner idle; verify chroma needs  
- Audio wiring — files exist; Dummy driver note in old docs; wire later  
- Fonts folder is empty — use Godot default font until fonts supplied  
- Zone 02 & Zone 04 **real** mini-games (Harbor Works / generator) — still deferred; see `Docs/MINIGAME_IMPLEMENTATION.md`  
- Zone 01 MG2–MG5 chain / crest ceremony polish — optional; not required for Zone 02 unlock  
- Zone 05 scene — map pin only after Z04 SUCCESSFUL  
- Per-character ambient proximity shape polish — optional editor tuning (`AMBIENT_CHARACTERS.md`)  
- Zone 04 approved cast dialogue (Mira/Echo/Nadia/Farid) — placeholders until authored  
