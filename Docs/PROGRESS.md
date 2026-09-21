# PROGRESS — Physics Quest

**Living development log.** Update after every meaningful implementation task.  
**Reflect real state only.** Untested = NOT TESTED. Partial = PARTIALLY IMPLEMENTED.

Docs sync 2026-09-21: living specs (`MASTER_GAME_SPEC`, `MINIGAME_IMPLEMENTATION`, `SCENE_IMPLEMENTATION`, audits, GDD notes) updated for Fiber Escape, Emergency Brake, and canonical badges.

---

# Current Status

**Profile save/load IMPLEMENTED** (`user://profiles/`, Main Menu New/Load/Quit, in-game **S** after checkpoint; no autosave).  
Canonical notes: section below + `Docs/SCENE_IMPLEMENTATION.md`. UI reaches `SaveManager` via `/root/SaveManager`.  
**Supervisor assessment dialogue** now includes Bloom cognitive-level context (topic + Remember→Evaluate per floor; Floor 4 also introduces Create-level mini-game context). Dialogue text only — quizzes unchanged.  
Ambient characters and Zone 01–04 progression remain as previously documented.

**Ambient factory characters IMPLEMENTED** on Zone 01–04 floors: proximity auto-dialogue (no E/F), body collision, Supervisor role on Zone 01 Managers, Teacher school line about Supervisors.  
Canonical upgrade guide: `Docs/AMBIENT_CHARACTERS.md`.  
Assessment / quiz / door / mini-game / World Map unlock flows unchanged.

**Progression connection IMPLEMENTED:** each Zone Floor 4 quiz → mini-game → success → next Zone unlocks → RETURN TO WORLD MAP.  
**Zone 01** uses the **real Emergency Brake** mini-game (`scenes/minigames/zone01/MiniGame01_Brake.tscn`).  
**Zone 02** uses the **real Harbor Works** mini-game (`scenes/minigames/zone02/MiniGame02_HarborWorks.tscn`).  
**Zone 03** uses the **real Fiber Escape** mini-game (`scenes/minigames/zone03/MiniGame03_FiberEscape.tscn`).  
Zone 04 still uses the temporary PLAY → SUCCESSFUL placeholder.  
**Canonical badges:** Momentum Crest · Radiant Crest · Spectrum Crest · Spark Emblem (see `Docs/MASTER_GAME_SPEC.md`).  
Floor 1–3 flows unchanged.

### Deferred / next upgrades (tracked)

| Item | Doc |
|------|-----|
| Real mini-games (Z02, Z04) | `Docs/MINIGAME_IMPLEMENTATION.md` |
| Zone 05 scene | Map pin only; no scene yet |
| Zone 04 approved assessor dialogue | `Docs/ZONE04_IMPLEMENTATION.md` |
| New ambient characters / Zone 05 floors | `Docs/AMBIENT_CHARACTERS.md` |
| Ambient proximity shape polish | Editor only — do not move sprites |

---

# Completed

## 2026-09-21 — Zone 02 real Harbor Works mini-game

Replaced Zone 02 Floor 4 fake SUCCESSFUL gate with playable **Harbor Works** (Mini-Game 02).

- **Scene:** `scenes/minigames/zone02/MiniGame02_HarborWorks.tscn`
- **Controller:** `scripts/minigames/zone02/MiniGame02HarborWorks.gd` (extends `Control`; no `MiniGameBase`)
- **Assets:** `asset/minigame asset/zone 2 mini game/mini_games_2_asset/` (19 PNGs; `liver_*.png` exact names)
- **Briefs:** `data/zone02_harbor_briefs.json` (Load Cargo Ship / Rescue Lifeboat / Storm Blackout)
- **Success:** all 3 briefs pass → `zone02_badge_earned` + `mark_minigame_successful(ZONE_02)` → World Map → Zone 03
- **Floor4:** PLAY launches MG2 only (no fake mark)
- **Verifier:** `VERIFY_MG2 fail=0`
- Quizzes / Floor1–3 / Z01 / Z03 / Z04 untouched

---

## 2026-09-21 — Zone 03 real Fiber Escape mini-game

Replaced Zone 03 Floor 4 fake SUCCESSFUL gate with playable **Fiber Escape** (Mini-Game 03).

- **Scene:** `scenes/minigames/zone03/MiniGame03_FiberEscape.tscn`
- **Controller:** `scripts/minigames/zone03/MiniGame03FiberEscape.gd` (extends `Control`; no `MiniGameBase`)
- **Assets:** `asset/minigame asset/zone 3 mini game/mini game 3 asset/` — **JPG** filenames as on disk (`Sensor_ring.jpg`, `Icon_clear.jpg`, etc.)
- **Plan ref:** `asset/minigame asset/zone 3 mini game/fiber_escape_implementation_plan.md` (HTML sprite plan adapted to Godot)
- **Stage 1:** SERVER ROOM, θc = 55°
- **Stage 2:** TRANSOCEANIC CABLE, θc = 68° (unlocks only after Stage 1 success)
- **Success:** Stage 2 clear → `GameState.mark_minigame_successful(ZONE_03)` → World Map → Zone 04 unlock
- **Failure:** leak/obstacle feedback + RETRY; does **not** unlock Zone 04
- **Canonical badge:** Spectrum Crest (`spectrum badge.png`)
- **Floor4:** `Zone03Floor4.gd` PLAY launches MG3 scene (no fake mark)
- **Verifier:** `scripts/tools/verify_mg03_fiber_escape.gd` → `VERIFY_MG3 fail=0`
- Zones 01 / 02 / 04 gameplay untouched. Zone 03 quizzes / Bloom / doors unchanged.
- **Manual tuning left:** playfield obstacle/waypoint coordinates (STAGES const fallbacks), chroma-key thresholds for JPG black backgrounds, HUD icon sizing.

---

## 2026-09-20 — Zone 01 real Emergency Brake mini-game

Replaced Zone 01 Floor 4 fake SUCCESSFUL gate with playable Emergency Brake using assets under `asset/minigame asset/zone 1 mini game/`. Scene: `scenes/minigames/zone01/MiniGame01_Brake.tscn`. Success calls `GameState.mark_minigame_successful(ZONE_01)` then World Map. Fail shows FACTORY DAMAGED and retries a new scenario. *(At time of write: Zones 02–04 placeholders. **Superseded for Zone 03:** Fiber Escape shipped 2026-09-21.)*

---

Added one cognitive-level explanation line to each Zone 01–04 Floor 1–4 assessor dialogue (topic from existing floor wording / bank zone + `bloom_levels` from question JSON). Floor 4 also speaks a Create-level mini-game context line after the quiz, before the existing Mini-Game Area / placeholder flow. Existing lines preserved; quiz banks, scoring, thresholds, and gameplay unchanged.

---

### Entry

Main scene: `res://scenes/ui/MainMenu.tscn`  
Menu visual: `res://asset/sprites/load game screen.png` with transparent hotspots over painted NEW / LOAD / SAVE / QUIT.  
**No Continue button** (not on menu art).

| Button | Flow |
|--------|------|
| NEW GAME | `ProfileCreate.tscn` → name → fresh `GameState` → `SchoolOpening.tscn` |
| LOAD GAME | `ProfileLoad.tscn` → pick profile → restore GameState + scene + player pos |
| SAVE GAME | In-menu tip only (toast: use **S** in-game after a checkpoint) |
| QUIT | `get_tree().quit()` |

### Storage (`user://` only — never `res://`)

- Index: `user://profiles/index.json` → `{ "version": 1, "profiles": ["Demo One", ...] }`
- Per profile: `user://profiles/<sanitized_name>.json`
- Fields: `version`, `profile_name`, `current_scene`, `player_position` `{x,y}`, `progress_summary`, `game_state` (full progression blob), `saved_at_unix`, `is_new_profile`
- **No autosave**, no save on scene transition, no per-frame save. Manual **S** only (`save_game` input). **S** remapped off `move_down` (Down arrow moves down).

### S-key rules

- Requires active profile + `GameState.has_progression_checkpoint()` (any zone floor pass **or** mini-game SUCCESSFUL)
- Pre-checkpoint toast: “Save is available after completing a progression checkpoint.”
- Success toast: “Game Saved”

### Load / restore

1. `GameState.apply_save_data`  
2. `SceneTransition` to saved `current_scene`  
3. After `transition_finished` + frames: restore player `global_position` (skips World Map / brand-new profiles)  
4. Toast: “Profile Loaded”  
Does **not** rewrite NPC/environment transforms. Missing scene → clear error toast (no silent new game).

### Duplicate names

ProfileCreate shows confirm: “A profile with this name already exists. Overwrite it?”  
Cancel leaves existing profile untouched.

### Autoload + UI access

- Autoload key: `SaveManager` → `res://scripts/autoload/SaveManager.gd` (with `GameState`, `SceneTransition`)
- GameState remains single progression source of truth (`get_save_data` / `apply_save_data` / `reset_for_new_profile`)
- Menu UI scripts resolve the singleton via `get_tree().root.get_node("SaveManager")` (`_save_manager()`) so they parse even when autoload globals are not injected (editor / `--check-only`). Runtime singleton is unchanged.

### Files

| Path | Role |
|------|------|
| `scripts/autoload/SaveManager.gd` | Profile index, JSON I/O, S-key, toasts, load+position restore |
| `scenes/ui/MainMenu.tscn` + `MainMenu.gd` | Ornate panel + hotspots |
| `scenes/ui/ProfileCreate.tscn` + `.gd` | New profile name / overwrite |
| `scenes/ui/ProfileLoad.tscn` + `.gd` | Profile list |
| `scripts/tools/verify_save_system.gd` | Headless smoke verify |

### Verify

`scripts/tools/verify_save_system.gd` → `VERIFY_SAVE: PASS`

### Known limitations

- World Map has no player node — position restore skipped there.
- Mid-quiz state is not saved (checkpoint = completed floor / MG SUCCESSFUL).
- Empty load list shows “No saved profiles found.” (no crash).

---

## 2026-09-20 — Ambient characters + Supervisor context

**Guide:** `Docs/AMBIENT_CHARACTERS.md`  
**Verify:** `scripts/tools/verify_ambient_characters.gd`

### Identification method

Per floor scene tree: Player ignored; assessment NPC (Manager / Director / named assessor) = **Supervisor**; remaining human/character Sprite2D or NPC instances = **ambient**. Decorative overlays (child sprites on assessors/workers, `PlayerBackview`, `TeacherIdle`, Farah’s `LabAssistant1`) ignored.

### Behavior

- `AmbientProximity.gd` (Area2D) auto-triggers on player enter; random line from `AmbientDialoguePools.gd`; re-arms on leave/re-enter.
- Reuses existing `DialoguePanel.show_line` — no second dialogue system.
- NPC ambients: `enable_collision = true` (existing CharacterBody2D shapes).
- Sprite ambients: scene-authored `BodyCollision` StaticBody2D + CollisionShape2D (layer 4).
- Player `collision_mask` includes layer 4 so character bodies block movement.
- Zone 01 Manager `display_name` / dialogue speaker → **Supervisor** (assessment InteractionArea unchanged).
- School Teacher: additive line about floor Supervisors (`TEACHER_LINE_SUPERVISOR`).

### Explicit

**EXISTING FLOOR GAMEPLAY FLOWS WERE NOT CHANGED.**  
**SUPERVISOR ASSESSMENT FLOW WAS NOT CHANGED.**

### Future upgrades (do not regress)

- New floors/zones: follow `Docs/AMBIENT_CHARACTERS.md` identification + inject rules; extend verifier paths.
- Expand dialogue pools only in `AmbientDialoguePools.gd` (never quiz banks).
- Keep Supervisor assessment separate from ambient proximity.
- Real mini-games must not reuse ambient triggers for MG start.

---

## 2026-09-20 — Floor 4 → mini-game SUCCESSFUL → World Map unlock

### Unlock rule

`zoneN_floor4_passed` AND `zoneN_minigame_successful` → unlock next zone (via `GameState.sync_world_map_unlocks()`).

Floor 4 quiz alone never unlocks the next zone.

### Per zone

| Zone | After F4 quiz | PLAY | SUCCESSFUL unlocks |
|------|---------------|------|--------------------|
| 01 | MiniGameHandoff + DemoCompleteUI | PLAY MINI-GAME 1 | Zone 02 |
| 02 | MiniGameArea + DemoCompleteUI | PLAY MINI-GAME 1 | Zone 03 |
| 03 | existing MiniGameArea (1 PLAY only) | PLAY MINI-GAME 1 | Zone 04 |
| 04 | existing MiniGameArea (1 PLAY) | PLAY MINI-GAME 1 | Zone 05 (map only; “coming soon”) |

After SUCCESSFUL: **RETURN TO THE WORLD MAP** → `WorldMap.tscn`.

### GameState flags added

`zone01_minigame_successful` … `zone04_minigame_successful`  
`mark_minigame_successful(zone_id)` sets MG flag + `*_complete` (compat) and syncs unlocks.  
No fake badge awards.

### Middle floors

**MIDDLE FLOOR FLOWS WERE NOT CHANGED.**

---

## 2026-09-20 — Zone 04 Exterior guide NPC (Volt)

- Added exterior guide **Volt** (`volt.png`) at `NPCs/Guide`
- Auto proximity dialogue only — instructs player to enter Door 1 manually
- Does not start quiz, open Door 1, or teleport
- Floors 1–4 / banks / door unlock logic unchanged

---

## 2026-09-20 — Zone 04 The Substation (4-floor assessments + MG placeholders)

### Flow

```
World Map → Zone04 Exterior
→ Door1 → Floor1 Professor Mira → Exterior (Door2 unlock)
→ Door2 → Floor2 Echo → Exterior (Door3 unlock)
→ Door3 → Floor3 Professor Nadia → Exterior (Door4 unlock)
→ Door4 → Floor4 Engineer Farid → Mini-Game PLAY placeholder (“coming soon”)
```

### Cast (authoritative)

| Floor | Character | Asset |
|-------|-----------|-------|
| 1 | Professor Mira | `asset/sprites/character/zone 4/Professor_Mira.png` |
| 2 | Echo | `asset/sprites/character/zone 4/Echo.png` |
| 3 | Professor Nadia | `asset/sprites/character/zone 4/Professor_Nadia.png` |
| 4 | Engineer Farid | `asset/sprites/character/zone 4/Engineer_Farid.png` |

### Env mapping (4-floor; bay5/capstone unused)

| Scene | Art |
|-------|-----|
| Exterior | `substation_entry.png` |
| Floor 1 | `substation_bay1_fundamentals.png` |
| Floor 2 | `substation_bay2_circuits.png` |
| Floor 3 | `substation_bay3_ohmslaw.png` |
| Floor 4 | `substation_bay4_diagnostics.png` |

### GameState

`zone04_floor1_passed` … `zone04_floor4_passed`, `zone04_exterior_spawn_marker`.  
Existing `zone04_complete` / `zone04_badge_earned` remain unset by this phase.

### Notes

- Old dialogue doc still uses Asha/Imran/…/5-floor — **not used**. Minimal placeholder dialogue for Mira/Echo/Nadia/Farid.
- No exterior guide NPC (no dedicated guide asset).
- World Map unlocked click → `Zone04_Exterior.tscn`.

---

## 2026-09-20 — Zone 03 progression correction (Door 4 + Milon + placeholders)

> **Superseded (MG gate):** Floor4 mini-game is now real **Fiber Escape** (2026-09-21). Door/Milon/Floor3 exterior return notes below remain valid.

### Flow

Exterior (Milon) → Door1/F1 → Exterior (Door2) → Door2/F2 → Exterior (Door3) → Door3/F3 → Exterior (Door4) → Door4/F4 Anwar → Mini-Game **PLAY placeholders** (“coming soon”). *(MG placeholder superseded.)*

### Key changes

- Floor 3: **no** “Continue to Floor 4”; returns via ExteriorExit
- Door 4: unlocks on `zone03_floor3_passed` (monotonic)
- Guide: Milon (`char_milon_idle.png`)
- Floor 4 PLAY buttons do **not** set badge/complete/Zone 04 unlock

---

## 2026-09-20 — Zone 03 completion → World Map → Zone 04 unlock

> **Superseded (unlock flags):** Current unlock is `zone03_floor4_passed AND zone03_minigame_successful` via `mark_minigame_successful(ZONE_03)` after Fiber Escape Stage 2. Badge art name remains **Spectrum Crest**.

### Flow

Anwar quiz → MiniGameArea Complete → `zone03_badge_earned` + `zone03_complete` → **RETURN TO THE WORLD MAP** → World Map with Zone 04 full-color / unlocked click (coming soon). *(Historical demo path.)*

### Files modified

- `scripts/zone03/Zone03Floor4.gd` — return button + unlock sync
- `scenes/zone03/Zone03_Floor4.tscn` — `ReturnToWorldMapButton` (no layout moves of existing nodes)
- `scripts/world_map/WorldMap.gd` — modulate unlock from GameState; Z02/Z03 entry; Z04 coming soon
- `scripts/autoload/GameState.gd` — `sync_world_map_unlocks()`, badge/complete flags for Z01/Z02/Z04 architecture
- `scripts/tools/verify_world_map_progression.gd` (new)
- docs

### Unlock gate

`zone03_complete && zone03_badge_earned` → `ZONE_04` unlocked (modulate white, `is_locked=false`). Persistent via GameState.  
*(Historical.) **Current:** `zone03_floor4_passed && zone03_minigame_successful`.*

---

## 2026-09-20 — Zone 03 Signal Station (assessments + demo completion)

> **Superseded (mini-game):** Temporary demo replaced by Fiber Escape (2026-09-21). Assessment banks / floors / exterior notes below remain the foundation.

### Question banks (inspected)

| Bank | Count | Formats | Bloom |
|------|-------|---------|-------|
| floor1 | 50 | MCQ 50 | remember, understand |
| floor2 | 50 | MCQ 50 | understand, apply |
| floor3 | 50 | MCQ 40 + one_word 10 | apply, analyze |
| floor4 | 50 | MCQ 40 + one_word 10 | analyze, evaluate |

### Created

- `scenes/zone03/Zone03_Exterior.tscn` + `scripts/zone03/Zone03Exterior.gd`
- `scenes/zone03/Zone03_Floor1.tscn` + `Zone03Floor1.gd` (Farid)
- `scenes/zone03/Zone03_Floor2.tscn` + `Zone03Floor2.gd` (Shirin)
- `scenes/zone03/Zone03_Floor3.tscn` + `Zone03Floor3.gd` (Tania → Floor4)
- `scenes/zone03/Zone03_Floor4.tscn` + `Zone03Floor4.gd` (Anwar + MiniGameArea demo)
- `data/zone03_floor1..4_questions.json`
- `scenes/minigames/zone03/`, `scripts/minigames/zone03/` (folder placeholders)
- `scripts/tools/verify_zone03_exterior.gd`, `verify_zone03_floors.gd`

### Modified (additive only)

- `GameState.gd` — zone03_* flags
- `QuizController.gd` — `load_zone03_floor*_bank()`

### Mini-game

**TEMPORARY DEMO COMPLETION FLOW** only: MiniGameArea Area2D → demo UI → Complete → Spectrum Crest badge. No real mini-game.  
*(Superseded 2026-09-21 by Fiber Escape — see Completed entry above.)*

### Verification

`verify_zone03_exterior.gd` + `verify_zone03_floors.gd` + Zone 02 regression verify.

---

## 2026-09-20 — Zone 02 Floor 4 Director final assessment

### Intent

Final Zone 02 assessment: Floor3 Continue → Floor4 → Director → 10Q / 80% → `zone02_floor4_passed` + `zone02_complete`. No Exterior return. No mini-games.

### Files created

- `scenes/zone02/Zone02_Floor4.tscn`
- `scripts/zone02/Zone02Floor4.gd`
- `data/zone02_floor4_questions.json` (from `Docs/questions/zone 2/…`)
- `scripts/tools/verify_zone02_floor4_quiz.gd`

### Files modified

- `scripts/quiz/QuizController.gd` — `load_zone02_floor4_bank()`
- `scripts/autoload/GameState.gd` — `zone02_floor4_passed`, `zone02_complete`
- `scripts/zone02/Zone02Exterior.gd` — door unlock includes Floor4/complete flags (monotonic)
- Floor3/Exterior verifiers + docs
- Floor3 script comment only (no layout change)

### Cast / bank / completion

- Director: `director 1.png` · Room: `energy_control_room.png`
- Bank: mixed MCQ + one_word (50); session 10 / 80% / retry fresh
- Continue label: “Complete Zone 02” → Director completion dialogue + prompt
- No ExteriorExit, no Door 4, no mini-game, no Zone 03

### Verification

Floor4 + Exterior + Floor2 + Floor3 → 0 failures.

---

## 2026-09-20 — Zone 02 Floor 3 + door unlock persistence

### Part A — Door persistence fix

Unlocked doors never re-lock. `_apply_door_lock_state()` is monotonic:
- Door2 unlocked if floor1 **or** floor2 **or** floor3 passed
- Door3 unlocked if floor2 **or** floor3 passed

File: `scripts/zone02/Zone02Exterior.gd` only (logic; no Door transforms changed).

### Part B — Floor 3 assessment

- `scenes/zone02/Zone02_Floor3.tscn`
- `scripts/zone02/Zone02Floor3.gd`
- `data/zone02_floor3_questions.json` (from `Docs/questions/zone 2/…`)
- `scripts/tools/verify_zone02_floor3_quiz.gd`
- Karim (`karim.png`), room `energy_quiz_room_3.png`
- Bank: mixed MCQ + one_word; 10Q / 80%; retry fresh
- `zone02_floor3_passed` on Continue only
- Continue → Floor 4 path (Floor4 scene not created yet — safe prompt)
- Pass Continue does **not** return to Exterior
- Door3 → Floor3; `Floor3ReturnSpawn` for voluntary ExteriorExit only

### Verification

Exterior / Floor2 / Floor3 verifiers → 0 failures.

---

## 2026-09-20 — Zone 02 Floor 2 assessment

### Intent

Floor 2 mirrors Floor 1: Farah InteractionArea → dialogue → 10Q / 80% → `zone02_floor2_passed` → Exterior; Door 3 unlocks.

### Files created

- `scenes/zone02/Zone02_Floor2.tscn`
- `scripts/zone02/Zone02Floor2.gd`
- `data/zone02_floor2_questions.json` (copy of `Docs/questions/zone 2/zone02_floor2_questions.json`)
- `scripts/tools/verify_zone02_floor2_quiz.gd`

### Files modified

- `scripts/quiz/QuizController.gd` — `load_zone02_floor2_bank()`
- `scripts/autoload/GameState.gd` — `zone02_floor2_passed`
- `scripts/zone02/Zone02Exterior.gd` — Door2 → Floor2; Door3 unlock; guide lines
- `scenes/zone02/Zone02_Exterior.tscn` — `Floor2ReturnSpawn`
- `scripts/tools/verify_zone02_exterior.gd`
- `Docs/PROGRESS.md`, `Docs/SCENE_IMPLEMENTATION.md`

### Cast / bank

- Farah: `res://asset/sprites/character/farah.png` (sole assessment NPC; no supporting NPC)
- Room: `energy_quiz_room_2.png`
- Bank: `res://data/zone02_floor2_questions.json` (50 MCQ, understand/apply)
- Exactly 10 unique / attempt; 80% pass; TRY AGAIN fresh session
- Flag set only on QuizPanel CONTINUE after pass

### Verification

`verify_zone02_floor2_quiz.gd` → 0 failures.

---

## 2026-09-20 — Zone 02 Floor 1 cast: Nabila (surgical)

Replaced Manager (`manager 1 fornt.png`) with **Nabila** (`nabila.png`). Quiz/GameState/Door2 flow unchanged. Verifier updated for `NPCs/Nabila`.

---

## 2026-09-20 — Zone 02 Floor 1 assessment

### Intent

Playable Floor 1 assessment using Zone 01 Floor 1 architecture: Manager InteractionArea → dialogue → 10Q / 80% → `zone02_floor1_passed` → Exterior; Door 2 unlocks.

### Files created

- `scenes/zone02/Zone02_Floor1.tscn`
- `scripts/zone02/Zone02Floor1.gd`
- `data/zone02_floor1_questions.json` (copy of `Docs/questions/zone 2/zone02_floor1_questions.json`)
- `scripts/tools/verify_zone02_floor1_quiz.gd`

### Files modified

- `scripts/quiz/QuizController.gd` — `load_zone02_floor1_bank()`
- `scripts/autoload/GameState.gd` — `zone02_floor1_passed`, `zone02_exterior_spawn_marker`
- `scripts/zone02/Zone02Exterior.gd` — Door2 unlock + Floor1ReturnSpawn placement
- `scenes/zone02/Zone02_Exterior.tscn` — `Floor1ReturnSpawn` marker
- `scripts/tools/verify_zone02_exterior.gd`
- `Docs/PROGRESS.md`, `Docs/SCENE_IMPLEMENTATION.md`

### Bank / quiz

- Path: `res://data/zone02_floor1_questions.json` (50 MCQ, remember/understand)
- Exactly 10 unique / attempt; 80% pass; TRY AGAIN fresh session
- Flag set only on QuizPanel CONTINUE after pass

### Verification

`verify_zone02_floor1_quiz.gd` + updated exterior verify.

---

## 2026-09-20 — Zone 02 Phase 1 Exterior foundation

### Intent

Stand up Energy Assessment Wing exterior using Zone 01 Exterior interaction patterns (InteractionArea guide + Interactable doors). No floors or World Map unlock this phase.

### Files created

- `scenes/zone02/Zone02_Exterior.tscn`
- `scripts/zone02/Zone02Exterior.gd`
- `scripts/tools/verify_zone02_exterior.gd`

### Files modified

- `Docs/PROGRESS.md`
- `Docs/SCENE_IMPLEMENTATION.md`

### Behavior

- Background: `energy_assessment_wing.png`
- Guide (Rina): NPC + InteractionArea auto dialogue (no E/F)
- Door1: available; transitions to `Zone02_Floor1.tscn` only if that scene exists (otherwise prompt)
- Door2 / Door3: locked feedback; locked door art on Door2/3
- Ambient: one non-interactive worker
- No quiz / MG / GameState floor flags

### Verification

`verify_zone02_exterior.gd` → 0 failures (architecture only)

### Manual editor tuning required

Door positions, Guide/Worker positions/scales, InteractionArea sizes, collision blocks, Camera2D position/zoom.

---

## 2026-09-19 — Phase 11B World Map click-only

### Intent

Fix null Player/PlayerSpawn errors by removing walking-map dependency. Map is a static click selector.

### Files created

- `scripts/world_map/MapClickTarget.gd`

### Files modified

- `scripts/world_map/WorldMap.gd` — no Player references; click → transition / locked feedback
- `scenes/world_map/WorldMap.tscn` — removed Player/PlayerSpawn/walking collision; ClickArea per landmark
- `scripts/tools/verify_world_map.gd`
- `scripts/tools/verify_world_map_flow.gd`
- `Docs/PROGRESS.md`, `Docs/SCENE_IMPLEMENTATION.md`

### Behavior

- Factory ClickArea (unlocked) → `Zone01_Exterior.tscn` via SceneTransition
- Locked landmarks → PromptLabel: "Locked — this area is not available yet."
- Click shapes scene-authored (editable CollisionShape2D)

## 2026-09-19 — Phase 11A Floor 1 Assessment

(See prior entry.) Manager → 10Q quiz → 80% → `zone01_floor1_passed` → Floor 2 gate.

---

# Currently Working On

Nothing — Phase 11B stopped.

---

# Not Yet Implemented

- Floor 2–4 quizzes / Director / MG1
- Production: turn off Floor 1 quiz demo mode
- Real mouse-click visual QA on World Map

---

# Known Issues

- Click-area sizes may need editor eye-tuning vs landmark art
- Actual mouse-click in-game: **NOT TESTED** (headless simulates `select_zone01` / locked handler)

---

# Verification / Testing

| Test | Result |
|------|--------|
| `verify_world_map.gd` | **PASS** |
| `verify_world_map_flow.gd` | **PASS** |
| `verify_zone01_exterior_flow.gd` | **PASS** |
| `verify_zone01_floor1_quiz.gd` | **PASS** (regression) |
| `verify_foundation.gd` | **PASS** |
| Real mouse click on Factory | **NOT TESTED** |

---

# Next Task

Await instruction (Floor 2 quiz, demo-mode off, or visual click tuning).
