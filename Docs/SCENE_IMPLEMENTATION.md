# SCENE IMPLEMENTATION — Physics Quest

**Scope:** Scene implementation tracking (School → World Map → Zones 01–04).  
**Not for inventing new mini-game designs** (see `Docs/MINIGAME_IMPLEMENTATION.md` for current MG status).  
**Ambient / Supervisor upgrade guide:** `Docs/AMBIENT_CHARACTERS.md`  
**Last updated:** 2026-09-24 (Zone 02 MG placeholder, Harbor Works unused; World Map completed-zone visuals; Status Bar + Badge Screen; Fiber Escape; Emergency Brake)

### Canonical badges

| Zone | Badge | Art (exact on-disk path) | Flag |
|------|-------|--------------------------|------|
| 01 | Momentum Crest | `zone 1/badge_momentum_crest (1).png` | `zone01_badge_earned` |
| 02 | Radiant Crest | `zone 2/crest radiant.png` | `zone02_badge_earned` |
| 03 | Spectrum Crest | `zone 3/spectrum _badge.png` | `zone03_badge_earned` |
| 04 | Spark Emblem | `zone 4/ui_badge_spark_emblem.png` | `zone04_badge_earned` |
| 05 | Atomic Amber | `Environment/Zone_5_badge.png` | *(none yet)* |

### Floor4 mini-game gates

| Zone | Gate | Unlocks |
|------|------|---------|
| 01 | Real Emergency Brake | Zone 02 |
| 02 | Floor4 DemoCompleteUI placeholder: PLAY → SUCCESSFUL | Zone 03 |
| 03 | Real Fiber Escape (55° → 68°) | Zone 04 |
| 04 | PLAY → SUCCESSFUL placeholder | Zone 05 pin |

### Gameplay Status Bar + Badge Screen

| Piece | Path | Notes |
|-------|------|-------|
| Status Bar | `scenes/ui/GameplayStatusBar.tscn` | Instanced under `$UI` on Z01–Z04 Exterior/Floors + Z05 Exterior |
| Script | `scripts/ui/GameplayStatusBar.gd` | Top-right **BADGES** → `SceneTransition.change_to(BadgeScreen)` |
| Badge Screen | `scenes/ui/BadgeScreen.tscn` + `.gd` | Read-only; profile via `SaveManager.active_profile_name`; X/5 from GameState |
| Mini-games | — | **Do not** instance Status Bar on Brake / Fiber Escape (or legacy Harbor Works) |

Return uses `BadgeScreen.return_scene_path` (set by Status Bar). Hall button only at **5/5**. No autosave on open.

---

## Main Menu + profile save/load

**Main scene:** `res://scenes/ui/MainMenu.tscn`  
**Menu art:** `res://asset/sprites/load game screen.png` (ornate panel; transparent hotspots over NEW/LOAD/SAVE/QUIT — no Continue)  
**Autoloads:** `GameState`, `SceneTransition`, `SaveManager` (`scripts/autoload/SaveManager.gd`)  
**Storage:** `user://profiles/` (not `res://`)  
**Verify:** `scripts/tools/verify_save_system.gd`

| Action | Behavior |
|--------|----------|
| NEW GAME | ProfileCreate → enter name → `reset_for_new_profile` → write fresh profile → SchoolOpening |
| LOAD GAME | ProfileLoad list (name + progress_summary) → restore GameState + scene + player pos → “Profile Loaded” |
| SAVE GAME (menu) | Tip toast: use **S** in-game after a checkpoint |
| S (in-game) | Manual save if active profile + checkpoint; “Game Saved” / gate message |
| QUIT | `get_tree().quit()` |

**Checkpoint gate:** `GameState.has_progression_checkpoint()` — any `zone*_floor*_passed` or `zone*_minigame_successful`.  
**Duplicate profile:** confirm overwrite; cancel leaves existing file untouched.  
**No autosave.** Position restore runs after `SceneTransition.transition_finished` (floor spawn `_ready` first). NPC/environment transforms never rewritten.  
**UI scripts:** call SaveManager via `get_tree().root.get_node("SaveManager")` (`_save_manager()`), not the bare global identifier (avoids parse errors when autoload globals are not injected).

Gameplay / quiz / ambient / zone unlock architecture unchanged.

**Assessment dialogue (text only):** each Floor 1–4 Supervisor/assessor adds Bloom cognitive-level context (topic + levels from that floor’s question-bank `bloom_levels`). Floor 4 also adds Create-level mini-game context after the assessment, before the Mini-Game Area handoff (real MG or placeholder). Quiz logic unchanged.

---

## Ambient characters (Zone 01–04 floors)

**Canonical guide (inventory + how to extend):** `Docs/AMBIENT_CHARACTERS.md`  
**Scripts:** `scripts/npc/AmbientProximity.gd`, `scripts/npc/AmbientDialoguePools.gd`  
**Verify:** `scripts/tools/verify_ambient_characters.gd`  
**UI:** existing `DialoguePanel` only.

| Type | Who | Interaction |
|------|-----|-------------|
| Supervisor | Floor assessment NPC (Manager→Supervisor / Director / named assessor) | Existing InteractionArea → dialogue → quiz (**unchanged**) |
| Ambient | Other character-like NPCs/Sprite2Ds (not props/decor overlays) | Auto proximity → random ambient line (no E/F) |

Ambient nodes carry scene-authored `AmbientProximity` Area2D + (for Sprite2D) `BodyCollision` StaticBody2D. Transforms are not rewritten at runtime.

School: `TEACHER_LINE_SUPERVISOR` added after existing Teacher welcome line.

**When adding Zone 05 / new floors:** follow `AMBIENT_CHARACTERS.md` — classify Supervisor vs ambient, add scene nodes (do not runtime-generate collision), extend pools + verifier. Do not merge ambient into assessment.

**EXISTING FLOOR GAMEPLAY FLOWS WERE NOT CHANGED.**  
**SUPERVISOR ASSESSMENT FLOW WAS NOT CHANGED.**

---

## Progression connection (Floor 4 → MG → next Zone)

Floor 1–3 assessment flows are **unchanged**.

After each Zone’s Floor 4 quiz pass:

1. Mini-game entry
   - **Zone 01:** real Emergency Brake (`scenes/minigames/zone01/MiniGame01_Brake.tscn`)
   - **Zone 02:** Floor4 DemoCompleteUI placeholder — PLAY → `mark_minigame_successful(ZONE_02)` + `zone02_badge_earned` → SUCCESSFUL → World Map (**does not** launch Harbor Works; Harbor Works files unused legacy)
   - **Zone 03:** real Fiber Escape (`scenes/minigames/zone03/MiniGame03_FiberEscape.tscn`)
   - **Zone 04:** Click **PLAY MINI-GAME 1** → **SUCCESSFUL** (temporary demo; does **not** set `zone04_badge_earned`)
2. On real-MG pass / placeholder SUCCESSFUL → `mark_minigame_successful` → World Map
3. Sets `zoneN_minigame_successful` (+ `zoneN_complete` for compatibility)
4. `sync_world_map_unlocks()` unlocks the next Zone (monotonic)
5. **RETURN TO THE WORLD MAP** → `WorldMap.tscn`

Unlock condition: `floor4_passed AND minigame_successful` only.

**Badge flags:** Zone 02 placeholder sets `zone02_badge_earned`. Emergency Brake / Fiber Escape unlock the map without setting their badge flags yet. Badge Screen reflects flags only.

Zone 05: World Map click shows “Zone 05 coming soon.” Exterior stub: `scenes/zone05/Zone05_Exterior.tscn` (incomplete; not map-wired).

Zone 01 assets/data: `asset/minigame asset/zone 1 mini game/`, `data/zone01_minigames.json`.  
Zone 02 Harbor Works assets/data remain on disk unused (`mini_games_2_asset/`, `zone02_harbor_briefs.json`) — not in active flow.  
Zone 03 assets: `asset/minigame asset/zone 3 mini game/mini game 3 asset/` (**JPG**). Plan: `fiber_escape_implementation_plan.md`.  
Zone 04 real mini-game deferred.

### World Map landmark visuals

Full-color modulate if `is_zone_unlocked(zone)` **or** `zoneN_minigame_successful`.  
Clickable only if `is_zone_unlocked(zone)`. Zone 01 always available + full color.

---

## Zone 04 progression (AUTHORITATIVE — 4 floors)

```
Exterior (Guide=Volt)
→ Guide dialogue → instructs Door 1
→ Door1 → Floor1 (Professor Mira) → Exterior → Door2 unlock
→ Door2 → Floor2 (Echo) → Exterior → Door3 unlock
→ Door3 → Floor3 (Professor Nadia) → Exterior → Door4 unlock
→ Door4 → Floor4 (Engineer Farid) → Mini-Game PLAY placeholder only
```

- Guide: `NPCs/Guide` — Volt (`volt.png`). Auto Area2D dialogue only; no quiz; player enters Door 1 manually.
- **Exactly 4 floors.** No Floor 5, no fifth door, no capstone floor.
- Floor 3 does **not** Continue to Floor 4.
- Mini-game PLAY = “coming soon” — **no** badge, **no** `zone04_complete`, **no** Zone 05 unlock.
- Actual mini-games DEFERRED.
- Old 5-bay / Asha→Imran→Rafi→Samira→Arman dialogue mapping is **not** used.

### Banks

| Floor | Path | Formats |
|-------|------|---------|
| 1 | `data/zone04_floor1_questions.json` | MCQ |
| 2 | `data/zone04_floor2_questions.json` | MCQ |
| 3 | `data/zone04_floor3_questions.json` | MCQ + one_word |
| 4 | `data/zone04_floor4_questions.json` | MCQ + one_word |

Assessment: 10 unique / attempt, 80% pass, Continue sets floor flag only.

### World Map

Unlocked Zone 04 landmark click → `scenes/zone04/Zone04_Exterior.tscn` (not “coming soon”).

### Manual tuning

Door / NPC / camera / collision / InteractionArea transforms are **editor-authored**. Runtime must not overwrite them.

---

## Zone 03 progression (CORRECTED)

```
Exterior (Guide=Milon)
→ Door1 → Floor1 (Farid) → Exterior → Door2 unlock
→ Door2 → Floor2 (Shirin) → Exterior → Door3 unlock
→ Door3 → Floor3 (Tania) → Exterior → Door4 unlock
→ Door4 → Floor4 (Anwar) → Fiber Escape (MG03) → World Map → Zone 04 unlock
```

- Floor 3 does **not** Continue to Floor 4.
- Mini-Game 03 = **Fiber Escape** (real). Stage 1 SERVER ROOM (55°) → Stage 2 TRANSOCEANIC CABLE (68°) → `mark_minigame_successful(ZONE_03)`.
- Quizzes / Bloom / doors unchanged. Lab Bench is **not** a stage.

---

## World Map progression — Zone 03 → Zone 04

After Zone 03 Floor 4 pass **and** Fiber Escape success (`zone03_floor4_passed` + `zone03_minigame_successful`; `mark_minigame_successful` also sets `zone03_complete`):

Zone 04 landmark unlocks (full color). Click → `Zone04_Exterior.tscn`.

Unlock sync: `GameState.sync_world_map_unlocks()`.

Landmark **transforms unchanged**; runtime only sets `modulate` + `is_locked`.

**Canonical badge name:** Spectrum Crest (art `spectrum _badge.png`). Badge Screen uses GameState flag `zone03_badge_earned` (not set by Fiber Escape yet). Unlock authority for Zone 04 is the mini-game success flag.

Zone 04 badge (**Spark Emblem**) → Zone 05 unlock remains architecture-only until Z04 MG success.

---

## Zone 03 — Signal Station (IMPLEMENTED — assessments + Fiber Escape MG03)

**Exterior:** `scenes/zone03/Zone03_Exterior.tscn` (`signal_station_entry.png`, Guide=Anwar)  
**Doors:** Door1→F1, Door2 after F1, Door3 after F2 — **monotonic** unlock.

| Floor | Scene | Assessor | Room art | Bank |
|-------|-------|----------|----------|------|
| 1 | Zone03_Floor1 | Farid | deck1_waves | zone03_floor1 (50 MCQ) |
| 2 | Zone03_Floor2 | Shirin | deck2_sound | zone03_floor2 (50 MCQ) |
| 3 | Zone03_Floor3 | Tania | deck3_optics | zone03_floor3 (mixed) → Continue Floor4 |
| 4 | Zone03_Floor4 | Anwar | deck4_diagnostic | zone03_floor4 (mixed) |

**Floor 4 after pass:** MiniGameArea → PLAY MINI-GAME 03 → `MiniGame03_FiberEscape.tscn`.  
**Fiber Escape:** Stage 1 SERVER ROOM (θc 55°) → Stage 2 TRANSOCEANIC CABLE (θc 68°) → `GameState.mark_minigame_successful(ZONE_03)` → World Map → Zone 04 unlock.  
**Failure:** RETRY only; Zone 04 stays locked.  
**Scene / script:** `scenes/minigames/zone03/MiniGame03_FiberEscape.tscn`, `scripts/minigames/zone03/MiniGame03FiberEscape.gd`.  
**Assets:** `asset/minigame asset/zone 3 mini game/mini game 3 asset/` (JPG; reuse via modulate). `favicon.jpg` unused in Godot UI.  
**Verifier:** `VERIFY_MG3 fail=0` via `scripts/tools/verify_mg03_fiber_escape.gd`.  
**Milon:** not used. Quizzes / doors / Bloom unchanged.

**GameState:** `zone03_floor1..4_passed`, `zone03_minigame_successful`, `zone03_complete`, `zone03_badge_earned`, `zone03_exterior_spawn_marker`

---

## Zone 02 Floor 4 — Director final assessment (IMPLEMENTED)

**Scene:** `scenes/zone02/Zone02_Floor4.tscn`  
**Script:** `scripts/zone02/Zone02Floor4.gd`  
**Bank:** `res://data/zone02_floor4_questions.json` (MCQ + one_word; analyze/evaluate)  
**Art:** `energy_control_room.png` · Director: `director 1.png` · no supporting NPC

```
Floor3 Continue → Zone02_Floor4
Director InteractionArea (auto)
  → dialogue
  → QuizPanel (10 mixed, 80%)
  → CONTINUE ("Complete Zone 02")
  → zone02_floor4_passed + zone02_complete
  → completion dialogue + prompt
```

- No Exterior return. No Door 4. No mini-games. World Map / Zone 03 handoff deferred.
- Floor 3 → Floor 4 transition unchanged (scene now exists).

---

## Zone 02 Floor 3 — Assessment (IMPLEMENTED)

**Scene:** `scenes/zone02/Zone02_Floor3.tscn`  
**Script:** `scripts/zone02/Zone02Floor3.gd`  
**Bank:** `res://data/zone02_floor3_questions.json` (MCQ + one_word)  
**Art:** `energy_quiz_room_3.png` · Assessment: Karim (`karim.png`) · no supporting NPC

```
Karim InteractionArea (auto)
  → dialogue
  → QuizPanel (10 mixed, 80%)
  → CONTINUE → GameState.zone02_floor3_passed
  → Zone02_Floor4.tscn (not implemented yet → safe prompt)
```

- Pass Continue does **not** return to Exterior.
- Voluntary `ExteriorExit` → Exterior `@ Floor3ReturnSpawn` only.
- No mini-games. Floor 4 not implemented.

### Exterior door persistence

Monotonic unlock in `Zone02Exterior._apply_door_lock_state()`:
Door1 always open; Door2 after F1+; Door3 after F2+; never re-locks.

---

## Zone 02 Floor 2 — Assessment (IMPLEMENTED)

**Scene:** `scenes/zone02/Zone02_Floor2.tscn`  
**Script:** `scripts/zone02/Zone02Floor2.gd`  
**Bank:** `res://data/zone02_floor2_questions.json` (from `Docs/questions/zone 2/…`)  
**Art:** `energy_quiz_room_2.png` · Assessment: Farah (`farah.png`) · no supporting NPC

```
Farah InteractionArea (auto)
  → dialogue
  → QuizPanel (10 MCQ, 80%)
  → CONTINUE → GameState.zone02_floor2_passed
  → ExteriorExit → Zone02_Exterior @ Floor2ReturnSpawn
  → Door3 unlocks (Floor3 not implemented)
```

---

## Zone 02 Floor 1 — Assessment (IMPLEMENTED)

**Scene:** `scenes/zone02/Zone02_Floor1.tscn`  
**Script:** `scripts/zone02/Zone02Floor1.gd`  
**Bank:** `res://data/zone02_floor1_questions.json` (from `Docs/questions/zone 2/…`)  
**Art:** `energy_quiz_room_1.png` · Assessment: Nabila (`nabila.png`)

```
Nabila InteractionArea (auto)
  → dialogue
  → QuizPanel (10 MCQ, 80%)
  → CONTINUE → GameState.zone02_floor1_passed
  → ExteriorExit → Zone02_Exterior @ Floor1ReturnSpawn
  → Door2 unlocks
```

- No mini-games. Manual transforms editor-authored.
- Door2 → `Zone02_Floor2.tscn` when unlocked.

---

## Zone 02 Phase 1 — Exterior foundation (IMPLEMENTED)

**Scene:** `scenes/zone02/Zone02_Exterior.tscn`  
**Script:** `scripts/zone02/Zone02Exterior.gd`

```
Zone02_Exterior
├── Background/WingArt (energy_assessment_wing.png)
├── Camera2D (editor-authored)
├── Collision (boundaries + building blocks)
├── NPCs/Guide (Rina) + InteractionArea
├── NPCs/WorkerAmbient (non-interactive)
├── Doors/Door1 | Door2 (+LockedVisual) | Door3 (+LockedVisual)
├── PlayerSpawn / Player
├── DialoguePanel
└── UI/PromptLabel
```

- Guide: auto `body_entered` dialogue (Interactable disabled)
- Door1 available → Floor1 path prepared (`Zone02_Floor1.tscn` not created yet)
- Door2/Door3 locked prompts
- **Not in this phase:** floors, quiz, World Map unlock, mini-games

---

## Phase 11B — World Map click-only (IMPLEMENTED)

**Architecture:** Static level selector — **no Player, no PlayerSpawn, no WASD, no E/F.**

```
WorldMap
├── Background / Camera2D (fixed zoom 0.93)
├── Landmarks/Zone01/PropArt + ClickArea (unlocked → Exterior)
├── Landmarks/Zone02–05_Locked/PropArt + ClickArea (locked feedback)
└── UI/PromptLabel
```

- Click Factory → `SceneTransition` → `Zone01_Exterior.tscn`
- Locked click → `"Locked — this area is not available yet."`
- Click targets: scene-authored `MapClickTarget.gd` + `CollisionShape2D` (editable)
- Reuses `GameState.is_zone_unlocked(ZONE_01)`

---

## Phase 11A — Floor 1 Assessment (IMPLEMENTED)

**Bank:** `res://data/zone01_floor1_questions.json` (exact copy of `Docs/questions/…`; do not reorder options)  
**Controller:** `scripts/quiz/QuizController.gd` — exactly **10** questions, **80%** pass  
**UI:** `scenes/ui/QuizPanel.tscn`  
**Flag:** `GameState.zone01_floor1_passed` (default false)

### Flow

```
Enter Supervisor (Manager node) / InteractionArea (auto)
  → dialogue lines (speaker display: Supervisor)
  → QuizPanel (10 MCQ)
  → FAIL: TRY AGAIN (new random 10)
  → PASS: CONTINUE → zone01_floor1_passed = true
  → walk to Floor2Entrance (gated until pass)
```

Workers `Worker_01…03` are **ambient** (auto proximity dialogue) — separate from assessment. See `Docs/AMBIENT_CHARACTERS.md`.

### Demo mode

`QuizController.demo_first_option_is_correct` (default true on Floor1 scene): evaluates **first option text** as correct without changing JSON.

### Supervisor InteractionArea

Scene-authored under `NPCs/Manager/InteractionArea` + `CollisionShape2D` (detection only, not solid).  
Node name remains `Manager` for scene paths; `display_name` / dialogue speaker = **Supervisor**.  
`can_interact = false` (no E/F). Orphan `Interactions/Area2Dmanager interaction 2d` unused.

---

## Phase 10 — MG1 specification audit

Full report: `Docs/MG1_SPEC_AUDIT.md`. **MG1 not implemented.**

| Item | Result |
|------|--------|
| MG1 name | Emergency Brake (Friction) |
| Canonical entry | Floor 4 Director quiz ≥80% → emergency → Continue → MG1 |
| Default numbers | m=40 kg, μ=0.35, d=7 m; NO → 150 N (distractors 50/250) |
| Ramp art | `mg1_ramp_bg.png` 1376×768 present |
| Block art | **MISSING** (`mg1_block (1).png`) |
| Momentum Crest art | Present — award after **MG5**, not MG1 |

---

## Phase 9 audit

Full Zone 01 physical audit: `Docs/ZONE01_AUDIT.md`.

| Check | Result |
|-------|--------|
| Physical progression School → … → Floor 4 | **PASS** |
| NPC casts (Exterior 1+8, F1 1+3, F2 exactly 2, F3 1+2, F4 Director) | **PASS** |
| Manual override (no layout regen) | **PASS** |
| Collision scene-authored | **PASS** (visual **NOT TESTED**) |
| Cameras fixed / scene-authored | **PASS** |
| Real MG1–5 present | **No** (stubs only) |
| GDD MG1 entry | Post Floor 4 Director quiz + emergency |
| Phase 9 readiness | **READY WITH FIXES REQUIRED** — resolve Floor1 `MG1_Handoff` before real MG1 |

No scene redesign in Phase 9.

---

## Planned scene hierarchy

```
res://scenes/
├── boot/BootTest.tscn
├── school/
│   ├── SchoolOpening.tscn          # ACTIVE main scene (Phase 2)
│   ├── SeatedStudent.tscn
│   └── School.tscn                 # legacy stub
├── world_map/WorldMap.tscn         # implemented (Phase 3)
├── zone01/                         # Exterior + Floors 1–4 + MG stub
├── player/Player.tscn
├── npc/NPC.tscn
├── ui/DialoguePanel.tscn
└── components/SceneTrigger.tscn
```

Target flow (physical foundation complete; MG deferred):

```
SchoolOpening → WorldMap → Zone01_Exterior → Floor1 → Floor2 → Floor3 → Floor4
                                                          ↘ MG stub (placeholder only)
Floor4 MiniGameHandoff → MG stub (scaffolding; real entry = Director emergency Continue)
```

---

## School opening — IMPLEMENTED

**Scene:** `res://scenes/school/SchoolOpening.tscn`  
**Script:** `res://scripts/school/SchoolOpening.gd`  
**Main scene:** yes (`project.godot`)

### Node hierarchy (actual)

```
SchoolOpening
├── ClassroomBackground          # Sprite2D, classroom.png, centered=false, 1920×1072
├── Camera2D                     # pos (960,536), zoom 0.667
├── Collision
│   ├── Walls (bottom/left/right/top-right; door gap top-left)
│   ├── TeacherDesk
│   └── StudentDesks (Desk_R1C1 … Desk_R3C4)
├── Teacher                      # Node2D + Sprite2D teacher_idle.png scale 0.18
├── AmbientStudents              # 8 × SeatedStudent instances
│   ├── Student_01 … Student_08
├── MainPlayer                   # instance of Player.tscn, start_seated
├── OpeningSequence              # Marker2D waypoints only (editable)
│   ├── StandPoint
│   ├── WalkPoint_01
│   ├── WalkPoint_02
│   ├── DoorPoint
│   └── ExitPoint
└── DialoguePanel                # minimal CanvasLayer UI
```

### Asset mapping

| Node | Asset | Notes |
|------|-------|-------|
| ClassroomBackground | `asset/sprites/Environment/classroom.png` | 1920×1072, unmodified |
| Teacher/Sprite2D | `teacher_idle.png` | 429×587, scale **0.18** (default; editable) |
| AmbientStudents | `player seated.png` via `SeatedStudent.tscn` | scale **0.13** on sprite |
| MainPlayer seated | `player seated.png` on `SeatedSprite` | scale **0.13** |
| MainPlayer walk | `player animation.png` via PlayerAnimLibrary | scale **0.13**; left = flip |

### Student placement system

- **8 ambient students** at deterministic desk-ish positions (4×3 painted grid; MainPlayer desk left visually for MainPlayer).
- Positions authored in `.tscn` only. `SchoolOpening.gd` **never** writes AmbientStudents transforms.
- Each instance: editable position / scale / `face_left` / visibility; optional per-student collision (disabled by default).
- Independent of MainPlayer: standing up hides only MainPlayer seated sprite.

Initial ambient defaults (pixels, classroom space):

| ID | Position | face_left |
|----|----------|-----------|
| Student_01 | (538, 450) | false |
| Student_02 | (1075, 450) | false |
| Student_03 | (1344, 450) | true |
| Student_04 | (538, 600) | false |
| Student_05 | (1075, 600) | true |
| Student_06 | (1344, 600) | false |
| Student_07 | (806, 750) | false |
| Student_08 | (1075, 750) | true |

MainPlayer seated default: **(810, 616)** — near row-2 / col-2 (docs DESK_NORM ≈ 0.42, 0.56).

### Teacher

- Separate `Teacher` node — not baked into BG.
- Default position **(1152, 354)** ≈ docs TEACHER_NORM (0.60, 0.33).
- Interaction is sequence-driven (not free E-talk in this phase).

### MainPlayer

- Same `Player.tscn` / `PlayerController.gd` as Phase 1.
- `start_seated = true`, `scripted_control = true` for opening.
- API used: `set_seated`, `face_toward`, `move_along_path(..., release_control=false)`.

### Opening sequence states

```
PLAYER_SEATED
 → TEACHER_INTERACTION   (face teacher; documented dialogue)
 → PLAYER_STANDS         (hide seated sprite; show walk idle)
 → PLAYER_WALKS_TO_DOOR  (Stand → Walk01 → Walk02 → Door markers)
 → PLAYER_EXITS          (ExitPoint)
 → WORLD_MAP_TRANSITION  (SceneTransition → WorldMap foundation)
```

Dialogue (from master docs §1.2):

- Teacher: *Welcome to Physics Quest! You need to secure at least 80% marks in your assignments to pass.*
- Student: *Understood, Sir! I will do my best.*

### Waypoint system

Markers under `OpeningSequence` (defaults from docs norms × 1920×1072):

| Marker | Default pos | Role |
|--------|-------------|------|
| StandPoint | (806, 493) | leave seat / row gap |
| WalkPoint_01 | (230, 493) | left aisle |
| WalkPoint_02 | (230, 280) | up aisle |
| DoorPoint | (154, 150) | door approach |
| ExitPoint | (96, 86) | exit / fade |

Script reads `global_position` only — does not rewrite markers.

### Collision approach

- Scene-authored `StaticBody2D` + `CollisionShape2D` under `Collision/`.
- Walls, teacher desk, 12 student-desk footprints.
- Top-left door gap: no full top wall; `WallTopRight` covers chalkboard side only.
- **Not** regenerated at runtime.
- Scripted walk uses tween (path authority = markers); collision matters for any future free roam.

### Manual-edit rules

| Element | Authority | Code may… |
|---------|-----------|-----------|
| Ambient student transforms | `.tscn` | read only |
| Teacher transform | `.tscn` | read for facing target |
| MainPlayer spawn | `.tscn` | toggle seated/anim; move along markers |
| Collision shapes | `.tscn` | nothing |
| Waypoints | `.tscn` Marker2D | read positions |
| Dialogue text | constants in `SchoolOpening.gd` (documented lines) | play sequence |

---

## Classroom

See School opening. Painted empty desks remain in BG; occupied seats use `player seated.png` (includes desk art) over those spots.

---

## World Map — IMPLEMENTED (Phase 3) → **UPDATED Phase 11B (click-only)**

**Scene:** `res://scenes/world_map/WorldMap.tscn`  
**Script:** `res://scripts/world_map/WorldMap.gd`  
**Click helper:** `res://scripts/world_map/MapClickTarget.gd`

### Interaction model (Phase 11B)

- **Click-only** landmark selection
- **No** Player / PlayerSpawn / WASD / proximity / E-F
- Factory (`Zone01/ClickArea`) → Zone 01 Exterior
- Other landmarks locked → PromptLabel feedback

### Legacy Phase 3 notes

Player walking map is **obsolete**. Landmark visual positions/scales remain scene-authored.

---

### Node hierarchy (Phase 11B)

```
WorldMap
├── Background                 # worldmap_background.png 1376×768
├── Camera2D                   # fixed (688,384), zoom 0.93
├── Landmarks
│   ├── Zone01                 # factory PropArt + ClickArea + label
│   └── Zone02_Locked … Zone05_Locked  # PropArt + locked ClickArea
└── UI/PromptLabel             # locked feedback / hints
```

**Removed (obsolete walking map):** Player, PlayerSpawn, boundary collision, factory footprint, E/F Interactable.

### Asset mapping

| Node | Asset | Size | Notes |
|------|-------|------|-------|
| Background | `worldmap/worldmap_background.png` | 1376×768 | Native 1:1 pixels; not stretched by code |
| Zone01/PropArt | `worldmap/factory.png` | 503×414 | scale **0.55** default; has alpha |
| Zone02_Locked | `landmark_energy_refinery.png` | 1404×766 | scale ~0.16, dimmed |
| Zone03_Locked | `landmark_signal_station.png` | 1404×766 | scale ~0.14, dimmed |
| Zone04_Locked | `landmark_substation.png` | 1024×1024 | scale ~0.14, dimmed |
| Zone05_Locked | `landmark_unrevealed.png` | 1408×768 | scale ~0.12, dimmed |
| School landmark | — | — | **No school map asset on disk** |

### Camera decision

- Map **1376×768** vs viewport **1280×720**
- **Fixed camera** at map center, zoom **0.93**
- No player-follow camera

### Click targets

- Each landmark has scene-authored `ClickArea` + `CollisionShape2D` (`MapClickTarget.gd`)
- Factory unlocked; Zone 02–05 `is_locked = true`
- No procedural generation of click shapes

### Factory / Zone 01

- `Landmarks/Zone01` at **(198, 520)** (scene-authored)
- Left-click Factory → `select_zone01()` / ClickArea → Exterior
- Uses `GameState.is_zone_unlocked(ZONE_01)` (true by default)

### Transition

```
SchoolOpening → SceneTransition → WorldMap
WorldMap Factory click → SceneTransition → Zone01_Exterior
```

### Manual-edit rules (World Map)

| Element | Authority | Code may… |
|---------|-----------|-----------|
| Background / landmark transforms | `.tscn` | nothing |
| ClickArea shapes | `.tscn` | nothing |
| Camera zoom/pos | `.tscn` | nothing |
| PromptLabel | `.tscn` + script text | show locked / hide |

---

## Zone 01 Exterior — IMPLEMENTED (Phase 4)

**Scene:** `res://scenes/zone01/Zone01_Exterior.tscn`  
**Script:** `res://scripts/zone01/Zone01Exterior.gd`

### Node hierarchy (actual)

```
Zone01_Exterior
├── Background
│   ├── YardGrass              # factory_yard_grass_bg.png 1376×768 (walkable field)
│   ├── EntranceRoad           # road_factory_entrance.png rotated 90°, scaled
│   └── FactoryExterior        # factory_exterior (1).png scale 0.48
├── Camera2D                   # fixed (688,384) zoom 0.93
├── Collision
│   ├── Boundaries             # map edges only — grass NOT covered
│   ├── FactoryFootprint       # building body block
│   └── CrateApprox            # small prop block
├── Gate
│   ├── LockedVisual
│   ├── OpenVisual
│   └── Barrier/CollisionShape2D
├── NPCs
│   ├── Guard                  # guard 1.png (NOT full sheet)
│   ├── GuardAsidePoint        # Marker2D for step-aside
│   └── Workers/Worker_01…08
├── PlayerSpawn
├── Player
├── InteractionPoints/Floor1Entrance
├── DialoguePanel
└── UI/PromptLabel
```

### Asset mapping

| Node | Asset | Size | Notes |
|------|-------|------|-------|
| YardGrass | `factory_yard_grass_bg.png` | 1376×768 | Primary walkable area |
| EntranceRoad | `road_factory_entrance.png` | 672×1584 | Rotated π/2; leads toward gate |
| FactoryExterior | `factory_exterior (1).png` | 1296×1080 | Scale **0.48**; has alpha |
| Gate locked/open | `factory_gate_locked/open.png` | 944×548 / 944×593 | Toggle visibility |
| Guard | `guard 1.png` | 248×429 | Clean idle; sheet unused |
| Workers | worker 1/2/4/5/6/7.png | ~270–326 × 370–440 | Ambient |

**Decision:** Prefer `guard 1.png` over `guard_shee (1).png` (1920×1080 spritesheet — do not display whole sheet).

### Grass walkability

- Grass sprite is decorative background only — **no collision on grass**.
- Collision = boundaries + factory footprint + gate barrier (when locked) + small crate approx.
- Player walks freely on yard grass.

### Gate behavior

1. Start: LockedVisual on, OpenVisual off, Barrier enabled.
2. Player E/F with Guard → 2 dialogue lines → `GameState.zone01_guard_granted = true`.
3. Swap visuals; disable barrier; tween Guard to `GuardAsidePoint` (marker-authored).
4. Player walks through passage physically (no teleport).

### Worker composition (8)

| ID | Texture | Role | Facing |
|----|---------|------|--------|
| Worker_01–02 | w1 / w2 | Conversation group A (left grass) | right ↔ left |
| Worker_03–04 | w4 / w5 | Conversation group B (right grass) | right ↔ left |
| Worker_05–06 | w6 / w7 | Solo ambient | mixed |
| Worker_07–08 | w1 / w4 | Conversation group C (lower grass) | right ↔ left |

All: `enable_collision = false`, `can_interact = false`. Transforms never rewritten by code.

### Floor 1 entry

- `Floor1Entrance` Interactable near gate; `enabled` only after grant.
- E/F → `Zone01_Floor1.tscn` **stub** (no Floor 1 gameplay).

### Camera

Fixed zoom **0.93** on 1376×768 yard (same rationale as World Map). Editable in scene.

### Manual-edit rules (Exterior)

| Element | Authority | Code may… |
|---------|-----------|-----------|
| Grass / road / factory transforms | `.tscn` | nothing |
| Gate node transform | `.tscn` | toggle child visibility / barrier.disabled |
| Workers | `.tscn` | nothing |
| Guard initial pos | `.tscn` | one-time tween to AsidePoint on grant |
| GuardAsidePoint | Marker2D | read only |
| PlayerSpawn | Marker2D | copy → Player once |
| Collision shapes | `.tscn` | nothing |

---

## Zone 01 Floor 1 — IMPLEMENTED (Phase 5)

**Scene:** `res://scenes/zone01/Zone01_Floor1.tscn`  
**Script:** `res://scripts/zone01/Zone01Floor1.gd`  
**Art:** `factory_floor_1.png` **1296×1080** (measured)

### Node hierarchy (actual)

```
Zone01_Floor1
├── Background/Floor1Art
├── Camera2D                 # fixed (648,540) zoom 0.667
├── Collision                # walls (door gap bottom), machines, crates, pallet, stairs
├── NPCs
│   ├── Manager              # manager 1 fornt.png (documented Floor 1 cast)
│   └── Workers/Worker_01…03
├── PlayerSpawn              # bottom red-mat area (648, 960)
├── Player
├── Interactions
│   ├── MG1_Handoff          # near bolts/stain (980, 820) → MiniGame01 stub
│   ├── Floor2Entrance       # stairs approach → Floor2 stub
│   └── ExteriorExit         # bottom mat → Exterior
├── DialoguePanel
└── UI/PromptLabel
```

### Inspection notes (art)

- Walkable: green chevron floor
- Solids: purple walls, left console bank, top-right wood crates, bottom-right metal pallet, stairs mass
- Entry: bottom-center recess / red mat
- Stairs: right side → Floor 2 (stub only this phase)
- Bolts/stain lower-right → **MG1_Handoff** placeholder (GDD MG1 is post–Floor 4; handoff is navigation placeholder only)

### NPC composition

| NPC | Asset | Role |
|-----|-------|------|
| Manager (display **Supervisor**) | `manager 1 fornt.png` | Floor Supervisor — InteractionArea → assessment quiz |
| Worker_01–03 | worker 1 / 5 / 7 | **Ambient** — `AmbientProximity` auto dialogue + collision |

See `Docs/AMBIENT_CHARACTERS.md` for ambient inventory across all zones.

### Collision design

Multiple scene-authored shapes — **not** one room-filling box; **not** runtime-generated:

- Outer walls with bottom-center door gap
- LeftMachines, CratesTopRight, PalletBottomRight, StairsBlock
- Ambient NPC bodies (layer 4); player mask includes layer 4

### Camera

Floor **1296×1080** vs viewport **1280×720** → fixed zoom **0.667** (fit height). Editable.

### Interactions

| Point | Behavior |
|-------|----------|
| Manager | Brief assignment intro lines (no quiz) |
| MG1_Handoff | → `MiniGame01_Brake_Stub.tscn` (label only; no physics) |
| Floor2Entrance | → Floor 2 stub |
| ExteriorExit | → Zone01_Exterior |

### MG1 handoff

- Marker/area: `Interactions/MG1_Handoff` on Floor 1 remains an older Phase 5 stub path  
- **Authoritative Floor 4 gate (2026-09-21):** Mini-Game Area → `MiniGame01_Brake.tscn` (real Emergency Brake)  
- See `Docs/MINIGAME_IMPLEMENTATION.md`

### Manual-edit rules

Same hierarchy: scene transforms authoritative; script only snaps Player to PlayerSpawn and wires signals.

---

## Zone 01 Floor 2 — IMPLEMENTED (Phase 6)

**Scene:** `res://scenes/zone01/Zone01_Floor2.tscn`  
**Script:** `res://scripts/zone01/Zone01Floor2.gd`  
**Art:** `factory_floor_2.png` **1296×1080**

### Locked cast (exact)

| Role | Count | Asset |
|------|-------|-------|
| Player | 1 | Player.tscn |
| Manager | **1** | `manager 2 front.png` (docs Floor 2) |
| Lab Assistant | **1** | `lab assistant 1.png` |
| Extra NPCs | **0** | — |

### Node hierarchy

```
Zone01_Floor2
├── Background/Floor2Art
├── Camera2D                 # fixed (648,540) zoom 0.667
├── Collision                # walls (gaps top+bottom stairs), consoles, pallets, conveyor, press, barrels, crates
├── NPCs
│   ├── Manager
│   └── LabAssistant
├── PlayerSpawn              # (648, 960) bottom stairs mat
├── Player
├── Interactions
│   ├── Floor1Entrance       # → Floor 1
│   └── Floor3Entrance       # → Floor 3 stub
├── DialoguePanel
└── UI/PromptLabel
```

### Placement defaults (editable)

| Node | Position | Notes |
|------|----------|-------|
| Manager | (441, 260) | Docs-ish open strip under top consoles (~0.34, 0.22) |
| LabAssistant | (620, 560) | Open floor near conveyor; face_left |
| PlayerSpawn | (648, 960) | Bottom stairs |

### Collision

Multiple scene-authored shapes (not room-wide, not runtime): walls with stair gaps, ConsolesTopLeft/MidLeft, PalletsBottomLeft, ConveyorBlock, PressBlock, BarrelsTopRight, CratesBottomRight.

### Transitions

- Floor1 ↔ Floor2 (existing Floor1 `Floor2Entrance` + Floor2 `Floor1Entrance`)
- Floor2 → Floor3 stub (`Floor3Entrance`)
- No MG1 on this floor

### Camera

Same as Floor 1: fixed zoom **0.667**.

### Manual-edit rules

Scene transforms authoritative; script only snaps Player to PlayerSpawn and wires dialogue/exits. Never repositions Manager/LabAssistant.

---

## Zone 01 Floor 3 — IMPLEMENTED (Phase 7)

**Scene:** `res://scenes/zone01/Zone01_Floor3.tscn`  
**Script:** `res://scripts/zone01/Zone01Floor3.gd`  
**Art:** `factory_floor_3.png` **1296×1080**

### NPC cast

| Role | Count | Asset | Reason |
|------|-------|-------|--------|
| Manager | 1 | `manager 3 front.png` | Docs Floor 3 manager |
| Worker ambient | 2 | worker 2 / 4 | Light density; facing pair |
| Lab Assistant | 0 | — | Floor 2 locked cast only |
| Director | 0 | — | Floor 4 |

### Node hierarchy

```
Zone01_Floor3
├── Background/Floor3Art
├── Camera2D                 # fixed (648,540) zoom 0.667
├── Collision                # walls (stair gaps), console, left racks, servers, barrels, pallets, crate, debris
├── NPCs
│   ├── Manager
│   └── Workers/Worker_01–02
├── PlayerSpawn              # (648, 960) bottom stairs
├── Player
├── Interactions
│   ├── Floor2Entrance
│   └── Floor4Entrance       # → Floor 4
├── DialoguePanel
└── UI/PromptLabel
```

### Collision (docs: left equipment, top-right servers, debris)

Multiple scene-authored shapes — not room-wide, not runtime.

### Transitions

Floor2 ↔ Floor3; Floor3 → Floor4. No mini-game handoff on this floor.

### Camera

Fixed zoom **0.667**.

### Manual-edit rules

Same as prior floors: scene transforms authoritative; script snaps PlayerSpawn only.

---

## Zone 01 Floor 4 — IMPLEMENTED (Phase 8)

**Scene:** `res://scenes/zone01/Zone01_Floor4.tscn`  
**Script:** `res://scripts/zone01/Zone01Floor4.gd`  
**Art:** `factory_floor_4.png` **1296×1080**

### NPC cast

| Role | Count | Asset |
|------|-------|-------|
| Director | **1** | `director 1.png` |
| Extra NPCs | **0** | — |

### Node hierarchy

```
Zone01_Floor4
├── Background/Floor4Art
├── Camera2D                 # fixed (648,540) zoom 0.667
├── Collision                # walls, bookshelf, consoles, desk, side table, machine, crates
├── NPCs/Director            # behind desk area (680, 200)
├── PlayerSpawn              # (648, 960) bottom stairs
├── Player
├── Interactions
│   ├── Floor3Entrance
│   └── MiniGameHandoff      # right stair alcove → MG1 stub ONLY
├── DialoguePanel
└── UI/PromptLabel
```

### Collision (docs: bookcases, center desk, pedestal, crates)

Multiple scene-authored shapes — not room-wide, not runtime.

### Director interaction

Brief office intro lines (no quiz). Quiz / emergency phone / real MG remain deferred.

### MiniGameHandoff

- Editable Area2D near right stair alcove `(1100, 520)`
- Transitions to existing `MiniGame01_Brake_Stub.tscn` (label only)
- **Not** real MG1–5 physics/UI

### Transitions

Floor3 ↔ Floor4; Floor4 → MiniGame stub placeholder.

### Camera

Fixed zoom **0.667**.

### Manual-edit rules

Scene transforms authoritative; script snaps PlayerSpawn + wires signals only.

---

## Zone 01 completion (physical + MG gate)

Physical navigation chain complete:

`Exterior → F1 → F2 → F3 → F4 → Emergency Brake → World Map (Zone 02 unlock)`

Real Zone 01 mini-game: **IMPLEMENTED** (`Docs/MINIGAME_IMPLEMENTATION.md`). Zone 01 Floor1 `MG1_Handoff` stub is legacy navigation only.

---

## Player movement / animation

- Foundation + seated: **IMPLEMENTED**
- School: scripted; Map / Exterior / Floors: normal control

---

## Interactions / triggers

- Per-scene as documented; Floor1 MG1_Handoff remains older Phase 5 placeholder; Floor4 MiniGameHandoff is the GDD-aligned future sequence entry

---

## Manual scene adjustments

| Scene | What changed | Date |
|-------|--------------|------|
| — | _(developer edits go here)_ | — |

---

## Default values vs override values

| Key | Default | Override | Final |
|-----|---------|----------|-------|
| Floor4 PlayerSpawn | (648,960) | edit Marker2D | marker → player |
| Director | (680,200) / 0.32 | edit NPC | scene |
| MiniGameHandoff | (1100,520) | edit Area2D | scene |
| Floor camera zoom | 0.667 | edit Camera2D | scene |
| Collision | shape nodes | move/resize | scene |






