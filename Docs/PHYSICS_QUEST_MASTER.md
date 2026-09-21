# PHYSICS QUEST — MASTER PROJECT DOCUMENT

**Document type:** Single source of truth for developers, artists, and AI agents  
**Project root:** `C:\Users\Mufrid Johanee\Desktop\capstone\final\`  
**Godot project:** `final-godot/`  
**Assets:** `asset/` (linked into Godot as `res://asset/`)  
**Last inventory date:** 2026-09-16 (legacy path notes below). **This rebuild root:** `d:\capstone 2`. Ambient/Supervisor floor system: `Docs/AMBIENT_CHARACTERS.md` (2026-09-20). **Profile save/load (authoritative for this rebuild):** `Docs/PROGRESS.md` + `Docs/SCENE_IMPLEMENTATION.md` — `SaveManager` autoload, `user://profiles/`, Main Menu New/Load, in-game **S** after checkpoint (supersedes legacy `user://savegame.json` / GameManager / F5 notes elsewhere in this file).  
**Mini-games / badges (authoritative for this rebuild, 2026-09-21):** `Docs/MINIGAME_IMPLEMENTATION.md` + `Docs/MASTER_GAME_SPEC.md` — Zone 01 **Emergency Brake** (real), Zone 03 **Fiber Escape** (real), Zones 02/04 PLAY→SUCCESSFUL placeholders. Canonical badges: **Momentum Crest** / **Radiant Crest** / **Spectrum Crest** / **Spark Emblem**. Unlock = `floor4_passed AND minigame_successful`. Older sections in this master that describe five Zone01 MGs, `MiniGameBase`, or missing Spectrum Crest PNG describe the **legacy** tree or outdated asset notes — prefer the living docs above.  
**Living status file:** `Docs/PROGRESS.md` (code / scene / on-disk asset / verify **only**)  
**Standing rule:** Update **this file** after any decision, chat spec, asset list, poster copy, or implementation. Update `docs/PROGRESS.md` **only** after code, scenes, files on disk, or verify runs. Chat-only replies do not edit PROGRESS. Do not leave the master describing an older Godot **or** an older agreed spec.

---

## Table of contents

1. Project overview  
2. Complete game structure  
3. Currently confirmed scenes  
4. Asset directory inventory  
5. Complete factory zone roadmap  
6. Factory asset master checklist  
7. Mini-game asset breakdown  
8. Other zones  
9. Zone status table  
10. Asset acquisition strategy  
11. Nano Banana generation standard  
12. Nano Banana prompt system (§12.5–12.8 Zone 02–04 catalogs)  
13. Reference image rules  
14. File naming convention  
15. Asset cleanup pipeline  
16. Godot folder structure  
17. Audio asset plan  
18. UI master plan  
19. Current state summary  
20. Roadmap and dependencies  
21. Priority system  
22. Unknown / decision required  
23. PROGRESS.md rule  
24. AI developer rules  
25. Quick start for a new AI  
26. Evidence sources and how to use them  
27. Screenshot / visual confirmation notes  
28. Godot systems architecture  
29. Question-bank inventory  
30. Duplicate-file and import hygiene  
31. Gameplay-critical vs decorative assets  
32. Full factory scene script (docs vs Godot)  
33. Full mini-game design specs (authoritative GDD text)  
34. Complete Nano Banana prompt catalog  
35. Zone 02–05 documented designs (Map B — superseded for 02–04 gameplay)  
36. UI component master list  
37. Audio requirement matrices  
38. Character pose and animation matrix  
39. Godot import and sprite-scale rules  
40. Photopea cleanup procedure (step-by-step)  
41. What to implement next (recipes, not inventions)  
42. Scientist / flash-card battle (side concept only)  
43. Zone 02 Assessment Wing + “Build the System” (**canonical**; implemented in Godot 2026-08-18)  
44. Zone 05 Godot scaffold + Zone 02 history (Zone 02 scaffold replaced with §43)  
45. Zone 03 Signal Station (**canonical**, implemented: decks, quizzes, Spectrum Crest, mini-games)  
46. Zone 04 The Substation (**canonical**, implemented: five bays, Spark Emblem, Build the Generator)  
47. Capstone project poster (extended layout + copy; chat 2026-08-18)  
48. Zone 01 mini-game implementation spec (architecture / JSON / asset pipeline — **PLANNED polish**; see also `docs/zone01_minigame_implementation_spec.md`)

---

## How to read this document

Evidence is labeled. Do not upgrade a label without new proof.

| Label | Meaning |
|---|---|
| **CONFIRMED EXISTING** | File or scene exists on disk in this repo |
| **CONFIRMED IN DOCUMENTATION** | Specified in GDD / proposal / chat dumps, not necessarily built |
| **VISIBLE IN GAMEPLAY** | Implemented and reachable in the Godot project |
| **DOWNLOADED / AVAILABLE** | File exists under `asset/`; may be unused, duplicated, or unclean |
| **GENERATED BUT NEEDS CLEANUP** | AI/export file present; white bg, JPG, typo name, or not wired |
| **PLANNED** | Intended; design exists at some level |
| **MISSING** | Required for a documented feature; no usable file found |
| **NOT YET DESIGNED** | Mentioned as a zone/idea only; no floor-by-floor spec |
| **UNKNOWN / REQUIRES DECISION** | Contradictory or unspecified; **do not invent** |

**Hard rules**

1. A filename in a design doc does **not** mean the asset is in Godot.
2. A PNG on disk does **not** mean it is used in a scene.
3. A placeholder `.tscn` does **not** mean the minigame is playable. Zone 01 MG1–5 and Zone 02 MG3 **are** real physics UI (not ColorRect Next-buttons). Zone 05 Hub/Floors remain placeholders.
4. Zone **05** still has **placeholder Hub/Floor/Capstone scenes**. Zone **02** is Map C Assessment Wing in Godot (rooms + Build the System). Zones **03 and 04** are implemented gameplay loops. Energy Mini-Games 1–2 (sort / diagnose) remain **NOT YET DESIGNED**. Do not invent them.

---

# 1. PROJECT OVERVIEW

## 1.1 What Physics Quest is

**Physics Quest** is a **2.5D top-down educational RPG** in which a secondary-school student must prove they can *apply* physics, not only recall formulas.

The player begins in a **classroom**, receives an assignment from a teacher, then travels through **themed industrial / scientific sites**. At each site they face **dialogue, quizzes (typically ≥80%), and later hands-on challenges**. Completing a zone awards a **badge** and unlocks the next site on a **world map**.

**CONFIRMED EXISTING engine:** Godot **4.7.1**, **GDScript**, project name `Physics Quest`.  
**CONFIRMED IN DOCUMENTATION (proposal):** Godot 4 + **C#**.  
**UNKNOWN / REQUIRES DECISION:** The capstone PDF listed C#. The running project is **GDScript**. Treat GDScript as the implemented stack unless the team explicitly migrates.

## 1.2 Core fantasy

The protagonist is a **back-bencher** who ignored class. The teacher gives limited time to complete physics assignments by visiting **real-world-flavored locations**, talking to experts (managers / director / later scientists), passing assessments, and solving factory emergencies.

Opening beat **CONFIRMED IN DOCUMENTATION** and **VISIBLE IN GAMEPLAY** (School cutscene):

- Teacher: *Welcome to Physics Quest! You need to secure at least 80% marks in your assignments to pass.*
- Teacher (additive, this rebuild): *Each floor of the factory has a Supervisor. They may ask you different questions and guide you as you explore.*
- Student: *Understood, Sir! I will do my best.*
- Student stands, walks to the classroom door, fade to World Map.

**This rebuild (`d:\capstone 2`):** Floor assessment NPCs are treated as **Supervisors**; other character sprites use ambient proximity dialogue. Upgrade guide: `Docs/AMBIENT_CHARACTERS.md`. Living status: `Docs/PROGRESS.md`.

## 1.3 Educational objective

**CONFIRMED IN DOCUMENTATION**

- Contextual physics (Bangladesh Class 9–10 syllabus appears in Zone 02–05 GDD).
- Assessment via quizzes and interactive challenges.
- Difficulty climbs with **Bloom’s Taxonomy**: Remember → Understand → Apply → Analyze → Evaluate/Create.
- Formal evaluation ideas in the proposal: pre/post test, SUS, Hake’s gain. **NOT implemented in code.**

**VISIBLE IN GAMEPLAY today:** Pass **≥ 80%** on JSON banks. Zone 01: 5 MCQ × 4 floors. Zone 02 Map C: 15 / 15 mixed / 15 mixed. Zone 03: 15/15/15/20 mixed. Zone 04: 10/15/15/15/20 mixed. Zone 05 scaffold: 5 MCQ placeholders. None of these are the proposal’s 50-questions-per-floor bank.

## 1.4 Intended technology stack

| Tool | Role | Status |
|---|---|---|
| Godot 4.7 | Engine | CONFIRMED EXISTING |
| GDScript | Game code | CONFIRMED EXISTING |
| C# | Listed in proposal | CONFIRMED IN DOCUMENTATION only |
| JSON question bank | Quizzes | CONFIRMED EXISTING (Zone 01: 5 Qs × 4 floors; Zone 02 rooms 1–3 Map C banks; Zone 03 rooms 1–4; Zone 04 rooms 1–5; Zone 05: 5 Qs × 4 floors + capstone **placeholders**) |
| Pixel art + sprite sheets | Characters / rooms | CONFIRMED EXISTING (partial) |
| Nano Banana / Gemini image gen | Custom assets | CONFIRMED IN DOCUMENTATION (workflow) |
| Photopea | BG remove, crop, PNG | CONFIRMED IN DOCUMENTATION |
| Piskel / Krita / Blender | Optional pixel / 3D | CONFIRMED IN DOCUMENTATION; unused in repo |

## 1.5 Art direction (working)

**CONFIRMED IN DOCUMENTATION (mixed):**

- Original GDD / chat: **2.5D** top-down RPG, Pokémon Emerald–inspired pixel art.
- Zone 02 GDD: **2D** pixel, 1px dark outline, 2-tone cel, warm afternoon palette.

**VISIBLE IN GAMEPLAY:** Top-down classroom and factory floor paintings; character sheets are top-down / 3/4 views with pose labels.

**UNKNOWN / REQUIRES DECISION:** Officially “2.5D” vs “2D locked.” Do not regenerate the whole game’s art until this is decided. Match **existing classroom / factory floor / player sheet** when adding Zone 01 assets.

Primary factory **style reference** on disk:

- `asset/sprites/Environment/factory_asset_reference.png`  
  (**DOWNLOADED / AVAILABLE**; docs also call it `physics_quest_factory_asset_reference.png` — **filename mismatch**, see §22.)

---

# 2. COMPLETE GAME STRUCTURE

## 2.1 Zone maps (Zones 02–04 locked)

**DECIDED 2026-08-18 (user — same rule as Zone 02: lock the most detailed spec):**

| Zone | Canonical content | Spec | In Godot? |
|---|---|---|---|
| 02 | **Map C** Assessment Wing + Radiant Crest | this file **§43** | **Yes** — Entry, Rooms 1–3, Control Room, Build the System (MG1–2 undesigned, skipped) |
| 03 | **Signal Station** + Spectrum Crest | this file **§45** | **Yes** — Entry–MG2 |
| 04 | **The Substation** + Spark Emblem | this file **§46** | **Yes** — Entry–MG1 |

**Why these (most detailed):** Zone 02 Map C is the longest authored script (four NPCs, quiz mix, Create-MG). Zones 03–04 already have full implemented loops (named casts, 80% decks, mini-games, badges) in Godot + §45–§46. Map A is names only. Map B Zone 03–04 pages are **skeletons** (Matter Labs / Wave Observatory) — thinner than what shipped. Do **not** replace Signal Station or The Substation with those skeletons.

Do **not** merge Map B Loading Dock / Drop Tower / Machine Shop into Zone 02 stations 1–2. Energy Mini-Games 1–2 stay **NOT YET DESIGNED**. Do **not** build Matter Labs, Research Lab / Flux Badge, Wave Observatory, or Observatory / Lens Token as Zones 03–04.

Godot World Map: Zone 02 pin **Energy Refinery** → `Zone02_Entry.tscn`. Zone 03 pin **Signal Station**. Zone 04 pin **The Substation**.

**Map A — original chat / this roadmap prompt (SUPERSEDED for Zones 02–04; historical):**

| Zone | Location | Discipline | Badge |
|---|---|---|---|
| 01 | Factory | Mechanics | Momentum Crest |
| 02 | Power Plant | Electricity | Spark Emblem |
| 03 | Research Lab | Magnetism | Flux Badge |
| 04 | Observatory | Optics | Lens Token |
| 05 | Industrial Facility | Thermodynamics | Heat Sigil |

**Map B — `docs/physics_quest_zones_02-05_gdd (2).md` (SUPERSEDED for Zones 02–04 gameplay; Zone 02 Hub + Control Room **art language** may still be used):**

| Zone | Location | Curriculum | Notes |
|---|---|---|---|
| 01 | Mechanics Factory | Measurement, Motion, Force | “locked, built” in that doc |
| 02 | Energy Refinery | Work, Power, Energy, Simple Machines | Full floor design + Foreman Rina |
| 03 | Matter Labs | Matter, Pressure, Density, Buoyancy | Skeleton |
| 04 | Wave Observatory | Heat, Waves, Sound | Skeleton |
| 05 | Light & Circuits Citadel | Optics, Electricity, Magnetism | Skeleton; possible 05a/05b split |

**Map C — Assessment Wing + three stations (CANONICAL Zone 02 content, 2026-08-17 script in §43; in Godot 2026-08-18 except Energy MG1–2):**

| Zone | Location | Curriculum | Badge in this script | Structure |
|---|---|---|---|---|
| 02 | Energy zone / refinery lab (Hub + Assessment Wing + Control Room) | Work, Power, Energy, Conservation, Simple Machines, MA, VR, Efficiency | **Radiant Crest** | 3 locked quiz rooms (Nabila / Karim / Farah) then 3 mini-game stations; only station 3 is fully designed |

Map C NPCs: Foreman **Rina**, Assistant **Nabila** (Room 1), Assistant **Karim** (Room 2), Assistant **Farah** (Room 3). Pass **80%** per room; fail = retake, door stays shut. After three quizzes, Rina sends the player to three stations (sort / diagnose / **build**). Station 3 = “Build the System” (Create tier). Stations 1–2 are **named in dialogue only** — **NOT YET DESIGNED**.

**On disk (DOWNLOADED / AVAILABLE, not wired as zones):**

- `powerplant_select.jpg`
- `researchlab_select.jpg`
- `world_map_background.png` (leftover; live map is `Environment/map.png`)
- No observatory or thermodynamics environment files found

**DECIDED (2026-08-18):** Zone 02 = **Map C** (§43, **in Godot**: Assessment Wing + Build the System). Zone 03 = **Signal Station** (§45, in Godot). Zone 04 = **The Substation** (§46, in Godot). Zone 02 badge = **Radiant Crest**. Zone 03 badge = **Spectrum Crest**. Zone 04 badge = **Spark Emblem**. `powerplant_select.jpg` / `researchlab_select.jpg` remain unused map-select JPGs — not a vote to build Power Plant or Matter Labs.

## 2.2 Master zone table

| Zone | Location | Discipline | Badge | Scene status | Evidence | Major gameplay | Asset status |
|---|---|---|---|---|---|---|---|
| 01 | Factory | Mechanics | Momentum Crest | **Playable** | School → Map → Exterior (Guard/gate) → F1–F4 → MG1–5 | Dialogue, 80% MCQ, real emergency run | Guard/managers/Director sprites; MG art wired |
| 02 | **Energy Refinery / Assessment Wing** (canonical Map C) | Work, Power, Energy, Simple Machines | **Radiant Crest** | **Production Ready / Implemented** (art + collision + proctors + crest UI) | `scenes/Zone02/` Entry–MG3 | 80% rooms + Build the System | Energy MG1–2 undesigned; Hub ColorRect; Floor4 scaffold unused |
| 03 | **Signal Station** (canonical) | Waves, Sound, Optics | **Spectrum Crest** | **Production Ready / Implemented** (paintings + full cast idles) | `scenes/Zone03/` Entry–MG2 | 80% decks + 2 mini-games | — |
| 04 | **The Substation** (canonical) | Electricity, Magnetism | **Spark Emblem** | **Production Ready / Implemented** (paintings + generator parts sheet) | `scenes/Zone04/` Entry–MG1 | 80% five bays + generator MG | Zone 04 NPC sheets **MISSING** |
| 05 | Industrial Facility *or* Light Citadel (**not locked**) | Thermo *or* Optics+E&M | Heat Sigil *or* unspecified | **Scaffold playable** | `scenes/Zone05/*.tscn` | Placeholder quizzes | **MISSING** env art |

## 2.3 Intended player journey (Zone 01)

**CONFIRMED IN DOCUMENTATION** (scene script in `docs/capstone,md.txt`):

1. School classroom assignment (black cutout / fade).
2. Appear in front of school, **walk to factory** with **road signs**, **player-controlled**.
3. **Guard** greets (they expected the student; assignment not turned in), **steps left**, door revealed.
4. Enter factory (fade).
5. Floors 1–3: manager blocks stairs until **80%** quiz.
6. Floor 4: Director quiz ≥80% → emergency phone cutscene → **five minigames in one run** (any GAME OVER → restart MG1).
7. Award **Momentum Crest**, unlock Zone 02 on world map.

**VISIBLE IN GAMEPLAY vs that script:**

| Beat | In Godot now? |
|---|---|
| School dialogue + walk to door + fade | Yes (automated cutscene, not free-walk from schoolyard) |
| Overworld walk school → factory with signs | **No** (World Map substitutes) |
| Guard sprite + talk + step-aside | **Yes** (`guard_shee (1).png` + E-talk; tween left; chroma-key) |
| Exterior uses true outdoor painting | **Yes** — `factory_exterior (1).png` (cutaway `factory.png` no longer the exterior BG) |
| Floors 1–4 quiz gating | Yes |
| Manager / Director sprites | **Yes** (idle crop from JPG sheets; still need Photopea) |
| Director emergency cutscene | **Yes** (post-pass dialogue lines, then MG1) |
| Real 5 minigames + fail-to-MG1 | **Yes** (documented numbers; GAME OVER reloads MG1) |
| Badge award + Zone 02 unlock | **Yes** (MG5 awards `momentum_crest` + unlocks Zone 02 pin). No Hall/badge ceremony UI. |

---

# 3. CURRENTLY CONFIRMED SCENES (GODOT)

Playable chain **VISIBLE IN GAMEPLAY**:

```
School.tscn
  → WorldMap.tscn
    → Zone01_Exterior.tscn
      → Zone01_Floor1.tscn
        → Floor2 → Floor3 → Floor4
          → MiniGame01_Brake.tscn (real MG; fail → MG1)
            → MG2 → MG3 → MG4 → MG5 → WorldMap.tscn
              (MG5 Engage awards Momentum Crest + unlocks Zone 02)
    → Zone02_Entry.tscn (locked until Zone 01 clear)
      → Rooms 1–3 (80%) → Control Room verdict
        → MiniGame3 Build the System → Radiant Crest + unlock Zone 03
    → Zone03_Entry.tscn (locked until Zone 02 clear)
      → Floor1–4 (80% decks) → Capstone verdict
        → MiniGame1 Signal Path → MiniGame2 Optical System
          → Spectrum Crest + unlock Zone 04 → WorldMap
    → Zone04_Entry.tscn (locked until Zone 03 clear)
      → Floor1–5 (80% bays) → Capstone verdict
        → MiniGame1 Build the Generator
          → Spark Emblem + unlock Zone 05 → WorldMap
    → Zone05 still Hub→Floors→Capstone scaffold
```

Main launch scene: **`res://scenes/School/School.tscn`** (`project.godot`).

### 3.1 School / Opening — VISIBLE IN GAMEPLAY

**Scene:** `final-godot/scenes/School/School.tscn`  
**Script:** `scripts/SchoolScene.gd`

| Element | Status |
|---|---|
| Classroom background `classroom.png` | Used, full-viewport TextureRect (cover); painted desks/chairs (no desk nodes) |
| Teacher `teacher_idle.png` | Used; runtime scale `TEACHER_SPRITE_SCALE = 0.18` |
| Teacher position | Runtime `_classroom_point(TEACHER_NORM)`; `TEACHER_NORM = (0.60, 0.33)` — **right/front of teacher desk** (not behind); z=5 |
| Student AtlasTexture on `player_transparent.png` | Used; seated `Rect2(1236, 596, 301, 428)` on 1980×1080 |
| Student position / scale | Runtime `DESK_NORM = (0.42, 0.56)` (row-2 / col-2); `STUDENT_SPRITE_SCALE = 0.13`; offset `(4, 16)`; z=4; same scale for seated + walk frames |
| Desks / blackboard / formulas / clock / globe / windows | Painted **into** classroom.png (not separate nodes) |
| Dialogue overlay (Teacher then Student) | Used (`DialoguePanel.tscn`) |
| Walk to top-left door, fade to World Map | Used (`SceneManager`); path `DESK → ROW_GAP → AISLE → DOOR` with column x=`0.42` |
| “Next Scene” button | **Hidden** (legacy node) |
| Player WASD | **Disabled** during cutscene |
| Schoolyard / road to factory | **MISSING** as a scene |
| Audio (bell, chair, footsteps) | Files exist; **not wired** in SchoolScene.gd |

**Applied 2026-09-16:** School layout matched to reference composition (not a fixed % height rule). Player roam `sprite_scale` may still differ (`Player.gd` export); cutscene student scale is authoritative for School.

### 3.2 World Map — VISIBLE IN GAMEPLAY (landscape + landmark props)

**Scene:** `scenes/WorldMap/WorldMap.tscn`  
**Script:** `scenes/WorldMap/WorldMap.gd`

- Background: `asset/sprites/Environment/worldmap/worldmap_background.png` (1376×768 plain landscape; no baked buildings/roads). Letterboxed into the viewport without distortion (`MAP_DESIGN_SIZE`).
- Landmarks: separate `PropArt` TextureRects — **`factory.png`** (Zone 01), `landmark_energy_refinery.png`, `landmark_signal_station.png`, `landmark_substation.png`, `landmark_unrevealed.png`. Old `landmark_factory.png` is leftover/unused.
- Zone 01 pin rect (design space): `Rect2(48, 400, 300, 260)`.
- Lock state: darkened `PropArt` modulate (`Color(0.45,0.45,0.5)`) + `DimOverlay` ColorRect + `LockIcon`; unlocked = full brightness, overlays hidden. PinButton text empty (identity from art). `OpenStamp` still shown for unlocked Z02–05.
- TODO: dedicated World Map badge-stamp textures when a zone is cleared (`BadgeIcon` node reserved; BadgeManager is flag-only today).
- Factory hotspot: `UI/Root/Zone01FactoryButton` (synced to Zone01Pin rect) → Zone 01 Exterior
- **Five pins** under `UI/Root/Pins/`: Zone01Pin … Zone05Pin with PropArt + PinButton click areas
- On load: `GameState.is_zone_unlocked(zone_id)` — unlock logic unchanged
- Zone 01 → Exterior  
- Zone 02 → `Zone02_Entry.tscn` (Assessment Wing)  
- Zone 03 → `Zone03_Entry.tscn` (Signal Station corridor)
- Zone 04 → `Zone04_Entry.tscn` (Substation walkway)
- Zone 05 → Hub scaffold (identity **not locked**; prop marks Unrevealed)
- Old baked `Environment/map.png` kept as leftover/reference. `powerplant_select.jpg` / `researchlab_select.jpg` still unused as pin art.

### 3.3 Zone 01 Exterior — VISIBLE IN GAMEPLAY

**Scene:** `scenes/Zone01_Factory/Zone01_Exterior.tscn`  
**Script:** `scripts/Zone01Exterior.gd`

- Design space **1603×902** (`YardCamera` letterboxes into the live viewport; global project window unchanged so Zone 01 floors stay 1152×648).
- `GrassBackground`: `factory_yard_grass_bg.png` (on-disk original was `.jpg` 1376×768) fill.
- `RoadSprite`: `road_factory_entrance.png` (portrait) rotated 90° → horizontal strip from the left to the south gate.
- Factory: `factory_exterior (1).png` Sprite2D uniform scale ~0.52, black chroma-keyed. `FactoryFootprint` blocks the building; south gate gap stays walkable.
- Player starts on the **left** (WASD / `Player.tscn`). Guard at the gate. `ProgressGate` still blocks entry until E-talk grant — logic unchanged.
- `GateDoorArt`: `factory_gate_locked.png` → `factory_gate_open.png` on grant (same moment Guard tweens aside).
- Enter Factory button **disabled** until grant; `zone01_guard_granted` / `zone01_entered` persisted

### 3.4 Zone 01 Floor 1 — VISIBLE IN GAMEPLAY

**Scene:** `Zone01_Floor1.tscn` + `Zone01Floor1.gd` + `ZoneFloorController.gd`

- Background: refined `factory_floor_1.png` (runtime cover-scale via `FloorRoomSetup.configure_background_sprite`)
- Player WASD; collision from `data/room_collisions.json` profile `zone01_floor1` (perimeter + interior machinery/crates). Layer 1 vs walls layer 2
- Dialogue → Start Quiz → ≥80% → Continue to Floor 2 (or walk unlocked stairs)
- Manager idle crop from `manager 1.png`
- Empty `ActionBar` ColorRect **removed** on Floor 1 only
- Staircase lock area: **collision barrier** until pass (`StaircaseLockArea` Barrier StaticBody2D)

### 3.5 Zone 01 Floor 2 — VISIBLE IN GAMEPLAY

**Scene:** `Zone01_Floor2.tscn`

- Background: refined `factory_floor_2.png` (runtime cover-scale)
- Same quiz/gating controller as other floors
- Empty ActionBar **still in this scene** (Floor 1 fix was Floor-1-only)
- Manager: `manager_norm` (0.34, 0.22) on the open floor strip under the top consoles (not on the top-center pipes). Was a hardcoded (470, 260).
- Collision: `zone01_floor2` — `top_center_pipes`, shrunk `conveyor_block`, `quiz_press`. `quiz_zone` [0.72, 0.54, 0.16, 0.14] is the open floor in front of the right press; Start Quiz stays the existing UI button.

### 3.6 Zone 01 Floor 3 — VISIBLE IN GAMEPLAY

- Background: refined `factory_floor_3.png` (runtime cover-scale)
- Same quiz/gating pattern
- Collision: profile `zone01_floor3` (left equipment, top-right servers, debris)

### 3.7 Zone 01 Floor 4 — VISIBLE IN GAMEPLAY

- Background: refined `factory_floor_4.png` (path was `.jpg`; now PNG)
- Collision: profile `zone01_floor4` (bookcases, center desk, pedestal, crates)
- Quiz JSON: `data/zone01_floor4_questions.json`
- Director idle crop from `director_sheet.png`
- After ≥80%: emergency phone dialogue (`post_pass_lines`) then Continue → MiniGame 01
- Sets `zone01_director_passed`

### 3.8 Minigames 01–05 — VISIBLE IN GAMEPLAY (physics UI)

Scripts under `scripts/zones/zone01/`. Scenes keep the old paths. **Not** `PlaceholderScene.gd`.

| MG | Script | Pass | Fail |
|---|---|---|---|
| 1 Brake | `MiniGame01Brake.gd` | NO then 150 N | YES or wrong force → reload MG1 |
| 2 Gear | `MiniGame02Gear.gd` | Test then confirm 150–200 RPM | Wrong confirm → MG1 |
| 3 Balance | `MiniGame03Balance.gd` | Place 200 N (moments) | Wrong / timeout → MG1 |
| 4 Pressure | `MiniGame04Pressure.gd` | 100 N (P=F/A) | 60 or 140 N → MG1 |
| 5 Pulley | `MiniGame05Pulley.gd` | MA ≥ 4 + rope | Snap → MG1; success awards Momentum Crest |

Loose art **is** instanced (ramp, block, housing, gear, crane, load, press, gauge, rig, pulley). Drag-and-drop GDD is **click/toggle** in Godot.

### 3.9 Shared systems — VISIBLE IN GAMEPLAY

| System | Files | Notes |
|---|---|---|
| Autoloads | GameManager, **GameState**, SceneManager, BadgeManager | Save JSON includes zone unlocks; F5 resets all |
| F5 | GameManager | Resets flags **including GameState**; **does not reload scene** |
| Player | `Player.tscn` / `Player.gd` | Zone 01 floors + Exterior; Zone 02–04 rooms via `RoomWalkController` (School student is a separate Sprite2D) |
| Quiz | QuizPanel, QuizManager | MCQ + typed short answers (`LineEdit`; Zone 02 Rooms 2–3; Zone 03 Decks 3–4; Zone 04 Bays 4–5) |
| Dialogue | DialoguePanel | Zone 01 floors; Zone 02–04 Entry/Decks/Capstone/MG |
| Interact | `Interactable.gd`, `ProgressGate.gd`, `interact` (E/F) | Guard talk; factory gate lock |
| NPC crop | `NPCIdleSprite.gd` + `shaders/chroma_key.gdshader` | First idle cell; white or black chroma |
| Zone scaffold | ZoneHub.gd, ZoneScaffoldFloor.gd | Zone **05** UI-only floors (Zone 02 leftover Floor4 unused) |
| Zone 02 | `scripts/zones/zone02/` | Entry, Deck, Capstone, MiniGame3 — extend `RoomWalkController` |
| Zone 03 | `scripts/zones/zone03/` | Entry, Deck, Capstone, MiniGame1, MiniGame2 — extend `RoomWalkController` |
| Zone 04 | `scripts/zones/zone04/` | Entry, Deck, Capstone, MiniGame1 — extend `RoomWalkController` |
| Room walk | `RoomWalkController.gd`, `FloorRoomSetup.gd`, `data/room_collisions.json` | Converts `RoomArt` → walkable Sprite2D; perimeter + obstacle colliders; roaming pauses during dialogue/quiz |
| Verify | `scripts/tools/verify_project.gd` | Headless **637 / 0** as of 2026-08-19; turns `trial_unlock_all` off so production gating still tests |

### 3.10 Zone 02 Assessment Wing + Zone 05 scaffold

**Zone 02 is no longer ColorRect Hub/Floors.** Play path is Map C (§43, **in Godot 2026-08-18**). World Map → `Zone02_Entry.tscn`. Hub still exists and redirects (“Enter Assessment Wing”). Leftover `Zone02_Floor4.tscn` scaffold is **unused**. Energy MG1–2 remain **NOT YET DESIGNED** (Rina dialogue admits they are not online).

| File | Role |
|---|---|
| `Zone02_Entry.tscn` | Assessment Wing corridor; Rina intro; three doors; Control Room Exit after Room 3 |
| `Zone02_Floor1.tscn` | Room 1 — Nabila, 15 MCQ, ≥80% unlocks Door 2 |
| `Zone02_Floor2.tscn` | Room 2 — Karim, 10 MCQ + 5 short, unlocks Door 3 |
| `Zone02_Floor3.tscn` | Room 3 — Farah, 5 MCQ + 10 short, unlocks Capstone |
| `Zone02_Capstone.tscn` | Rina Control Room verdict; **does not** unlock Zone 03 |
| `Zone02_MiniGame3.tscn` | Build the System — live MA/efficiency vs 60 kg, 200 N, 70%; lube for ≥70%; fail = rebuild (no GAME OVER); Radiant Crest + unlock Zone 03 |
| `Zone02_Hub.tscn` | Kept; Enter Assessment Wing → Entry |
| `Zone02_Floor4.tscn` | Leftover scaffold — **do not use** |

Scripts: `scripts/zones/zone02/Zone02Entry.gd`, `Zone02Deck.gd`, `Zone02Capstone.gd`, `Zone02MiniGame3.gd`  
Dialogue: `data/zone02_dialogue.json`  
Banks: `data/zone02_room1_questions.json` … `room3`  
Room art: `asset/sprites/Environment/zone 2/energy_assessment_wing.png`, `energy_quiz_room_1.png` … `_3.png`, `energy_control_room.png`  
Walk: `RoomWalkController` converts `RoomArt` → Sprite2D + Player; hides pre-art `Background` ColorRect that previously covered `FloorBackground`; profiles `zone02_entry` / `zone02_room1–3` / `zone02_control` in `data/room_collisions.json`.

**Pixel sizes (2026-08-19 audit — cover-scale is to viewport 1152×648 ≈ 16:9, not to the 1296×1080 PNG standard):**

| File | Pixels | Sprite cover vs 1152×648 | Camera / `painted_norm` |
|---|---|---|---|
| `energy_assessment_wing.png` | 1920×1072 RGBA | ~0.4% L/R only — almost native 16:9 | All three doors stay in frame; doors 1 and 3 sit on the camera edges |
| `energy_quiz_room_1.png` | 1920×1072 RGBA | same tiny L/R | Whiteboard + right desk in frame |
| `energy_quiz_room_2.png` | **1080×1080** RGBA | **~22% top and bottom** — furthest off | Desk + instruments stay; formula-sheet tops / overhead light / extra floor cut. `zone02_room2.painted_norm` is a 16:9 window `[0.06, 0.27, 0.88, 0.50]` so clamp matches the visible band (do not stretch the PNG) |
| `energy_quiz_room_3.png` | 1920×1072 **RGB (no alpha)** | tiny L/R | Logic board + desk/chair in frame. RGB is fine — `RoomArt` / `FloorBackground` have no alpha material |
| `energy_control_room.png` | **1296×1080** RGBA | same ~16% T/B as factory floors | Console, schematic, RGB floor panels in frame — wire normally |

Do **not** force-stretch mismatched rooms. Do **not** re-crop source PNGs in-repo. UI props (`energy_door_locked.png` 1159×1080, `crest radiant.png` 1980×1080) are CanvasLayer TextureRects, not cover-scaled room bgs.  
NPC sheets (Rina / Nabila / Karim / Farah) wired as `ProctorNPC` + `RoomProctorSprite.gd` on Entry, Rooms 1–3, Capstone, and MiniGame3. Entry locked doors + capstone exit use `energy_door_locked.png` UI overlays (doors 2–3 lock until prior room pass; capstone until Room 3 pass). `crest radiant.png` on Capstone (`BadgeArt` preview) and MiniGame3 (preview → full on win). Badge flag via `BadgeManager.award_badge("radiant_crest")` on Engage success.

**Zone 05 remains scaffold only** — Hub / Floor1–4 / Capstone ColorRect + 5 MCQ placeholders. Scripts: `ZoneHub.gd`, `ZoneScaffoldFloor.gd`. **Do not** describe Zone 05 as a finished Citadel.

### 3.11 Zone 03 Signal Station — VISIBLE IN GAMEPLAY (implemented)

**CONFIRMED EXISTING / Production Ready** for the **gameplay loop** (2026-08-19 roaming pass; 2026-08-21 full cast). Refined paintings wired as `RoomArt`, then converted at runtime to walkable `FloorBackground` + obstacle colliders. **Anwar / Tania / Milon / Shirin / Farid** wired as `char_*_idle.png` proctors on Entry, Decks 1–4, and Capstone (single-idle alpha trim, uniform height).

| File | Role |
|---|---|
| `Zone03_Entry.tscn` | Scene 1 — corridor, Chief Anwar intro, four doors, Capstone Exit after Deck 4 |
| `Zone03_Floor1.tscn` | Scene 2 — Tania, Wave Basics, 15 MCQ, ≥80% unlocks Door 2 |
| `Zone03_Floor2.tscn` | Scene 3 — Milon, Sound & Vibration, 15 MCQ, unlocks Door 3 |
| `Zone03_Floor3.tscn` | Scene 4 — Shirin, Reflection & Refraction, 12 MCQ + 3 short, unlocks Door 4 |
| `Zone03_Floor4.tscn` | Scene 5 — Farid, Optics Diagnostic, 12 MCQ + 8 short, unlocks Capstone |
| `Zone03_Capstone.tscn` | Scene 6 — Anwar verdict at lighthouse base; **does not** unlock Zone 04 |
| `Zone03_MiniGame1.tscn` | Scene 7 — Signal Path grid (mirrors / glass / Transmit) |
| `Zone03_MiniGame2.tscn` | Scene 8 — optical rail; Spectrum Crest + `unlock_next_zone("zone_03")` → World Map |
| `Zone03_Hub.tscn` | Kept; Enter Corridor → Entry so old Hub paths still work |

Scripts: `scripts/zones/zone03/Zone03Entry.gd`, `Zone03Deck.gd`, `Zone03Capstone.gd`, `Zone03MiniGame1.gd`, `Zone03MiniGame2.gd`  
Dialogue: `data/zone03_dialogue.json`  
Banks: `data/zone03_room1_questions.json` … `room4` (legacy `zone03_floorY` files duplicate the same banks)

### 3.12 Zone 04 The Substation — VISIBLE IN GAMEPLAY (implemented)

**CONFIRMED EXISTING / Production Ready** for the **gameplay loop** (2026-08-19 roaming pass). Refined paintings wired as `RoomArt` then converted to walkable backgrounds + colliders (`zone04_entry` / `zone04_bay1–5` / `zone04_capstone` / `zone04_mg1`). Z04 NPC sheets **MISSING** (§12.8).

| File | Role |
|---|---|
| `Zone04_Entry.tscn` | Scene 1 — caged walkway, Chief Proma intro, five doors, Control Room Exit after Bay 5 |
| `Zone04_Floor1.tscn` | Scene 2 — Rumi, Fundamentals, 10 MCQ, ≥80% unlocks Door 2 |
| `Zone04_Floor2.tscn` | Scene 3 — Dipa, Circuit Basics, 15 MCQ, unlocks Door 3 |
| `Zone04_Floor3.tscn` | Scene 4 — Sabbir, Ohm's Law, 15 MCQ, unlocks Door 4 |
| `Zone04_Floor4.tscn` | Scene 5 — Nusrat, Diagnostics, 10 MCQ + 5 short, unlocks Door 5 |
| `Zone04_Floor5.tscn` | Scene 6 — Imran, Judgment, 12 MCQ + 8 short, unlocks Capstone |
| `Zone04_Capstone.tscn` | Scene 7 — Proma verdict; **does not** unlock Zone 05 |
| `Zone04_MiniGame1.tscn` | Scene 8 — Build the Generator; Spark Emblem + `unlock_next_zone("zone_04")` → World Map |
| `Zone04_Hub.tscn` | Kept; Enter Walkway → Entry |

Scripts: `scripts/zones/zone04/Zone04Entry.gd`, `Zone04Deck.gd`, `Zone04Capstone.gd`, `Zone04MiniGame1.gd`  
Dialogue: `data/zone04_dialogue.json`  
Banks: `data/zone04_room1_questions.json` … `room5`

---

# 4. ASSET DIRECTORY INVENTORY

**Source:** recursive listing of `asset/` on 2026-08-17, plus evening 2026-08-18 pack-in of Zone 02 sheets (`rina.png`, `farah karim and nabila.png`, `locked door bulb magnifying glass gear.png`, `other.png`).  
Duplicates named `(2)` or `(1)` are Windows copies. **Do not use `(2)` files** (UID collisions). Canonical file = name **without** `(2)`.

**Used In** = referenced by a `.tscn` / `.gd` / `.tres` in `final-godot`. “None” means **DOWNLOADED / AVAILABLE but unused**.

## 4.1 Characters

| Asset | Filename | Category | Current status | Used in | Needs cleanup? | Needs regen? | Notes |
|---|---|---|---|---|---|---|---|
| Player sheet (white bg) | `sprites/character/player.png` | Character | DOWNLOADED | No | Yes (opaque white) | No if transparent used | Source sheet |
| Player transparent | `player_transparent.png` | Character | CONFIRMED EXISTING | School, sprite frames | Edge speckle possible | Only if edges bad | 1980×1080 (was 2816×1536) |
| Player frames | `player_sprite_frames.tres` | Character | CONFIRMED EXISTING | Player.tscn | No | No | Includes seated crop |
| Player walk strip | `sprites/animation/player_walking_animation.png` | Character | DOWNLOADED | **None** | Unknown | Unknown | Unused alternate |
| Teacher opaque | `teacher.png` | Character | DOWNLOADED | No | White bg | No if idle used | Source |
| Teacher transparent | `teacher_transparent.png` | Character | DOWNLOADED | No (School uses idle crop) | Speckle on shirt | Maybe | Full sheet |
| Teacher idle crop | `teacher_idle.png` | Character | CONFIRMED EXISTING | School.tscn | Minor speckle | Optional | 429×587 |
| Director sheet | `director_sheet.png` | Character | GENERATED BUT NEEDS CLEANUP | Floor 4 idle crop | Labels, chroma-key | Photopea alpha | JPG copy in `New folder/` unused |
| Manager 1 | `manager 1.png` | Character | GENERATED BUT NEEDS CLEANUP | Floor 1 idle crop | Space in filename | Rename + crop | Wired via chroma-key |
| Manager 2 | `manager 2.png` | Character | GENERATED BUT NEEDS CLEANUP | Floor 2 idle crop | Same | Same | |
| Manager 3 | `manager 3.png` | Character | GENERATED BUT NEEDS CLEANUP | Floor 3 idle crop | Same | Same | |
| Guard sheet | `guard_shee (1).png` | Character | GENERATED BUT NEEDS CLEANUP | Exterior | Typo name; chroma-key stand-in | Rename `guard_sheet.png`, Photopea | E-talk + gate grant |
| Foreman Rina | `character/rina.png` | Character | GENERATED BUT NEEDS CLEANUP | Entry, Capstone, MG3 | Multi-pose sheet, baked labels, black bg | Slice idle-front; Photopea cleanup | `RoomProctorSprite.gd` |
| Nabila / Karim / Farah | `character/farah karim and nabila.png` | Character | GENERATED BUT NEEDS CLEANUP | Rooms 1–3 | Spaces in filename; three NPCs on one sheet | Split + `snake_case` optional | Nabila/Karim/Farah crops wired |
| Verify idle | `_verify_idle_on_purple.png` | Dev | DOWNLOADED | None | — | No | Debug image; do not ship |
| Zone 03 Anwar / Tania / Milon / Shirin / Farid | `character/character zone 3/char_{anwar,tania,milon,shirin,farid}_idle.png` | Character | CONFIRMED EXISTING | Entry, Decks 1–4, Capstone | — | No | Single-idle RGBA; `NPCIdleSprite` alpha-trim + uniform height. Old JPG/PNG sheets superseded |
| Zone 04 NPCs (Proma, Rumi, Dipa, Sabbir, Nusrat, Imran) | — | Character | **MISSING** | — | — | Yes | Remaining list; not generated |

## 4.2 Environments

| Asset | Filename | Category | Status | Used in | Cleanup | Regen | Notes |
|---|---|---|---|---|---|---|---|
| Classroom | `Environment/classroom.png` | Env | CONFIRMED EXISTING | School | No | No | Full room painting |
| Factory cutaway | `factory.png` | Env | CONFIRMED EXISTING | **None** (replaced as exterior BG) | Checker-like baked ground | No | F1–F4 labeled building; leftover |
| Factory exterior | `factory_exterior (1).png` | Env | CONFIRMED EXISTING | Exterior Sprite2D (scaled ~0.52) | Rename optional | If not matching style | Yard prop 2026-08-22; no longer full-screen |
| Factory yard grass | `factory_yard_grass_bg.png` (from `.jpg` 1376×768) | Env | CONFIRMED EXISTING | Exterior `GrassBackground` | — | No | Cover-scaled into 1603×902 |
| Factory entrance road | `road_factory_entrance.png` (672×1584 portrait) | Env | CONFIRMED EXISTING | Exterior `RoadSprite` | — | No | Rotated 90° to run horizontally |
| Factory gate locked/open | `factory_gate_locked.png`, `factory_gate_open.png` | Env | CONFIRMED EXISTING | Exterior `GateDoorArt` | — | No | Swapped on `zone01_guard_granted` |
| Floor 1 | `factory_floor_1.png` | Env | CONFIRMED EXISTING | Floor1.tscn | No | No | Refined PNG; profile `zone01_floor1` |
| Floor 2 | `factory_floor_2.png` | Env | CONFIRMED EXISTING | Floor2.tscn | No | No | Refined PNG; profile `zone01_floor2` |
| Floor 3 | `factory_floor_3.png` | Env | CONFIRMED EXISTING | Floor3.tscn | No | No | Refined PNG; profile `zone01_floor3` |
| Floor 4 | `factory_floor_4.png` | Env | CONFIRMED EXISTING | Floor4.tscn | Was JPG | No | Path switched from `.jpg` 2026-08-19 |
| World map background | `Environment/worldmap/worldmap_background.png` | Env | CONFIRMED EXISTING | WorldMap.tscn | — | No | 1376×768 plain landscape |
| World map landmarks | `Environment/worldmap/factory.png` + `landmark_{energy_refinery,signal_station,substation,unrevealed}.png` | Env | CONFIRMED EXISTING | WorldMap pin PropArt | Old `landmark_factory.png` leftover | No | Zone 01 uses `factory.png` (2026-09-16) |
| World map (old baked) | `Environment/map.png` | Env | DOWNLOADED | **None** (replaced 2026-08-22) | Baked title + locks + path | No | Leftover reference |
| World map (old parchment) | `world_map_background.png` | Env | DOWNLOADED | **None** | — | No | Leftover |
| Power plant select | `powerplant_select.jpg` | Env | DOWNLOADED | **None** | JPG | If used as zone art | Map A evidence |
| Research lab select | `researchlab_select.jpg` | Env | DOWNLOADED | **None** | JPG | Same | |
| Style reference | `factory_asset_reference.png` | Ref | DOWNLOADED | Docs/prompts | Not a gameplay sprite | No | See §11 |
| Zone 02 door + icons (packed) | `Environment/locked door bulb magnifying glass gear.png` | UI | GENERATED BUT NEEDS CLEANUP | **None** | Spaces in name; 4 assets + labels on black | Slice to `energy_door_locked.png`, `energy_icon_lightbulb.png`, `energy_icon_gear.png`, `energy_icon_magnifier.png` | User: generated |
| Zone 02 Create-MG (packed) | `Environment/other.png` | MG | GENERATED BUT NEEDS CLEANUP | **None** | Labels on sheet; black bg | Slice to `energy_mg3_*` names in §12.6 | Workbench, lever, fixed pulley, ramp, gear pair, rope, lube, drum. **Movable pulley** not clearly separate. |
| Zone 02 Assessment Wing rooms | `Environment/zone 2/energy_assessment_wing.png` 1920×1072, `energy_quiz_room_1.png` 1920×1072, `energy_quiz_room_2.png` **1080×1080**, `energy_quiz_room_3.png` 1920×1072 RGB, `energy_control_room.png` **1296×1080** | Env | CONFIRMED EXISTING | Zone02 Entry / Floors 1–3 / Capstone / MG3 | Room 2 square; Room 3 no alpha | No — do not re-crop in-repo | Cover-scale is viewport 16:9 (not 1296). Control room uses `scale_mode: contain` so 1296×1080 fits without vertical crop-zoom. Room 2 `painted_norm` is the visible 16:9 band |
| Radiant Crest | `Environment/zone 2/crest radiant.png` | Badge | CONFIRMED EXISTING | Capstone + MiniGame3 `BadgeArt` | Spaces in name | Optional rename | Preview on Capstone; full on MG3 win + flag |
| Zone 03 Signal Station rooms / MG boards | `Environment/zone 3/signal_station_*.png` | Env | CONFIRMED EXISTING | Zone03 Entry–MG2 | Truncated capstone filename | Optional rename | `RoomArt` + walk colliders |
| Spectrum Crest | `Environment/zone 3/spectrum badge.png` | Badge | CONFIRMED EXISTING (rebuild) | Zone03 Floor4 BadgeArt / docs | Spaces in name | Keep filename | Living docs: `MINIGAME_IMPLEMENTATION.md` |
| Zone 04 Substation env | `Environment/zone 4/substation_*.png` | Env | CONFIRMED EXISTING | Zone04 Entry–MG1 | — | No | `RoomArt` + walk colliders |
| Observatory | — | Env | MISSING | — | — | Yes when designed | |
| Thermo / industrial | — | Env | MISSING | — | — | Yes when designed | |
| School exterior / road | — | Env | MISSING | — | — | Yes for GDD scene 2 | |
| Director office (unique) | — | Env | MISSING | Floor 4 uses floor_4.jpg | — | Optional | |

## 4.3 Machinery / minigame loose files

These are **CONFIRMED EXISTING** under `asset/sprites/Environment/` (restored 2026-08-19 from Godot `.ctex` cache after env cleanup deleted the PNGs). Wired into Zone 01 MiniGame01–05 `.tscn` files. Still **GENERATED BUT NEEDS CLEANUP** (typos, `(1)` names, labels).

| Asset | Filename | Likely MG | Used in | Notes |
|---|---|---|---|---|
| Crane | `crane.png` | MG3 | `MiniGame03_Balance.tscn` | |
| Press | `press.png` | MG4 | `MiniGame04_Pressure.tscn` | |
| Rig | `rig.png` | MG5 | `MiniGame05_Pulley.tscn` | |
| Pulley (typo) | `pully (1).png` | MG5 | `MiniGame05_Pulley.tscn` | Rename `mg5_pulley.png` |
| Load | `load (1).png` | MG3/5 | `MiniGame03_Balance.tscn` | |
| Weights | `weights (1).png` | MG3 | None (on disk) | May be a sheet of 5 weights |
| Gauge (typo) | `guage (2).png` | MG4 | `MiniGame04_Pressure.tscn` | Canonical should be `mg4_pressure_gauge.png` |
| MG1 block | `mg1_block (1).png` | MG1 | `MiniGame01_Brake.tscn` | 1920×1920 RGBA |
| MG1 ramp bg | `mg1_ramp_bg.png` | MG1 | `MiniGame01_Brake.tscn` | 1376×768 playfield |
| MG2 gear | `mg2_gear_a (1).png` | MG2 | `MiniGame02_Gear.tscn` | Need more gears |
| MG2 housing | `mg2_housing.png` | MG2 | `MiniGame02_Gear.tscn` | |
| Badge | `badge_momentum_crest (1).png` | Reward | None | Not shown in UI |
| Conveyor (separate) | — | Env/MG2 | MISSING | Floor 2 has conveyor **painted in BG only** |

## 4.4 Audio (files exist; playback not confirmed in scenes)

| File | Status | Used in code? |
|---|---|---|
| `music/amb_classroom.ogg` | DOWNLOADED | **No** (grep: not in SchoolScene) |
| `music_opening_sting.ogg` | DOWNLOADED | **No** |
| `sfx_chair_scrape.ogg` | DOWNLOADED | **No** |
| `sfx_footsteps_wood.ogg` | DOWNLOADED | **No** |
| `sfx_paper_rustle.ogg` | DOWNLOADED | **No** |
| `sfx_school_bell.ogg` | DOWNLOADED | **No** |
| `sfx_typewriter_tick.ogg` | DOWNLOADED | **No** |
| Factory SFX set | MISSING | — |

## 4.5 Fonts / icons

| Item | Status |
|---|---|
| `asset/fonts/` | Empty / **MISSING** |
| Dedicated icon set | **MISSING** (Godot default theme used) |

## 4.6 Data

| File | Status | Notes |
|---|---|---|
| `final-godot/data/zone01_floor1_questions.json` … `floor4` | CONFIRMED EXISTING | 5 questions each; **not** 50/floor GDD |
| Save (legacy scaffold notes) | `user://savegame.json` | **Superseded in rebuild** by `user://profiles/` + `SaveManager` — see `Docs/PROGRESS.md` |
| Profile save (rebuild) | `user://profiles/index.json` + per-profile JSON | CONFIRMED — Main Menu + **S** checkpoint save |

---

# 5. COMPLETE FACTORY ZONE ROADMAP

## 5.1 Structure (CONFIRMED IN DOCUMENTATION)

- Multi-floor factory. Chat: **5-story** building; playable spec: **Floors 1–4** + optional rooftop/Floor 5 establishing shot.
- Floors 1–3: Floor Manager + quiz, Bloom difficulty up.
- Floor 4: Director + final quiz (Analyze/Evaluate).
- Then emergency + **five minigames, one continuous run**.
- Success: Momentum Crest; World Map unlocks Zone 02.

## 5.2 Bloom mapping (CONFIRMED IN DOCUMENTATION; not encoded in JSON)

| Floor | Bloom (docs) | In code |
|---|---|---|
| 1 | Remember → Understand | 5 generic MCQs |
| 2 | Understand → Apply | 5 generic MCQs |
| 3 | Apply → Analyze | 5 generic MCQs |
| 4 | Analyze → Evaluate | 5 generic MCQs |

## 5.3 Minigames (authoritative design: `docs/capstone,md.txt`)

| # | Name | Physics | Fail condition (docs) | Godot |
|---|---|---|---|---|
| 1 | Emergency Brake | f = μmg, N2, deceleration | Crash → GAME OVER → MG1 | **IMPLEMENTED** (UI + existing ramp/block art) |
| 2 | Gear Swap | Gear ratio, RPM | Wrong confirm → belt snap | **IMPLEMENTED** |
| 3 | Counterweight Balance | Moments F₁d₁ = F₂d₂ | Wrong/timeout → crash | **IMPLEMENTED** |
| 4 | Pressure Panic | P = F/A, Pascal | Wrong zone → burst | **IMPLEMENTED** |
| 5 | Pulley Rush | MA = Load/Effort | MA < 4 → snap | **IMPLEMENTED** (awards Momentum Crest) |

**MG1 numbers (docs):** mass 40 kg, μ = 0.35, 7 m; YES/NO then extra force.  
**MG3 numbers:** 300 N at 2 m, CW at 3 m; weights 150/180/200/220/250 N.  
**MG4 numbers:** A_in 0.02 m², A_out 0.10 m², P_out 5000 Pa; forces 60/100/140 N.  
**MG5 numbers:** Load 600 N, motor 150 N, need MA ≥ 4.

Any GAME OVER **restarts Mini-Game 1**. **IMPLEMENTED** 2026-08-18.

## 5.4 NPCs (docs vs code)

| NPC | Docs | Code |
|---|---|---|
| Teacher | School | School sprite |
| Guard | Exterior step-aside | Sprite + E-talk + gate lock (`guard_shee (1).png`) |
| Manager 1–3 | Floors 1–3 | Idle crop from JPG sheets on floors |
| Director | Floor 4 + MG5 clap | Sprite + post-quiz emergency lines |
| Workers | Optional hints | Missing |

---

# 6. FACTORY ASSET MASTER CHECKLIST

Legend: `[x]` file on disk · `[~]` file but unused/unclean · `[ ]` missing · `[G]` Godot default UI

## A. Characters

- [x] Player idle/walk (transparent sheet + SpriteFrames)
- [ ] Player talk pose (distinct)
- [ ] Player climb stairs
- [x] Teacher idle crop
- [~] Director sheet (JPG, **wired** via chroma-key idle crop; still needs Photopea)
- [ ] Director worried / smiling variants (not confirmed as separate files)
- [~] Manager 1/2/3 JPG **wired** via chroma-key; still need Photopea
- [~] Guard sheet **wired** on Exterior; still needs rename + Photopea
- [ ] Factory worker male/female
- [ ] Engineer / technician / safety officer (**PLANNED** in chat; not required for MVP)

## B. Environment

- [x] Classroom
- [x] Factory exterior (`factory_exterior (1).png`)
- [~] Factory cutaway leftover (`factory.png`, not the exterior BG)
- [x] Floors 1–4 backgrounds
- [ ] School exterior + road + signs
- [ ] Door closed/open states
- [ ] Staircase locked/unlocked overlay (logic exists; art optional)
- [ ] Rooftop / Floor 5
- [x] World map painting
- [ ] Unique Director office if Floor 4 art is insufficient

## C. Machinery (world props)

- [~] Conveyor only as pixels on floor_2.png
- [ ] conveyor_belt.png / broken
- [ ] crates, barrels, pressure plate, industrial button/switch
- [ ] pipes/valves as separate sprites
- [ ] control panel sprite
- [x] factory_asset_reference.png (style only)

## D. Mini-game assets

See §7. Raw files **wired** into MG1–5 scenes (click/toggle UI, not drag-and-drop).

## E. UI

- [G] Godot Button / Label / PanelContainer
- [x] Dialogue panel scene
- [x] Quiz panel scene
- [ ] Custom MCQ art, nameplates, portraits
- [ ] World map lock icons for zones 2–5
- [~] Badge PNG unused
- [ ] Pause, retry, GAME OVER, PROBLEM SOLVED banners

## F. VFX

- [ ] Sparks, dust, steam, alarm overlay, confetti
- [ ] Some FX may exist **inside** `factory_asset_reference.png` as drawings, **not** sliced sprites

## G. Audio

- [x] 7 school/opening files (unwired)
- [ ] All factory / MG / quiz / badge SFX

## H. Fonts

- [ ] Project fonts (Bengali+English if bilingual — **UNKNOWN**)

## I. Icons

- [ ] Padlock, check, cross, interact, push/pull

## J. Animation

- [x] Player 4-dir via AtlasTexture frames (mostly single-frame “walk”)
- [~] Guard sidestep (tween left after grant; not a walk cycle)
- [ ] Door open
- [ ] MG success/fail animations

---

# 7. MINI-GAME ASSET BREAKDOWN

**Existing?** = file found under `asset/` (any name). **In scene?** = used by MiniGame tscn. Zone 01 MG1–5: **yes, wired 2026-08-18** (click/toggle UI); PNG sources **restored 2026-08-19** after env cleanup. Packed Energy MG3 props in `other.png` are **not** sliced into `Zone02_MiniGame3` (that scene uses Labels + Zone 01 pulley art).

## MG1 — Emergency Brake

| Asset | Purpose | Existing? | Download? | Nano Banana? | Animation? |
|---|---|---|---|---|---|
| Ramp / side-view bg | Playfield | Yes `mg1_ramp_bg.png` | No | Only if style mismatch | Optional scroll |
| Sliding block | Actor | Yes `mg1_block (1).png` | No | Cleanup | Slide + stop/crash |
| Data panel | mass, μ, distance | No (use Godot UI) | No | Optional | — |
| YES/NO buttons | Friction-alone question | Godot Button | No | No | — |
| 3 force buttons | Extra brake | Godot | No | No | — |
| Speed indicator | Tension | No | Optional | Optional | Needle/number |
| Countdown bar | Timer | Godot ProgressBar | No | No | — |
| Screech / dust | Success | No | Optional | VFX sheet | Yes |
| Crash + sparks | Fail | No | Optional | Yes | Yes |
| PROBLEM SOLVED banner | Success | No | No | Optional | — |
| GAME OVER | Fail | No | No | Optional | — |

## MG2 — Gear Swap

| Asset | Purpose | Existing? | NB? | Anim? |
|---|---|---|---|---|
| Housing + smoke | Broken slot | `mg2_housing.png` | Cleanup | Smoke loop |
| Gear A | Draggable | `mg2_gear_a (1).png` | Need 3–4 more sizes | Spin |
| Empty slot highlight | Target | Missing | Yes or Godot ColorRect | Pulse |
| RPM meter | Feedback | Missing (`guage` may be reused) | Maybe | Needle |
| Conveyor | Result | Missing as sprite | Yes | Belt move |
| Test / Confirm buttons | UI | Godot | No | — |
| Belt snap | Fail | Missing | Yes | Yes |

## MG3 — Counterweight Balance

| Asset | Purpose | Existing? | NB? | Anim? |
|---|---|---|---|---|
| Crane arm | Tilting | `crane.png` | Cleanup | Tilt |
| Conical load | Left mass | `load (1).png` | Cleanup | Descend |
| Weight blocks 5× | 150–250 N | `weights (1).png` (sheet?) | Slice + labels | Place |
| Shelf | Source of weights | Missing | Optional | — |
| Place button | Commit | Godot | No | — |
| Descent bar | Timer | Godot | No | — |
| Impact destroy | Fail | Missing | Yes | Yes |

## MG4 — Pressure Panic

| Asset | Purpose | Existing? | NB? | Anim? |
|---|---|---|---|---|
| Hydraulic press | Two pistons + pipe | `press.png` | Cleanup | Needle/steam |
| Gauge 3 zones | Green/yellow/red | `guage (2).png` | Rename + verify | Needle sweep |
| Force buttons | 60/100/140 N | Godot | No | — |
| Steam success | Win | Missing | Yes | Yes |
| Pipe burst | Fail | Missing | Yes | Yes |

## MG5 — Pulley Rush

| Asset | Purpose | Existing? | NB? | Anim? |
|---|---|---|---|---|
| Empty rig | Playfield | `rig.png` | Cleanup | — |
| Pulley parts | Drag-drop | `pully (1).png` (maybe one) | Need fixed/movable/double/spool | Thread rope |
| Engine block | Load | Maybe `load` | Distinct from MG3 | Rise/drop |
| Motor | Effort 150 N | Missing (in reference sheet?) | Yes | Whir |
| MA readout | Live | Godot Label | No | — |
| Rope snap | Fail | Missing | Yes | Slow-mo |
| Director clap | Win beat | director_sheet unused | Crop | Optional |

---

# 8. OTHER ZONES

Zone 02 **content is locked to Map C** (§43). Zones 03–04 are locked to **Signal Station** and **The Substation** (§45–§46). Map A names are historical. Map B GDD is superseded for 02–04 gameplay (Zone 02 Hub + Control Room art language only).

## Zone 02 — Energy Refinery / Assessment Wing (Map C — CANONICAL — in Godot)

- Physics / reward: Work, Power, Energy, Conservation, Simple Machines, MA, VR, Efficiency → **Radiant Crest**
- Scene confirmed in Godot? **Yes** — `Zone02_Entry` → Rooms 1–3 → Control Room → Build the System (`Zone02_MiniGame3`)
- Playable? **Yes** (80% rooms + Create-MG). Energy MG1–2 **skipped** (undesigned). NPC proctors + crest UI **placed** on all six play scenes.
- Background available? **Yes** — refined `energy_*` rooms as `RoomArt` + player roaming/collision (`room_collisions.json`). Sizes mixed: Control 1296×1080 (standard); Entry/Rooms 1+3 1920×1072; Room 2 **1080×1080** (16:9 `painted_norm`, no PNG stretch).
- Canonical script: **§43** (now the play path; leftover Floor4 scaffold unused)
- **Do not** invent Energy Mini-Games 1–2. **Do not** paste Map B Loading Dock / Drop Tower / Machine Shop as those stations. **Do not** rebuild Zone 02 as four ColorRect quiz floors.

**Art that may still be used from Map B docs:** Hub / refinery exterior; Control Room schematic language (Map C Scene 5 already shares it).  
**Do not generate as Zone 02 rooms:** Map A generator/turbine Power Plant; Map B Floors 1–3 as the quiz path.

## Zone 03 — Signal Station (CANONICAL — in Godot)

- Curriculum: waves, sound, reflection/refraction, optics diagnostics → **Spectrum Crest**
- Spec: **§45**. Scenes: `scenes/Zone03/` Entry, Floors 1–4, Capstone, MiniGame1–2. Hub redirects to Entry.
- Unlock: Mini-Game 2 awards the crest and `unlock_next_zone("zone_03")`. Capstone does **not** unlock Zone 04.
- `researchlab_select.jpg` on disk, unused. Optional style only — **do not** build Map A Research Lab / Flux Badge or Map B Matter Labs.
- Env art: refined `signal_station_*.png` as `RoomArt` + `RoomWalkController` collision. Packed Zone 02 sheets exist unused for doors/icons (§12.6). Zone 03 cast idles **wired** (`char_*_idle.png`).

## Zone 04 — The Substation (CANONICAL — in Godot)

- Curriculum: charge/current/voltage, circuits, Ohm’s law, diagnostics/Lenz, design judgment → **Spark Emblem**
- Spec: **§46**. Scenes: `scenes/Zone04/` Entry, Floors 1–5, Capstone, MiniGame1. Hub redirects to Entry.
- Unlock: Build the Generator awards the emblem and `unlock_next_zone("zone_04")`. Capstone does **not** unlock Zone 05.
- **Do not** build Map A Observatory / Lens Token or Map B Wave Observatory.
- Env art: refined `substation_*.png` as `RoomArt` + walk colliders. Zone 04 NPC sheets **MISSING**.

## Zone 05 — Industrial / Citadel

- **No environment art files found**
- Godot: `scenes/Zone05/` Hub–Capstone **scaffold**
- Map B flags possible split 05a/05b for real content

## Side concept (chat dump) — scientist Pokémon battles + flash cards

- **PLANNED / OPTIONAL / NOT IN CODE**
- Conflicts with current Floor = Manager quiz
- **Do not implement** unless explicitly scheduled; would be a large second system

---

# 9. ZONE STATUS TABLE

| Zone | Concept | Scene confirmed? | Playable? | Background available? | Characters available? | Gameplay designed? | Assets complete? |
|---|---|---|---|---|---|---|---|
| 01 Factory | Mechanics | 🟢 School, map, exterior, F1–4, MG1–5 | 🟢 80% + emergency run | 🟢 `factory_exterior`; floors; MG art | 🟢 Player/teacher/Guard/managers/Director | 🟢 Docs yes | 🟡 Sheet crops not Photopea-clean |
| 02 Energy Refinery / Assessment Wing | 🟢 Map C locked (§43) | 🟢 Entry–Rooms–Control–MG3 | 🟢 15/15/15 banks + Build the System | 🟢 `energy_*` wired | 🟢 Proctors + crest UI on all play scenes | 🟢 Script yes; MG1–2 undesigned | 🟡 Packed MG3 prop sheet unused; Hub ColorRect |
| 03 Signal Station (**canonical**) | Waves / sound / optics | 🟢 Entry–MG2 scenes | 🟢 80% decks + 2 MGs | 🟢 `signal_station_*.png` wired | 🟢 all five `char_*_idle.png` placed | 🟢 Implemented | — |
| 04 The Substation (**canonical**) | Electricity / magnetism | 🟢 Entry–MG1 scenes | 🟢 80% five bays + generator | 🟢 `substation_*.png` wired | 🔴 Z04 NPC sheets missing | 🟢 Implemented | 🔴 NPC art |
| 05 Light & Circuits (scaffold name) | ⚪ **Not locked** | 🟡 Hub–Capstone | 🟡 Placeholder quiz | 🔴 | 🔴 | 🟠 Skeleton | 🔴 |

🟢 Confirmed/ready · 🟡 Partial · 🟠 Planned · 🔴 Missing · ⚪ Not yet designed / conflict

---

# 10. ASSET ACQUISITION STRATEGY

| Method | Use when |
|---|---|
| **A — Existing project asset** | File already in `asset/` and style-matches (classroom, floors, player_transparent) |
| **B — Download** | Generic UI/SFX with a clear license; **not** unique NPCs |
| **C — Nano Banana** | Custom pixel props/NPCs matching reference |
| **D — Manual edit** | JPG→PNG, Photopea alpha, crop sheets, rename, slice weights/gears |
| **E — Programmer UI** | Buttons, bars, labels, quiz layout (already mostly this) |

**Priority order for Zone 01:** D (wire and clean what you have) → C (only true gaps) → E (UI) → B (SFX if needed) → never regenerate player/classroom without a reason.

---

# 11. NANO BANANA GENERATION STANDARD

Match:

- Retro pixel art, Pokémon Emerald–like readability
- Industrial / school science mood
- Muted purple-gray metal, dark outlines, 2-tone shade
- **No photorealism, no 3D renders, no UI chrome, no text** unless asked
- Transparent PNG, one object, centered
- Same “camera” as factory floors / character sheets (top-down or 3/4 as appropriate)

**Upload as style reference for factory/mechanical objects:**

`asset/sprites/Environment/factory_asset_reference.png`

This is a **STYLE REFERENCE**, not a drop-in spritesheet. Slice later if needed.

**Do not** use classroom.png as the style ref for a gear.  
**Do not** use player.png as the style ref for a turbine.

---

# 12. NANO BANANA PROMPT SYSTEM

## 12.1 Individual asset template

```text
Create a game-ready pixel-art [ASSET NAME] for Physics Quest, a retro 2.5D educational physics RPG.
Use the uploaded factory_asset_reference.png as the primary visual style reference.
Match its pixel density, dark outlines, muted industrial purple-gray palette, shading, proportions, and mechanical design language.
Create only the requested object, centered, isolated, transparent background, no text, no UI, no extra objects, no background scene.
```

## 12.2 High-priority factory / MG prompts (P0–P1)

**Reference to upload:** `factory_asset_reference.png` unless noted.

**factory_conveyor_belt.png**  
Template with `[ASSET NAME]` = `side-view industrial conveyor belt segment, flat top, visible rollers, Pokémon Emerald industrial pixel style`.

**factory_conveyor_belt_broken.png**  
Same belt, snapped belt, slight smoke, still isolated.

**factory_movable_crate.png**  
`small wooden crate, 3/4 top-down, readable silhouette, no labels`.

**factory_heavy_crate.png**  
`larger darker crate, metal corners, heavier read`.

**factory_pressure_plate.png**  
`floor pressure plate, recessed metal, top-down`.

**factory_switch_industrial.png**  
`wall lever switch, chunky pixel, isolated`.

**factory_spring_mechanism.png**  
`metal coil spring standing upright, isolated`.

**factory_fulcrum.png**  
`triangular fulcrum block for a lever, isolated`.

**mg5_pulley_double.png**  
`double movable pulley block with two wheels, isolated, no rope text`.

**mg3_counterweight.png**  
`single hanging counterweight, industrial, isolated`.

**factory_gear_assembly.png**  
`two meshed gears on a small mount, isolated`.

**factory_control_panel.png**  
`chunky factory control panel with blank gauges (no readable numbers), isolated`.

**npc_factory_worker.png** (also upload `player_transparent.png` for scale/style of characters)  
`one factory worker, same top-down proportions as the uploaded player sheet, idle front pose only, isolated, no pose labels, transparent background`.

**guard_sheet.png** — only if `guard_shee (1).png` is unusable  
Upload `player_transparent.png` + `factory_asset_reference.png`  
`guard character sprite sheet matching player sheet layout (idle front, side, back), factory uniform, no photorealism`. Prefer **cleanup of existing guard file** first (Method D).

## 12.3 Other-zone prompts (Zones 02–04 identities locked)

Do **not** generate Map A Power Plant rooms as Zone 02, Research Lab / magnets as Zone 03, or Observatory / telescope as Zone 04. Those maps lost.

Zone 02 art: §12.4 + §43.7.  
Zone 03–04 **gameplay is shipped**; refined env PNGs are **wired** with roaming collision. Do not generate Matter Labs or Wave Observatory rooms. `researchlab_select.jpg` / `powerplant_select.jpg` are optional style refs only.

**observatory_telescope.png** / **observatory_lens.png** — **do not generate for Zone 04**. No observatory zone is locked.

**industrial_heat_chamber.png** / **industrial_thermometer.png**  
Wait for Zone 05 decision; do not mass-generate.

## 12.4 Energy Assessment Wing / Create MG (Zone 02 canonical — generate when starting Zone 02 art)

**Zone 02 art is in scope.** Generate Assessment Wing + NPC + Create-MG props from this section and §43.7. Do **not** generate Map B Loading Dock / Drop Tower / Machine Shop as Zone 02 rooms.

Upload for mechanical parts: `factory_asset_reference.png`.  
Upload for people: `player_transparent.png` (scale) + `teacher_idle.png` (lab-coat language if useful).

**char_rina_idle.png**  
`Foreman Rina, industrial supervisor, idle front, arms-capable pose, same pixel density as the uploaded player, isolated, transparent, no text, no photorealism.`

**char_nabila_idle.png**  
`Lab assistant Nabila, warm encouraging expression, clipboard in one hand, idle front, isolated, transparent, no text.`

**char_karim_idle.png**  
`Lab assistant Karim, clinical folded-arms pose, idle front, isolated, transparent, no text.`

**char_farah_idle.png**  
`Lab assistant Farah, quiet precise idle front, no smile required, isolated, transparent, no text.`

**energy_assessment_wing.png** — this is a **full environment**, not an isolated prop. Generate only if a full-room painting is requested; otherwise compose in Godot from doors + corridor tiles. If generating a room: `short industrial lab corridor with three numbered doors, no readable text on the image, pixel art, matching factory_asset_reference lighting.`

**energy_mg3_lever.png** — `adjustable fulcrum lever, isolated, no numbers.`  
**energy_mg3_pulley_fixed.png** — `single fixed pulley, isolated.`  
**energy_mg3_pulley_movable.png** — `single movable pulley, isolated.`  
**energy_mg3_ramp.png** — `short adjustable incline plane, isolated.`  
**energy_mg3_gear_pair.png** — `two meshed gears, isolated, no tooth-count text.`  
**energy_mg3_rope.png** — `coiled rope or chain connector, isolated.`  
**energy_mg3_lube.png** — `small oil/lubrication can, isolated, no brand text.`  
**energy_mg3_workbench.png** — `empty industrial workbench / rig frame, isolated or as a simple bg strip.`  
**energy_mg3_water_drum.png** — `60 kg-looking water drum, isolated, no text.`  
**ui_badge_radiant_crest.png** — `simple crest/badge emblem, isolated, no letters.` (Method C; do not copy Momentum Crest file.)

**energy_icon_lightbulb.png / energy_icon_gear.png / energy_icon_magnifier.png** — tiny door icons, isolated, no text. Method E (Godot) is acceptable instead.

## 12.5 Existence-filtered Nano Banana catalog (chat 2026-08-18)

Disk check of `asset/` (same day). **CONFIRMED IN DOCUMENTATION** (prompts). Evening pack-in is in **§12.6** — do not stop at this subsection.

**Upload:** rooms → `factory_floor_1.png` + `factory_asset_reference.png`. Props → `factory_asset_reference.png`. Characters → `player_transparent.png` + `teacher_idle.png`.

### Do not generate (already usable, or Godot UI)

| File | Why skip |
|---|---|
| `player_transparent.png` | Player; reuse |
| `teacher_idle.png` | Upload reference only |
| `factory_floor_1.png` … `factory_floor_4.png` | Zone 01 rooms |
| `classroom.png`, `worldmap/worldmap_background.png` + landmarks | School + World Map |
| `factory_asset_reference.png` | Style reference, not a sprite |
| Quiz / MA / Engage widgets | Method E (Godot) |

### Exists on disk but **not** a Zone 02 asset — generate the new name

Do **not** reuse these as Assessment Wing / Create-MG art.

**Isolated-prop prefix (paste before each prop subject):**

```text
Create a game-ready pixel-art [ASSET] for Physics Quest, a retro 2.5D educational physics RPG.
Use the uploaded factory_asset_reference.png as the primary visual style reference.
Match its pixel density, dark outlines, muted industrial purple-gray palette, shading, and proportions.
Create only the requested object, centered, isolated, transparent background, no text, no UI, no extra objects, no photorealism, no 3D render.
```

**Full-room prefix:**

```text
Create a game-ready pixel-art full-screen room background for Physics Quest.
Use factory_floor_1.png for camera, pixel density, and top-down / three-quarter layout.
Use factory_asset_reference.png for 1px outlines and 2-tone cel shading.
One complete single-screen interior. Warm industrial light. No readable text, no numbers, no UI, no photorealism.
```

| Save as | On disk now (unusable for this) | Subject line after the matching prefix |
|---|---|---|
| `energy_hub_exterior.png` | `powerplant_select.jpg`, `factory.png` | Wide energy-refinery exterior hub. Tall industrial building, amber and copper pipes, glowing conduits, storage tanks, crane silhouette, steam on one stack. Late-afternoon light from the left. Empty doorway. No sign letters. |
| `energy_mg3_pulley_fixed.png` | `pully (1).png` (Zone 01 MG5, typo, unused) | Single fixed pulley wheel with a ceiling bracket, isolated, no rope text. |
| `energy_mg3_pulley_movable.png` | no separate movable | Single movable pulley block, isolated, no text. |
| `energy_mg3_ramp.png` | `mg1_ramp_bg.png` (Emergency Brake playfield) | Short adjustable inclined plane / ramp, isolated, no angle numbers. |
| `energy_mg3_gear_pair.png` | `mg2_gear_a (1).png` (one Gear Swap gear) | Two meshed industrial spur gears on a small mount, isolated, no tooth-count text. |
| `energy_mg3_workbench.png` | `rig.png` (MG5 pulley rig) | Empty industrial workbench and rig frame, three-quarter, isolated, no tools on it, no text. |
| `energy_mg3_water_drum.png` | `load (1).png` (crane load) | Heavy water drum / barrel that reads as a 60 kg load, isolated, no kg text, no labels. |
| `ui_badge_radiant_crest.png` | `badge_momentum_crest (1).png` | Simple Radiant Crest badge, shield silhouette, warm copper and amber, isolated, transparent, no letters, not a copy of Momentum Crest. |

### Missing — generate these too

| Save as | Subject (after the matching prefix) |
|---|---|
| `char_rina_idle.png` | Foreman Rina, industrial supervisor, same body proportions as the uploaded player sheet, idle front, arms crossed, industrial vest, isolated, transparent, no pose labels, no text, no photorealism. |
| `char_rina_gesture.png` | Same Rina, one arm gesturing down a corridor, isolated, transparent, no text. |
| `char_rina_back.png` | Same Rina, back view, standing, isolated, transparent, no text. |
| `char_nabila_idle.png` | Lab assistant Nabila, same proportions as the player, idle front, warm expression, clipboard in one hand, isolated, transparent, no text. |
| `char_karim_idle.png` | Lab assistant Karim, same proportions, idle front, arms folded, clinical face, isolated, transparent, no text. |
| `char_farah_idle.png` | Lab assistant Farah, same proportions, idle front, quiet precise face, no smile required, isolated, transparent, no text. |
| `energy_assessment_wing.png` | Short industrial lab corridor, three blank closed doors, warm factory light, metal floor, pipes. No numbers, no words, no icons on doors. Empty floor for the player. |
| `energy_quiz_room_1.png` | Small Recall Lab, blank wall panels, a desk, warm lamps, pipes. Empty center floor. No letters or formulas. |
| `energy_quiz_room_2.png` | Applied Lab, workbench, a small toy pulley and spring scale painted into the background only. No readable numbers. |
| `energy_quiz_room_3.png` | Diagnostic Lab, large blank wall screen, unlabeled machine shapes only. No text. |
| `energy_control_room.png` | Control room, blank monitors, unlabeled schematic silhouettes, central console, empty workbench, three station alcoves. Cool monitor glow on warm industrial base. No text. |
| `energy_door_locked.png` | Industrial lab door with a lock graphic only (padlock or red bar), isolated, no text. |
| `energy_icon_lightbulb.png` | Tiny pixel lightbulb icon, isolated, no text. |
| `energy_icon_gear.png` | Tiny pixel gear icon, isolated, no text. |
| `energy_icon_magnifier.png` | Tiny pixel magnifying-glass icon, isolated, no text. |
| `energy_mg3_lever.png` | Simple-machine lever on an adjustable fulcrum block, isolated, no numbers. |
| `energy_mg3_rope.png` | Coiled industrial rope or chain, isolated, no text. |
| `energy_mg3_lube.png` | Small oil can, isolated, no brand text. |

Optional later (not blocking): `char_rina_turn.png`; `npc_refinery_worker.png`; VFX `energy_vfx_lift.png`, `energy_vfx_stall.png`, `energy_vfx_rope_fray.png`, `energy_vfx_steam.png`.

**Do not generate:** Map B Loading Dock / Drop Tower / Machine Shop; Matter Labs; Wave Observatory; Citadel mass-gen; Zone 01 Guard/Director/Managers as Zone 02 casts; Spark Emblem PNG (Zone 04 flag). Audio is not Nano Banana.

**Generate order:** characters (Rina idle first) → hub + Assessment Wing + Control Room → three quiz rooms → Create-MG palette → badge + door icons.

**Later the same day:** packed sheets arrived (§4.1–4.2, §12.6). Canonical `energy_*.png` / `signal_station_*.png` filenames are still **not** separate files. Do not claim rooms are wired into Godot.

## 12.6 Nano Banana conventions + Zone 02 disk map (2026-08-18 evening)

**User conventions (lock these for later zones):**

1. **Solid white background** for every new generate from this point (characters, icons, props, sheets). Packed sheets already on disk used **black** + baked filename labels — Method D: slice, drop labels, prefer white or true alpha in Godot.  
2. **Icons / single props** go on **one reference page per category**, not one file per icon, then slice.  
3. Style: Pokémon Emerald readability, 2.5D top-down slight iso tilt, 1px dark outlines, 2-tone shading, “premium / $200 game” polish — still match `factory_floor_1.png` rooms and `factory_asset_reference.png` metal.  
4. Zone 02 NPCs were generated as sheets (`rina.png`, `farah karim and nabila.png`). Zone 03 full cast idles are on disk and **wired** (`char_anwar_idle.png` … `char_farid_idle.png`). **Zone 04 NPCs** still missing (§12.8).  
5. Reuse `energy_door_locked.png` (once sliced) for Zone 03 doors. Do **not** invent Zone 03 per-door lightbulb/gear/magnifier icons.

**Zone 02 — what is on disk vs still missing**

| Canonical name | On disk? | Source file |
|---|---|---|
| `char_rina_idle.png` (+ walk/side/back in sheet) | Packed | `rina.png` |
| `char_nabila_idle.png` | Packed | `farah karim and nabila.png` |
| `char_karim_idle.png` | Packed | same |
| `char_farah_idle.png` | Packed | same |
| `energy_door_locked.png` | Packed | `locked door bulb magnifying glass gear.png` |
| `energy_icon_lightbulb.png` / `_gear` / `_magnifier` | Packed | same |
| `energy_mg3_workbench.png` | Packed | `other.png` |
| `energy_mg3_lever.png` | Packed | `other.png` |
| `energy_mg3_pulley_fixed.png` | Packed | `other.png` |
| `energy_mg3_pulley_movable.png` | **Not clearly on sheet** | still generate or crop if a second pulley exists |
| `energy_mg3_ramp.png` | Packed | `other.png` |
| `energy_mg3_gear_pair.png` | Packed | `other.png` |
| `energy_mg3_rope.png` | Packed | `other.png` |
| `energy_mg3_lube.png` | Packed | `other.png` |
| `energy_mg3_water_drum.png` | Packed | `other.png` |
| `energy_assessment_wing.png` | **On disk + wired** 1920×1072 | `Environment/zone 2/` |
| `energy_quiz_room_1.png` | **On disk + wired** 1920×1072 | same |
| `energy_quiz_room_2.png` | **On disk + wired** **1080×1080** (square — 16:9 `painted_norm`) | same |
| `energy_quiz_room_3.png` | **On disk + wired** 1920×1072 RGB (no alpha; OK) | same |
| `energy_control_room.png` | **On disk + wired** 1296×1080 (Capstone + MG3) | same |
| `energy_hub_exterior.png` | **MISSING** (optional) | — |
| `ui_badge_radiant_crest.png` | Wired as `crest radiant.png` on Capstone + MiniGame3 | `Environment/zone 2/` |

User stated non-character Zone 02–03 work is “done.” Room paintings **are** in `asset/sprites/Environment/zone 2|3|4/`, wired as `RoomArt`, then converted at runtime to walkable sprites with `room_collisions.json` obstacles. Zone 02 NPC sheets **are** wired as `ProctorNPC`. Packed door-icon sheet and MG3 prop sheet remain unsliced.

Packed door / MG3 sheets are **not** used as Sprite2D props yet.

## 12.7 Zone 03 Signal Station — Nano Banana catalog (chat; rooms now in `asset/` and wired)

Skip regenerating the door-lock overlay (reuse Zone 02). No per-door icons. Zone 03 cast idles (`char_*_idle.png`) are **on disk and wired** — do not regenerate Anwar / Tania / Milon / Shirin / Farid.

Skip regenerating the door-lock overlay (reuse Zone 02). No per-door icons. Zone 03 cast idles (`char_*_idle.png`) are **on disk and wired** — do not regenerate Anwar / Tania / Milon / Shirin / Farid.

**Environments** (upload `factory_floor_1.png` + `factory_asset_reference.png`). Solid white if following the new convention; full-room paintings may use the floor’s own painted ground.

**`signal_station_entry.png`**  
Create a game-ready pixel-art top-down environment background for Physics Quest. An industrial signal-station corridor with four gated doors along one wall, each door showing a plain number plate (1–4), no icons, no readable text beyond the numerals. Match the uploaded factory_floor reference: muted purple-gray metal walls, warm floor accent, dark 1px outlines, 2-tone flat shading. No characters, no UI, no photorealism.

**`signal_station_deck1_waves.png`**  
A room themed around wave motion: a wall display showing simple sine-wave diagrams (abstract lines only, no readable text), one desk terminal. Match factory_asset_reference industrial metal and factory_floor walls. Top-down 2.5D, dark outlines, 2-tone shading, no characters, no UI, no text.

**`signal_station_deck2_sound.png`**  
Sound/vibration room: a speaker or tuning-fork rig on the wall, a simple oscilloscope-style screen with an abstract waveform (no readable text). Same style lock. No characters, no UI, no text.

**`signal_station_deck3_optics.png`**  
Optics room: a small angled mirror or prism on a stand, light-ray decals on the floor (abstract lines, no text). Same style lock.

**`signal_station_deck4_diagnostic.png`**  
Sparse diagnostic room: one wall screen with a partial optical-path diagram and blank value boxes (no readable text), minimal props, cold mood. Same style lock.

**`signal_station_capstone_lighthouse.png`**  
Lighthouse-base interior: curved metal walls, a tall structural column, a schematic panel, dim atmospheric lighting. factory_asset_reference purple-gray. No characters, no UI, no text.

**`signal_station_mg1_grid_board.png`**  
Flat grid of empty square cells (about 6×6) in an industrial console, subtle grid etching, no pieces, no text, no numbers.

**`signal_station_mg2_optical_rail.png`**  
Long optical rail at table height with three empty mount slots, industrial metal, minimal room around it.

**`ui_badge_spectrum_crest.png`**  
Pixel-art circular badge, prism/spectrum motif (rainbow-refraction or light-beam fan), chunky retro, dark outline, **solid white background**, no letters.

**Prop sheets** (upload `factory_asset_reference.png`; one page; solid white):

**`signal_station_mg1_pieces_sheet.png`**  
One page: (1) diagonal mirror `/` (2) diagonal mirror `\` (3) glass/prism panel tile. Separated, no labels.

**`signal_station_mg2_pieces_sheet.png`**  
One page: (1) empty mount stand (2) convex lens on a small holder. No labels.

## 12.8 Zone 03–04 characters

Idle-front was the prompt. **Solid white / transparent background.** Upload `player_transparent.png` + an existing `char_*_idle.png` for scale.

**On disk + wired (2026-08-21):**

| File | Scene |
|---|---|
| `character zone 3/char_anwar_idle.png` | Zone03 Entry + Capstone |
| `character zone 3/char_tania_idle.png` | Zone03 Deck 1 |
| `character zone 3/char_milon_idle.png` | Zone03 Deck 2 |
| `character zone 3/char_shirin_idle.png` | Zone03 Deck 3 |
| `character zone 3/char_farid_idle.png` | Zone03 Deck 4 |

Godot: `RoomProctorSprite` / `NPCIdleSprite` with `columns=1`, `rows=1`, `use_chroma=false`, alpha-bound trim, uniform `display_height` (~92–96).

**Still generate (Zone 04 only):**

| Save as | Prompt subject |
|---|---|
| `char_proma_idle.png` | Chief Proma, substation supervisor, confident commanding, idle front |
| `char_rumi_idle.png` | Rumi, fundamentals bay, approachable beginner-friendly, idle front |
| `char_dipa_idle.png` | Dipa, circuit-basics bay, practical hands-on, idle front |
| `char_sabbir_idle.png` | Sabbir, Ohm’s-law bay, analytical calm, idle front |
| `char_nusrat_idle.png` | Nusrat, diagnostics bay, sharp diagnostic-minded, idle front |
| `char_imran_idle.png` | Imran, judgment bay, stern evaluator, idle front |

Wrap each remaining generate with: game-ready pixel-art Physics Quest character, isolated, centered, **solid white background**, no pose labels, no text, no photorealism, same pixel density as uploaded Anwar/Rina.

**Zone 04 environments** were **not** in this generate batch. Do not mark Substation rooms as downloaded.

---

# 13. REFERENCE IMAGE RULES

| Generating | Upload |
|---|---|
| Gears, belts, pulleys, levers, doors, FX | `factory_asset_reference.png` |
| Crates, plates, worker props on factory floor | `factory_asset_reference.png` + optional `factory_floor_1.png` for palette |
| Player-like body / new student poses | `player_transparent.png` |
| Teacher variants | `teacher.png` or `teacher_idle.png` |
| Guard / manager / director cleanup | That character’s existing sheet, not the factory prop sheet |
| Power plant thumbnails | `powerplant_select.jpg` |
| Lab thumbnails | `researchlab_select.jpg` |
| Energy NPCs (Rina / assistants) | `player_transparent.png` + `teacher_idle.png` — **not** factory director sheet |
| Energy Create-MG machines | `factory_asset_reference.png` |
| School furniture | `classroom.png` |

Never upload a minigame ramp as the reference for a character.

---

# 14. FILE NAMING CONVENTION

- `snake_case`, English, no spaces (`manager 1.jpg` → `manager_1_sheet.png`)
- Prefix by domain: `factory_`, `mg1_`, `mg2_`, `school_`, `ui_`, `sfx_`, `amb_`, `energy_`, `char_`
- No `(1)` / `(2)` copies in the live set
- Fix typos when renaming: `pully` → `pulley`, `guage` → `gauge`, `guard_shee` → `guard_sheet`

Examples:

```
factory_asset_reference.png
factory_conveyor_belt.png
factory_movable_crate.png
mg1_emergency_brake_block.png
mg1_ramp.png
mg2_gear_small.png
mg2_gear_housing.png
mg3_crane_arm.png
mg3_weight_150n.png
mg4_hydraulic_press.png
mg4_pressure_gauge.png
mg5_pulley_fixed.png
mg5_pulley_movable.png
mg5_rope_spool.png
char_director_idle.png
char_guard_sheet.png
ui_badge_momentum_crest.png
energy_assessment_wing.png
energy_quiz_room_1.png
energy_quiz_room_2.png
energy_quiz_room_3.png
energy_control_room.png
energy_door_locked.png
energy_icon_lightbulb.png
energy_icon_gear.png
energy_icon_magnifier.png
char_rina_idle.png
char_nabila_idle.png
char_karim_idle.png
char_farah_idle.png
ui_badge_radiant_crest.png
energy_mg3_lever.png
energy_mg3_pulley_fixed.png
energy_mg3_pulley_movable.png
energy_mg3_ramp.png
energy_mg3_gear_pair.png
energy_mg3_rope.png
energy_mg3_lube.png
energy_mg3_workbench.png
energy_mg3_water_drum.png
```

Keep originals in a `_raw/` folder if needed; **Godot should only import canonical names**.

---

# 15. ASSET CLEANUP PIPELINE

1. Generate or download.  
2. Save raw (`_raw/`).  
3. Rename to §14.  
4. Photopea: Magic Wand tolerance **25–40**, delete bg, Contract 1–2 px if halo.  
5. Crop empty pixels; **keep integer pixel scale**.  
6. Resize with **Nearest Neighbor** only.  
7. Export **PNG**.  
8. Checkerboard = transparency.  
9. Compare next to player/factory floor.  
10. Put in the correct folder (§16).  
11. Godot import: 2D, filter **Nearest**, no 3D compress.  
12. AtlasTexture / SpriteFrames if a sheet.  
13. Place in a **test scene** before replacing production art.  
14. Log in `PROGRESS.md` + §4 inventory.

Godot AtlasTexture example (School seated):

`Rect2(1236, 596, 301, 428)` on `player_transparent.png` (1980×1080).

---

# 16. GODOT FOLDER STRUCTURE

**Current (CONFIRMED EXISTING):**

```
final-godot/
├── scenes/School/ School.tscn
├── scenes/WorldMap/ WorldMap.tscn + WorldMap.gd
├── scenes/Zone01_Factory/  Exterior, Floors 1–4, MiniGame01–05 (real MG scripts)
├── scenes/Zone02/  Entry, Floor1–3, Capstone, MiniGame3 (Map C); Hub redirect; leftover Floor4 unused
├── scenes/Zone03/  Entry, Floor1–4, Capstone, MiniGame1–2 (Signal Station)
├── scenes/Zone04/  Entry, Floor1–5, Capstone, MiniGame1 (The Substation)
├── scenes/Zone05/  Hub, Floor1–4, Capstone (scaffold)
├── scenes/NPC/ Interactable, ProgressGate
├── scenes/UI/ QuizPanel, DialoguePanel
├── scenes/Player/
├── scripts/GameManager.gd, Interactable.gd, ProgressGate.gd, NPCIdleSprite.gd, RoomProctorSprite.gd
├── scripts/autoload/GameState.gd
├── scripts/zones/ZoneHub.gd, ZoneScaffoldFloor.gd
├── scripts/zones/zone01/  MiniGame01Brake … MiniGame05Pulley
├── scripts/zones/zone02/  Zone02Entry, Deck, Capstone, MiniGame3
├── scripts/zones/zone03/  Zone03Entry, Deck, Capstone, MiniGame1–2
├── scripts/zones/zone04/  Zone04Entry, Deck, Capstone, MiniGame1
└── data/ zone01_floor*.json; zone02_room* + dialogue; zone03_room* + dialogue; zone04_room* + dialogue; zone05 scaffold JSON
```

Assets still: `res://asset/sprites/{character,Environment,animation,badge}` and `res://asset/music/`.

**Proposed target** (migrate later; do not break paths blindly):

```
asset/
├── characters/
├── environments/school|factory|powerplant|researchlab|observatory|industrial|energy/
├── machinery/
├── minigames/mg1_emergency_brake/ … mg5_pulley_rush/
├── minigames/energy_mg3_build_system/
├── ui/
├── vfx/
├── audio/{amb,music,sfx}/
├── fonts/
├── icons/
└── _raw/
```

Godot scenes stay under `final-godot/scenes/`.  
**Do not** move files without updating every `res://` path.

---

# 17. AUDIO ASSET PLAN

**Engine (2026-08-23):** `project.godot` sets `audio/driver/driver="Dummy"`. This is **not** missing game audio — it skips Windows WASAPI so Intel(R) UHD Graphics 620 device invalidation does not spam `GetBufferSize` / `output_device invalidated`. No `AudioStreamPlayer` is wired yet. **Clear Dummy** (empty driver = platform default WASAPI) when classroom/factory SFX are integrated. Editor-only spam still needs `--audio-driver Dummy` or a full editor restart.

### Existing (DOWNLOADED, unwired)

Classroom ambience, opening sting, chair scrape, wood footsteps, paper rustle, school bell, typewriter tick.

### Missing factory (P1 after MG1 exists)

Machinery hum, factory ambience, alarm, metal footsteps, stairs, door, quiz correct/incorrect, badge jingle, brake screech, gear clank, crane creak, hydraulic hiss, rope snap, motor whir.

### Zones 02–05

Map B per-floor loops (dock clank, drop-tower creak, shop grind) are **not** Zone 02 audio (superseded gameplay). Control-room hum may still apply.

Map C (Assessment Wing, §43) needs, still **MISSING**:

- Control Room electrical hum (scripted)
- Door unlock click + light change (Doors 2 and 3, then exit to Rina)
- Quiz fail / pass stingers (reuse Zone 01 quiz SFX if created)
- Engage / stall / rope-fray for “Build the System” (iteration, not GAME OVER buzzer)
- Radiant Crest award stinger

**Method:** B (licensed SFX) is acceptable for mechanical sounds; C is for unique music stingers if needed.

---

# 18. UI MASTER PLAN

| Component | Now | Need |
|---|---|---|
| World map | Painting + factory hotspot + **5 pins with LOCK overlay** | Custom pin art, unused select JPGs |
| Dialogue box | DialoguePanel | Optional portraits/nameplate art |
| Quiz | QuizPanel MCQ + short-answer LineEdit (Zone 02–04) | Factory GDD still wants more one-word items on Zone 01 |
| Door lock overlay | `energy_door_locked.png` on Entry (doors 2–3 + capstone) | Per-door lightbulb/gear/magnifier icons still optional |
| Live MA + efficiency HUD | Zone02 MiniGame3 labels | — |
| Engage / rebuild (no hard fail) | Zone02 MiniGame3 | — |
| Radiant Crest | `crest radiant.png` on Capstone + MG3; flag on win | Award stinger still missing |
| Correct/incorrect | Text feedback | Icons optional |
| Progress / countdown | Missing | MG1/MG3 |
| Badge collection | Flags only | Show `momentum_crest`, `spectrum_crest`, `spark_emblem` |
| Pause / retry / GAME OVER | Missing | MG fail path |
| PROBLEM SOLVED banner | Missing | MG1 |
| Interaction icon | Missing | Optional P2 |
| Godot theme / fonts | Default | P2 |

**Programmer UI (Method E)** is enough for defense MVP; custom art is P2.

---

# 19. CURRENT STATE SUMMARY (ONE PAGE)

**Rebuild root `d:\capstone 2` (2026-09-20) — authoritative playable entry**

- Main scene: `scenes/ui/MainMenu.tscn` (art: `asset/sprites/load game screen.png`)
- Autoloads: `GameState`, `SceneTransition`, `SaveManager`
- Profile save/load: `user://profiles/` — New Game / Load Game / in-game **S** after checkpoint; **no autosave**
- Details: `Docs/PROGRESS.md`, `Docs/SCENE_IMPLEMENTATION.md`

**What exists right now (legacy inventory block below; prefer rebuild notes above for save/menu)**

**CONFIRMED / PLAYABLE**

- Godot 4.7 GDScript project; rebuild autoloads **GameState**, **SceneTransition**, **SaveManager** (legacy text below may still mention GameManager / SceneManager / BadgeManager / F5 from the older `final-godot` tree)
- School cutscene (teacher + seated student + dialogue + walk + fade)
- World map: `worldmap_background.png` + five landmark props; Zones 02–05 locked until previous zone’s **last mini-game** (not the capstone verdict)
- Zone 01 Exterior: `factory_exterior`, Guard sprite + E-talk + gate, walkable Player
- Zone 01 Floors 1–4: refined factory PNGs, manager/Director idle crops, 80% MCQ, **profile-based room + obstacle collision**, stair lock, Director emergency lines
- Zone 01 Mini-Games 1–5: real physics UI; fail reloads MG1; MG5 awards Momentum Crest + unlocks Zone 02
- **Zone 02 Map C** Entry → three rooms (80%) → Rina verdict → Build the System → Radiant Crest → Zone 03 — **WASD roam + furniture collision**
- **Zone 03 Signal Station** Entry → four decks (80%) → Anwar verdict → Signal Path → Optical System → Spectrum Crest → Zone 04 — **WASD roam + collision**
- **Zone 04 The Substation** Entry → five bays (80%) → Proma verdict → Build the Generator → Spark Emblem → Zone 05 — **WASD roam + collision**
- Zone 05 **scaffold** Hub / Floor 1–4 / Capstone (ColorRect + 80% MCQ)
- Dialogue + quiz UI (MCQ + short answer)
- Player movement on Zone 01–04 rooms and Exterior (`RoomWalkController` + `room_collisions.json`)
- Headless `verify_project.gd` (**717 checks, 0 failures**; re-run 2026-08-23 with Dummy audio)
- `project.godot` audio driver **Dummy** until SFX are wired (WASAPI skip on this Windows laptop)
- School door vanish fixed: player sheet is 1980×1080; atlas crops were still 2816×1536 (walk-back/left sat off the texture)

**DOWNLOADED BUT NOT INTEGRATED (or only chroma-key crop)**

- All Zone 04 NPC sheets — missing
- Momentum Crest badge PNG / ceremony UI
- Packed MG3 prop sheet (`other.png`) — Create-MG uses button toggles, not sliced props
- Per-door difficulty icons (lightbulb / gear / magnifier) — optional; doors use text + lock overlay
- Power plant & research lab select JPGs
- School audio pack

**PARTIALLY READY**

- Factory zone navigation, quizzes, emergency run
- Exterior (yard strip, not school→factory overworld)
- NPC crops: Zone 01 managers/guard (chroma-key); Zone 02 packed sheets; Zone 03 **full cast** single-idle PNGs

**NOT READY**

- School→factory walk with road signs
- Factory audio (driver is Dummy until then; see §17)
- Full badge ceremony UI (flags + preview art exist for Radiant/Spectrum/Spark)
- Energy Mini-Games 1–2 (sort / diagnose) — **NOT YET DESIGNED**
- Zone 05 **finished** gameplay (**scaffold exists**; identity not locked)
- Zone 04 bay proctor sprites (missing sheets)
- Custom fonts/icons
- Trained 50×4 question banks
- Scientist battle / flash-card combat

**Rough Zone 01 completeness:** quizzes/nav **~85%**; story beats **~75%**; minigames **~80%** (click UI, not GDD drag); audio integration **~0%**.

---

# 20. ROADMAP AND DEPENDENCIES

This is **one** practical path, not the only one.

| Phase | Focus | Depends on | Output |
|---|---|---|---|
| 1 | This master doc + PROGRESS.md | — | Shared truth |
| 2 | School + Factory **navigation polish** | Phase 1 | Guard sheet + exterior PNG + gate — **done 2026-08-18**; optional schoolyard still open |
| 3 | NPCs on floors (manager/director sprites) | Cropped PNG sheets | **Idle crops wired** (chroma-key); Photopea still open |
| 4 | Quiz content pass (still 5 Qs or expand) | JSON | Defense-ready questions |
| 5 | **Mini-Game 1** real | MG1 art + UI | **Done** — first real challenge |
| 6–9 | MG2–MG5 | Each previous MG; shared fail→MG1 | **Done** (click/toggle UI) |
| 10 | Crest + map unlock flag | MG5 | Zone 02 pin unlocks (**done as flag + GameState**; no badge UI) |
| 11 | Zone 02–05 **folder scaffold** | Phase 10 | Hub/Floors/Capstone placeholders (**done 2026-08-18**; Zones 02–04 later replaced) |
| 12 | Zone 02 **real content** (Map C locked) | §43 | Assessment Wing + Create MG — **done 2026-08-18** (MG1–2 skipped) |
| 13 | Zone 03 Signal Station | Task spec 2026-08-18 | **Done** — see §45 |
| 14 | Zone 04 The Substation | Task spec 2026-08-18 | **Done** — see §46 |
| 15 | Zone 05 / Hall of Physics Legends | Zone 04 clear + **identity lock** | **Next** (do not invent) |
| 16 | Integration, audio, NPC slice, SUS polish | Playable loop | Capstone defense |

**Do not** invent Mini-Games 1–2; **do not** paste Map B Floors 1–3 as those stations. **Do not** rebuild Zone 02 as ColorRect Hub/Floors.  
Do **not** invent Zone 05 rooms. Zone 03 Signal Station and Zone 04 The Substation are in Godot (§45–§46).

---

# 21. PRIORITY SYSTEM

| ID | Type | Task | Pri |
|---|---|---|---|
| P0-1 | Design | Lock Zone 02 identity (Map A vs B vs **C / §43**) | **DONE 2026-08-18 — Map C** |
| P0-1b | Design | Lock Zone 03 / 04 identity | **DONE 2026-08-18 — Signal Station / The Substation** |
| P0-2 | Design | Lock pass threshold 80% vs 75% | P0 |
| P0-3 | Prog | Keep School as main scene | P0 (done) |
| P1-1 | Asset+Prog | Wire Guard sheet; drop ColorRect | **DONE 2026-08-18** |
| P1-2 | Asset+Prog | Use `factory_exterior` or confirm cutaway is intentional | **DONE — exterior PNG** |
| P1-3 | Prog | Implement MG1 with existing ramp/block | **DONE** |
| P1-4 | Prog | GAME OVER → reload MG1 | **DONE** |
| P1-5 | Prog | Director emergency before MG chain | **DONE** |
| P1-6 | Content | Replace placeholder quiz items | P1 |
| P1-7 | Asset D | Rename/clean JPG NPC sheets → PNG | P1 |
| P1-8 | Asset+Prog | Slice Zone 02–03 NPC sheets into rooms | **DONE** Zone 02 + Zone 03 full cast |
| P2-1 | Audio | Play school SFX in cutscene | P2 |
| P2-2 | Asset | Schoolyard + road signs | P2 |
| P2-3 | UI | Badge screen | P2 |
| P2-4 | Prog | Floor 2–4 ActionBar / collision polish | P2 |
| P3-1 | Content | 50 questions × 4 floors | P3 |
| P3-2 | Design+Prog | Scientist battles | P3 |
| P3-3 | Asset C | Zone 02–05 worlds | P3 |
| P3-4 | Design | Energy Map C stations 1 (sort) and 2 (diagnose) — currently undesigned | P3 |
| P3-5 | Content | Map C banks: 15 MCQ / 10+5 / 5+10 as in §43 | **DONE** (JSON + QuizPanel) |
| P3-6 | Asset C | Rina, Nabila, Karim, Farah, Assessment Wing, Radiant Crest | **DONE** — rooms + proctors + crest UI + flag |

---

# 22. UNKNOWN / DECISION REQUIRED

Do **not** silently pick a side in code.

1. **Zone maps — DECIDED 2026-08-18:** Zone 02 = **Map C** (§43, Radiant Crest). Zone 03 = **Signal Station** (§45, Spectrum Crest). Zone 04 = **The Substation** (§46, Spark Emblem). Map A and Map B are superseded for 02–04 **gameplay**. Map B Hub + Control Room art language may still be used for Zone 02. Energy Mini-Games 1–2 remain **NOT YET DESIGNED** (item 16). Do not rebuild 03–04 as Matter Labs / Wave Observatory.
2. **Art: 2.5D vs 2D GDD lock.**
3. **Language:** GDScript (now) vs C# (proposal).
4. **Pass mark:** 80% everywhere in code vs 75% in one GDD quick-ref.
5. **Factory height:** 5-story illustration vs 4 playable floors + rooftop.
6. **Scene 2:** Player-controlled walk from school with road signs vs current cutscene→map→exterior.
7. **Quiz mix:** Factory GDD wants MCQ + one-word; Zone 01 is still MCQ-only. Zone 02 Rooms 2–3 and Zone 03 Decks 3–4 / Zone 04 Bays 4–5 use short answers.
8. **Floor 4 Continue** target: **DECIDED in Godot** — emergency lines then MG1.
9. **World map:** landscape bg + five landmark props; clickable when unlocked; `powerplant_select.jpg` / `researchlab_select.jpg` unused as pin art.
10. **Bilingual Bengali+English fonts:** mentioned, not specified.
11. **Sprite scale:** Player/School use **0.17**; future sheets must match.
12. **Reference filename:** `factory_asset_reference.png` vs `physics_quest_factory_asset_reference.png`.
13. **Scientist/flash-card battles:** in or out of MVP.
14. **Mini-game fail:** Factory docs = full MG1 restart; **coded** for Zone 01 MG1–5. Zone 02 Build the System is rebuild, not GAME OVER.
15. **Audio:** school files exist but are not connected — bug or not yet scheduled?
16. **Energy Mini-Games 1–2:** Map C Scene 5 names three stations (sort / diagnose / build). Only station 3 is specified and **implemented**. **Do not invent** MG1–2.
17. **Zone 02 badge name — DECIDED:** **Radiant Crest** (Map C). Spark Emblem is Zone 04 only.
18. **Map C after-badge beat:** script says fade to World Map (Zone 03 unlock) **and** “then return to the lab with Rina.” Sequence is unspecified. Godot currently fades to World Map.
19. **Map C vs Map B rooms — DECIDED:** Assessment Wing (3 quiz labs) is the quiz path. Map B Loading Dock / Drop Tower / Machine Shop are **not** Zone 02 rooms. Control Room art language is shared.
21. **Scaffold vs GDD:** Godot Zone **05** still uses Hub/Floor/Capstone **placeholders**. Zone 02 play path is §43. Zones 03–04 pins and scenes are canonical (Signal Station / The Substation).

---

# 23. PROGRESS.MD RULE

This master file is **baseline architecture plus chat-agreed specs**.

**Standing rule (2026-08-18, updated same day):**

1. **`docs/PHYSICS_QUEST_MASTER.md`** — update after **any** agreed work: code, scenes, assets on disk, **and** chat decisions (zone locks, asset lists, Nano Banana catalogs, poster copy, map picks). Do not leave this file describing an older spec.
2. **`docs/PROGRESS.md`** — update **only** after a real action: code, scenes, files written to disk, or a verify run. **Do not** append chat-only lists, poster drafts, or prompt catalogs here. If the user says “reply in chat,” do not edit PROGRESS.

Root `PROGRESS.md` is only a pointer to `docs/PROGRESS.md`.

`PROGRESS.md` must include: Current Status, Recently Completed, Currently Working On, Next Tasks, Blockers, Newly Added Assets/Scenes/Systems, Known Bugs, Decisions Made, Assets Still Missing, Next Recommended Action. **Use dates.** Only list items that reflect Godot/repo actions (or the living gameplay status those actions produced).

---

# 24. AI DEVELOPER RULES

1. Never assume an asset exists unless it is in §4 or you just added it.  
2. Never replace classroom/player/floor art without checking current scenes.  
3. Never invent a new visual style if `factory_asset_reference.png` or player/teacher sheets apply.  
4. Reuse: Floor 2 conveyor is already in the background PNG.  
5. Keep `snake_case` names; delete `(2)` duplicates.  
6. Keep pixel scale (Nearest, ~0.17 for characters).  
7. Gameplay-critical before decoration.  
8. Zone 02 play path **is** §43 Assessment Wing. Do **not** invent Mini-Games 1–2. Do **not** paste Map B Floors 1–3 as those stations. Do **not** rebuild Zone 02 as ColorRect Hub/Floors. Leave Zone 05 scaffold until that zone is in scope. Zones 03–04 are implemented (§45–§46).  
9. Label CONFIRMED vs PLANNED in every summary.  
10. If uncertain, ask; do not invent quiz science or zone stories.  
11. Update **this master** after any decision or chat spec. Update `docs/PROGRESS.md` only after code/scene/on-disk/verify actions.  
12. New assets on disk → §4 inventory. Chat-only prompts → §12.5 until files exist.  
13. New scenes → §3 scene list.  
14. New systems → §28 and PROGRESS.md.  
15. Do not claim minigames are done because placeholder tscn files exist. Zone 01 MG1–5 **are** implemented physics UI. Latest verify **580 / 0**.  
16. Do not claim Guard is done because a PNG exists — Guard **is** wired; Photopea cleanup is still open.  
17. Headless verify before calling a scene complete.  
18. F5 in-game resets save only; editor Play restarts the game.

---

# 25. QUICK START FOR A NEW AI

1. Open `final-godot/project.godot` — main scene School. Audio driver is **Dummy** until SFX exist (§17).  
2. Play: School cutscene → Map (5 pins; 02–05 locked until prior last-MG) → Factory Exterior (Guard) → floors → MG1–5.  
3. Read this file §19, §22, **§3.10–3.12**, §43–§46.  
4. Read `docs/PROGRESS.md`.  
5. Next scheduled work: **NPC slice / remaining character sheets**, then Zone 05 **only after identity lock**. Zone 01 Guard / Factory MG1–5 are implemented.  
6. Zone 02 = **Map C / §43 (in Godot)**. Zone 03 = **Signal Station / §45**. Zone 04 = **The Substation / §46**. Do not invent Zone 02 Mini-Games 1–2. Do not build Map B Matter Labs / Wave Observatory or Map A Research Lab / Observatory as 03–04.  
7. Zone 02 art: **§12.5–12.6**. Zone 03 art prompts: **§12.7**. NPC remaining: **Zone 04 cast only** **§12.8**. Poster: **§47**.  
8. After any **spec/chat/code** change, update **this master**. Update `PROGRESS.md` only if code, scenes, files on disk, or verify changed.

**Canonical paths**

- Godot: `final-godot/`  
- Art/audio: `asset/`  
- Design dumps: `docs/capstone,md.txt`, `docs/physics_quest_zones_02-05_gdd (2).md`, `docs/physics_quest_zone02_scene_design (2).md`

---

# 26. EVIDENCE SOURCES AND HOW TO USE THEM

A new AI must treat these as **separate** sources. Never merge them into one “everything is done” story.

| Source | Path / location | What it proves | What it does **not** prove |
|---|---|---|---|
| Godot project | `final-godot/` | Scenes, scripts, autoloads, main scene, pass threshold in code | That art on disk is used |
| Asset folder | `asset/` | Files downloaded/generated | That they are wired, cleaned, or final |
| Scene files | `final-godot/scenes/**/*.tscn` | What is actually instantiated | Visual quality |
| Headless verify | `scripts/tools/verify_project.gd` | Structural checks the script knows about | Gameplay fun, art polish, audio |
| Chat/GDD dump | `docs/capstone,md.txt` | Zone 01 story, 5 minigames, asset wishlists | Implementation |
| Zones 02–05 GDD | `docs/physics_quest_zones_02-05_gdd (2).md` | Map B curriculum skeletons (**superseded** for 02–04 gameplay) | That Matter Labs / Wave Observatory / Refinery floors are what to ship |
| Zone 02 scene design | `docs/physics_quest_zone02_scene_design (2).md` | Hub exterior + Control Room **art language**; Floors 1–3 **not** the quiz path | Built scenes |
| Map C Assessment Wing | This file **§43** (user script 2026-08-17) | **Canonical** Zone 02: 3 quiz rooms, Rina verdict, Create MG | Godot scenes, MG1–2 energy, art |
| This master | `docs/PHYSICS_QUEST_MASTER.md` | Baseline inventory dated 2026-08-17 | Live daily status |
| Living status | `docs/PROGRESS.md` | What changed after this baseline | Architecture |

**Proposal / capstone PDF** (C#, 12-week methodology, SUS, Hake’s gain) is **CONFIRMED IN DOCUMENTATION** only. It is **not** in this repo as a built evaluation system.

---

# 27. SCREENSHOT / VISUAL CONFIRMATION NOTES

The following matches **what the design request asked to document** plus **what Godot scenes actually contain**. If a screenshot was provided in chat, it is corroborating evidence for art, not for systems that are not in the `.tscn`.

## 27.1 School / opening — VISIBLE IN GAMEPLAY

**Status:** CONFIRMED / VISIBLE  
**Evidence:** `School.tscn` + `SchoolScene.gd` (and provided classroom screenshot if present in chat).

Visible / painted into `classroom.png` (not separate Godot nodes unless noted):

| Element | How it exists |
|---|---|
| Classroom room | Full-viewport TextureRect `classroom.png` |
| Teacher | Separate sprite `teacher_idle.png` |
| Student desks | Painted in background |
| Teacher desk | Painted in background |
| Blackboard + physics formulas | Painted in background |
| Clock | Painted in background |
| Globe | Painted in background |
| Windows | Painted in background |
| Player / student | `Sprite2D` AtlasTexture on `player_transparent.png` |
| Scene transition | Automated fade via `SceneManager` after walk-to-door (legacy Next Scene **hidden**) |

Cutscene behaviour **VISIBLE IN GAMEPLAY:** seated pose `Rect2(1236, 596, 301, 428)` on `player_transparent.png` (1980×1080) → teacher line → student “Understood, Sir…” → idle front → **tween into row gap** → **left along aisle** → **up to door** (back view) → World Map. Waypoints are **content-relative** (opaque classroom in `classroom.png`, left margin ~0.175 excluded): `TEACHER_NORM (0.60, 0.33)`, `DESK_NORM (0.42, 0.56)`, `ROW_GAP_NORM (0.42, 0.46)`, `AISLE_NORM (0.12, 0.46)`, `DOOR_NORM (0.08, 0.14)`. Scales: teacher `0.18`, student `0.13` + offset `(4, 16)`. Conversion: `_classroom_art_rect()`. Still a scripted tween (no desk colliders).

## 27.2 Zone 01 — Factory Floor 1 — VISIBLE IN GAMEPLAY

**Status:** CONFIRMED / VISIBLE  
**Evidence:** `Zone01_Floor1.tscn` + `factory_floor_1.png` (and provided Floor 1 screenshot if present).

Typical visible content of the floor painting (do not invent extra colliders): industrial floor, pipes, staircase area, factory lighting. Player WASD. Quiz/start interaction via dialogue + `QuizPanel`. Transition toward Floor 2 after ≥80%. Collision: baked `WallColliders`; player layer 1, mask 2; walls layer 2.

## 27.3 Zone 01 — Factory Floor 2 — VISIBLE IN GAMEPLAY

**Status:** CONFIRMED / VISIBLE  
**Evidence:** `Zone01_Floor2.tscn` + `factory_floor_2.png`.

Painted in the background (not separate animated nodes): conveyor language, robotic/industrial arms, machinery, pipes, crates, industrial equipment. Transition toward Floor 3 after quiz. **Do not** claim separate conveyor sprites exist just because they are painted.

## 27.4 What screenshots do **not** confirm

- Zone 02 **Assessment Wing** **is** implemented (§43; Entry–Rooms–Control–Build the System). `powerplant_select.jpg` is unused. Leftover `Zone02_Floor4` scaffold is unused.
- Floors 3–4 art exists in Godot; if a screenshot was not provided, still treat them as **VISIBLE IN GAMEPLAY** because the scenes launch in the playable chain.
- Minigame screenshots of ColorRect placeholders would **not** mean the physics games exist. Current Zone 01 MG1–5 **are** physics UI (not ColorRect Next).

---

# 28. GODOT SYSTEMS ARCHITECTURE

**CONFIRMED EXISTING**

| Piece | Path | Role |
|---|---|---|
| Engine | Godot 4.7, Forward Plus, Jolt 3D (unused for this 2D game) | — |
| Main scene | `res://scenes/School/School.tscn` | Launch |
| `GameManager` | `scripts/GameManager.gd` | Zone 01 flags + save file; merges GameState into JSON |
| `GameState` | `scripts/autoload/GameState.gd` | `is_zone_unlocked`, `unlock_next_zone`, floor-pass keys; radiant crest migrates Zone 03; spectrum crest migrates Zone 04; spark emblem migrates Zone 05. **`TRIAL_UNLOCK_ALL = true`** opens all World Map pins + interior doors for playtesting (not saved; verify forces it off). |
| `SceneManager` | `scripts/SceneManager.gd` | Fade + change scene |
| `BadgeManager` | `scripts/BadgeManager.gd` | `momentum_crest`, `radiant_crest`, `spectrum_crest`, `spark_emblem` flags (no badge ceremony UI) |
| Player | `scenes/Player/Player.tscn` | WASD on floors + Zone 01 Exterior |
| School student | `SchoolScene.gd` Sprite2D | Cutscene only; physics off while seated |
| `ZoneFloorController` | `scripts/ZoneFloorController.gd` | Dialogue → quiz → continue; Director `post_pass_lines` |
| `QuizManager` | `scripts/QuizManager.gd` | Loads JSON; default pass 0.80; `submit_short_answer` |
| `QuizPanel` | `scenes/UI/QuizPanel.tscn` | MCQ + `ShortAnswer` LineEdit |
| `DialoguePanel` | `scenes/UI/DialoguePanel.tscn` | One line + Continue |
| `FloorRoomSetup` | `scripts/FloorRoomSetup.gd` | Runtime walls on some floors |
| `Interactable` / `ProgressGate` | `scripts/Interactable.gd`, `ProgressGate.gd` | E-talk; collision lock until grant |
| `NPCIdleSprite` | `scripts/NPCIdleSprite.gd` | First idle cell + chroma-key |
| `PlaceholderScene` | leftover minigame helper | **Not** used by Zone 01 MG1–5 |
| `ZoneHub` / `ZoneScaffoldFloor` | `scripts/zones/` | Zone **05** placeholder UI (Zone 02 leftover Floor4) |
| Zone 01 MG scripts | `scripts/zones/zone01/` | Brake, Gear, Balance, Pressure, Pulley |
| Zone 02 scripts | `scripts/zones/zone02/` | Assessment Wing + Build the System |
| Zone 03 scripts | `scripts/zones/zone03/` | Signal Station scenes |
| Zone 04 scripts | `scripts/zones/zone04/` | Substation scenes |
| Verify | `scripts/tools/verify_project.gd` | Headless `--script` |

**Run headless verify (CONFIRMED EXISTING workflow):**

```text
Godot_v4.7.1-stable_win64_console.exe --path final-godot --headless --audio-driver Dummy --script res://scripts/tools/verify_project.gd
```

Godot exe used in this project’s notes: `D:\Download\Godot_v4.7.1-stable_win64_console.exe` — **UNKNOWN** if that path exists on every machine; do not invent another path.

**Input:** WASD + arrows + `interact` (E and F) (`project.godot`).  
**Stretch:** `canvas_items` + `expand`.  
**F5:** resets save flags only; **does not reload** the running scene.

**Scene graph (playable):**

```text
School.tscn
 → WorldMap.tscn
   → Zone01_Exterior.tscn
     → Zone01_Floor1.tscn
       → Zone01_Floor2.tscn
         → Zone01_Floor3.tscn
           → Zone01_Floor4.tscn
             → MiniGame01_Brake.tscn   (real; fail → MG1)
               → MiniGame02_Gear.tscn
                 → MiniGame03_Balance.tscn
                   → MiniGame04_Pressure.tscn
                     → MiniGame05_Pulley.tscn
                       → WorldMap.tscn  (Momentum Crest + Zone 02 unlock)
   → Zone02_Entry.tscn
     → Floor1–3 rooms → Capstone → MiniGame3 → WorldMap (Radiant Crest + Zone 03)
   → Zone03_Entry.tscn … MiniGame2 → WorldMap (Spectrum Crest + Zone 04)
   → Zone04_Entry.tscn … MiniGame1 → WorldMap (Spark Emblem + Zone 05)
   → Zone05_Hub.tscn (scaffold)
```

---

# 29. QUESTION-BANK INVENTORY

**CONFIRMED EXISTING** under `final-godot/data/`:

| File | Floor | Questions in file | Pass in JSON | Bloom tags present? |
|---|---|---|---|---|
| `zone01_floor1_questions.json` | 1 | 5 | 0.80 | Yes (Remember / Understand / Apply on items) |
| `zone01_floor2_questions.json` | 2 | 5 | 0.80 (if same pattern) | Check file; do not assume 50 |
| `zone01_floor3_questions.json` | 3 | 5 | 0.80 | Same |
| `zone01_floor4_questions.json` | 4 | 5 | 0.80 | Same |

| `zone02_room1_questions.json` | Assessment Wing Room 1 | 15 MCQ | 0.80 | Map C bank |
| `zone02_room2_questions.json` | Room 2 | 10 MCQ + 5 short | 0.80 | Map C bank |
| `zone02_room3_questions.json` | Room 3 | 5 MCQ + 10 short | 0.80 | Map C bank |
| `zone02_dialogue.json` | Assessment Wing lines | — | — | Rina / Nabila / Karim / Farah |
| `zone02_floor1_questions.json` … `floor4` + `zone02_capstone_questions.json` | Leftover scaffold | 5 each | 0.80 | **Unused** play path |
| `zone03_room1_questions.json` | Signal Station Deck 1 | 15 MCQ | 0.80 | Original syllabus bank |
| `zone03_room2_questions.json` | Deck 2 | 15 MCQ | 0.80 | Original |
| `zone03_room3_questions.json` | Deck 3 | 12 MCQ + 3 short | 0.80 | Original |
| `zone03_room4_questions.json` | Deck 4 | 12 MCQ + 8 short | 0.80 | Original |
| `zone03_floor1` … `floor4` | Same banks as room1–4 (legacy filenames) | same | 0.80 | Mirrors |
| `zone03_capstone_questions.json` | Unused leftover from Matter Labs scaffold | 5 | 0.80 | Capstone is dialogue, not this quiz |
| `zone03_dialogue.json` | Signal Station lines | — | — | Anwar / Tania / Milon / Shirin / Farid |
| `zone04_room1_questions.json` | Substation Bay 1 | 10 MCQ | 0.80 | Original |
| `zone04_room2_questions.json` | Bay 2 | 15 MCQ | 0.80 | Original |
| `zone04_room3_questions.json` | Bay 3 | 15 MCQ | 0.80 | Original |
| `zone04_room4_questions.json` | Bay 4 | 10 MCQ + 5 short | 0.80 | Original |
| `zone04_room5_questions.json` | Bay 5 | 12 MCQ + 8 short | 0.80 | Original |
| `zone04_floor1` … `floor4` | Same as room1–4 (legacy filenames) | same | 0.80 | Mirrors |
| `zone04_capstone_questions.json` | Unused leftover from Wave Observatory scaffold | 5 | 0.80 | Capstone is dialogue, not this quiz |
| `zone04_dialogue.json` | Substation lines | — | — | Proma / Rumi / Dipa / Sabbir / Nusrat / Imran |
| `zone05_floor1` … `capstone` | Citadel scaffold | 5 each | 0.80 | Placeholder |

**CONFIRMED IN DOCUMENTATION (not built as full banks):** 50 questions per floor, 200 per zone, MCQ + one-word mix (Map B). Map C **15 + 15 + 15** mixed items **are** in `zone02_room1–3_questions.json` (§43). Those are **not** the leftover 5-question scaffold files.

**VISIBLE IN GAMEPLAY:** `QuizPanel` supports MCQ and typed short answers. Zone 01 banks remain MCQ-only.

Floor 1 sample (CONFIRMED EXISTING content, placeholder quality): SI unit of force; momentum = mv; Newton’s First Law; F=ma numerical; etc. These are **not** the trained Bloom bank from the proposal.

---

# 30. DUPLICATE-FILE AND IMPORT HYGIENE

Windows copy suffixes **CONFIRMED EXISTING** throughout `asset/`:

- `filename (2).png` / `.ogg` / `.jpg` next to the canonical file
- `filename.png (2).import` Godot import clones
- Spaces: `manager 1.jpg`
- Typos: `guard_shee`, `pully`, `guage`

**Rule:** Godot should reference **only** the name without `(2)`. `(2)` copies caused UID warnings. One duplicate `.tres` (`player_sprite_frames (2).tres`) was deleted; **many image/audio `(2)` files remain**.

Do not delete `(2)` files in bulk without checking Godot `.tscn` paths first. Prefer: stop importing them, then delete after a verify pass.

---

# 31. GAMEPLAY-CRITICAL VS DECORATIVE

Use this when choosing Nano Banana work. **P0/P1 before decoration.**

## Gameplay-critical (Zone 01 MVP)

| Asset / system | Why critical | Status |
|---|---|---|
| Player readable sprite | Movement identity | CONFIRMED EXISTING (wired) |
| Teacher idle | School beat | CONFIRMED EXISTING (wired) |
| Classroom, floors 1–4, world map | Navigation | CONFIRMED EXISTING (wired) |
| Quiz + dialogue UI | Assessment | CONFIRMED EXISTING (Godot UI) |
| Guard sprite in Exterior | GDD entrance beat | CONFIRMED EXISTING (wired; chroma-key) |
| Manager / Director crops | Floor experts | CONFIRMED EXISTING (wired; JPG chroma-key) |
| MG1 ramp + block | First real challenge | CONFIRMED EXISTING (wired in MG1) |
| Fail → MG1 restart logic | Emergency run | CONFIRMED EXISTING |
| Momentum Crest display | Zone reward | Flag awarded; ceremony UI MISSING |
| Pass-threshold consistency | Pedagogy | 80% in code; 75% in one doc |

## Important but not blocking a first MG1 demo

Schoolyard, factory SFX, badge ceremony, Photopea NPC sheets, extra gears/pulleys.

## Decorative / later

Extra workers, confetti, rooftop Floor 5, pipe variants, scientist battles, Zone 05 world, bilingual custom fonts.

**Do not** generate observatory telescopes before remaining NPC sheets are sliced.

---

# 32. FULL FACTORY SCENE SCRIPT (DOCS VS GODOT)

Authoritative story beats: `docs/capstone,md.txt` (user messages dated 2026-08-17). **CONFIRMED IN DOCUMENTATION.**

| # | Documented beat | Godot 2026-08-18 |
|---|---|---|
| 1 | Classroom: teacher assigns field work; back-bencher; leave classroom; black cutout | **Partial:** assignment is 80% line, not full “visit five sites / collect badges” speech. Leave classroom **yes**. Schoolyard **no**. |
| 2 | Appear in front of school; **player-controlled** walk to factory; **road signs** | **MISSING** — World Map substitutes |
| 3 | Guard greets (expected him; assignment not turned in); **steps left**; door revealed; enter; black cutout | **Yes:** Guard sprite + E-talk + tween left + `ProgressGate`. Door is the painting, not a separate sprite. |
| 4 | Floor 1: machinery; manager blocks stairs; quiz ≥80%; manager moves; stairs | **Partial:** quiz + manager idle crop + **collision** stair lock. Manager does not walk aside. |
| 5–6 | Floors 2–3 same pattern, different machinery | **Partial:** same as Floor 1 (quiz + manager crop + stair barrier) |
| 7 | Floor 4: Director working, “tangled with work,” quiz >80%, about to give badge, **phone emergency**, player offers help, minigames | **Yes:** Director crop + `post_pass_lines` then MG1. No unique office painting. |
| 8 | Five minigames one run; any GAME OVER → MG1 | **Yes** (click/toggle UI; documented numbers). Drag-and-drop GDD not used. |
| 9 | Momentum Crest; World Map unlocks Zone 02 | **Yes** as flags + pin unlock. **No** badge ceremony UI. |

**Contradiction in the same dump:** one summary says Director receives the player on the **ground floor** and sends them to Floor 1; the scene script says Guard at the door and Manager on Floor 1, Director on Floor 4. **UNKNOWN / REQUIRES DECISION.** Do not invent a third version. Current Godot: Exterior Guard → Floor 1 manager → Floor 4 Director.

---

# 33. FULL MINI-GAME DESIGN SPECS (AUTHORITATIVE GDD)

Source: `docs/capstone,md.txt`. Status of **all five** in Godot: **IMPLEMENTED** as click/toggle physics UI (`scripts/zones/zone01/MiniGame0X*.gd`). Numbers below are **CONFIRMED IN DOCUMENTATION** and used in those scripts. Drag-and-drop, screech VFX, and unique fail banners remain GDD polish, not shipped.

## 33.1 MG1 — Emergency Brake (Friction)

- Physics: \(f = \mu mg\), Newton’s Second Law, deceleration  
- View: side-view ramp; metal block sliding; speed indicator; red countdown (crash at zero)  
- Data: mass **40 kg**; steel on concrete; \(\mu = 0.35\); distance **7 m**  
- Step 1: Does friction alone stop the block? **YES / NO**. Correct = **NO**  
- Step 2: extra braking force, 3 options (one correct)  
- Success: decelerate, screech, dust, green **PROBLEM SOLVED**  
- Fail: crash, sparks, alarm, GAME OVER + factory damage  
- Assets: see §7; existing loose files `mg1_ramp_bg.png`, `mg1_block (1).png`

## 33.2 MG2 — Gear Swap (Gear Ratios)

- Physics: gear ratio = driven teeth ÷ driving teeth; output RPM  
- Empty slot highlighted red; smoke from broken housing; RPM meter at 0  
- Target RPM example: **150–200**; formula card: Output RPM = Input RPM × (input teeth ÷ output teeth)  
- Four gears with tooth counts; drag into slot  
- **Test before confirm** (one preview swap); confirm wrong → belt snap GAME OVER  
- Existing: `mg2_housing.png`, `mg2_gear_a (1).png` (need more sizes)

## 33.3 MG3 — Counterweight Balance (Moments)

- Physics: \(F_1 d_1 = F_2 d_2\)  
- Crane, conical load descending; left progress bar = timer  
- Load **300 N** at **2 m**; CW point **3 m** right  
- Weights: **150 / 180 / 200 / 220 / 250 N**  
- \(F_2 = (F_1 \times d_1) / d_2\) → click block → **Place** (no preview)  
- Timeout or wrong → crash GAME OVER  
- Existing: `crane.png`, `load (1).png`, `weights (1).png` (may be a sheet — slice required)

## 33.4 MG4 — Pressure Panic (Pascal)

- Physics: \(P = F/A\), \(P_{in} = P_{out}\)  
- Two pistons + pipe; safety valve needs exact pressure  
- Gauge zones: green safe, yellow too low, red burst  
- \(A_{in} = 0.02\,\mathrm{m}^2\), \(A_{out} = 0.10\,\mathrm{m}^2\), \(P_{out} = 5000\,\mathrm{Pa}\)  
- Force buttons **60 / 100 / 140 N**  
- Slow dramatic needle; green → steam; else GAME OVER  
- Existing: `press.png`, `guage (2).png`

## 33.5 MG5 — Pulley Rush (Mechanical Advantage)

- Physics: \(MA = \mathrm{Load}/\mathrm{Effort}\), Work = F × d  
- Empty rig; engine block; motor max **150 N**; load **600 N**; need **MA ≥ 4**  
- Drag: single fixed, single movable, double movable, rope spool  
- Live MA readout; rearrange free until **Engage Motor**  
- Success: lift + Director clap; fail: rope snap  
- Existing: `rig.png`, `pully (1).png`; motor / extra pulley types **MISSING** or unconfirmed as separate files

## 33.6 Emergency run rule

Any GAME OVER → restart **Mini-Game 1**. All five in one continuous run. **NOT IMPLEMENTED.**

---

# 34. COMPLETE NANO BANANA PROMPT CATALOG

## 34.1 Master template (copy exactly, then replace the last sentence)

```text
Create a game-ready pixel-art asset for Physics Quest, a retro 2.5D educational physics RPG.
Use the uploaded factory_asset_reference.png as the primary visual style reference.
Match its pixel density, dark outlines, muted industrial purple-gray palette, shading, proportions, and mechanical design language.
Create only the requested object, centered, isolated, transparent background, no text, no UI, no extra objects, no background scene.
Do not use photorealism or 3D rendering. Pokémon Emerald-inspired readability. One asset only.
```

Then add the **subject sentence** from the tables below.

## 34.2 Factory / mechanical (upload `factory_asset_reference.png`)

| Output filename | Subject sentence to append | Pri | Method if file already exists |
|---|---|---|---|
| `factory_conveyor_belt.png` | Create a side-view industrial conveyor belt segment with a flat top and visible rollers. | P1 | Floor 2 already paints a belt — generate only if you need a **separate moving sprite** |
| `factory_conveyor_belt_broken.png` | Same belt with a snapped belt and a small puff of smoke, still a single isolated object. | P1 | MG2 |
| `factory_movable_crate.png` | Small wooden crate, three-quarter top-down, readable silhouette, no labels. | P2 | Decorative / Map B crate game later |
| `factory_heavy_crate.png` | Larger darker crate with metal corners that reads as heavier. | P2 | |
| `factory_pressure_plate.png` | Recessed metal floor pressure plate, top-down. | P2 | |
| `factory_switch_industrial.png` | Chunky wall lever switch, isolated. | P2 | |
| `factory_spring_mechanism.png` | Metal coil spring standing upright, isolated. | P2 | |
| `factory_fulcrum.png` | Triangular fulcrum block for a lever, isolated. | P2 | |
| `factory_gear_assembly.png` | Two meshed gears on a small mount, isolated. | P1 | Prefer extra MG2 gears first |
| `factory_control_panel.png` | Chunky factory control panel with blank gauges and no readable numbers. | P2 | |
| `factory_pipe_valve.png` | Short pipe segment with a wheel valve, isolated. | P3 | Decorative |
| `factory_metal_platform.png` | Simple metal grated platform tile, isolated, no scene. | P3 | |
| `mg2_gear_small.png` | Small industrial spur gear, few teeth, isolated, no numbers. | P1 | Have `mg2_gear_a` — this is extra sizes |
| `mg2_gear_medium.png` | Medium spur gear, more teeth than small, isolated. | P1 | |
| `mg2_gear_large.png` | Large spur gear, many teeth, isolated. | P1 | |
| `mg2_empty_slot.png` | Empty circular gear housing hole, slight red highlight baked in, isolated. | P1 | Or Godot ColorRect |
| `mg3_weight_150n.png` | Single rectangular weight block, isolated, **no text** (we add 150 N in Godot). | P1 | Slice `weights (1).png` first (Method D) |
| `mg4_steam_puff.png` | Small steam puff VFX, isolated, transparent. | P2 | |
| `mg4_pipe_burst.png` | Burst pipe with water/steam spray, isolated. | P2 | |
| `mg5_pulley_fixed.png` | Single fixed pulley wheel with a bracket, isolated, no rope text. | P1 | Cleanup `pully (1).png` first |
| `mg5_pulley_movable.png` | Single movable pulley block, isolated. | P1 | |
| `mg5_pulley_double.png` | Double movable pulley block with two wheels, isolated. | P1 | |
| `mg5_rope_spool.png` | Industrial rope spool, isolated. | P1 | |
| `mg5_motor.png` | Small industrial motor, isolated. | P1 | |
| `mg1_sparks.png` | Spark burst VFX for a crash, isolated. | P2 | |
| `mg1_dust.png` | Dust puff VFX for a screech stop, isolated. | P2 | |
| `ui_banner_problem_solved.png` | Optional pixel banner shape **with no text** (text in Godot). | P2 | Method E preferred |
| `npc_factory_worker.png` | See character prompts below. | P3 | |

## 34.3 Character prompts

**Guard** — Method D first on `guard_shee (1).png`. Only if unusable:

Upload: `player_transparent.png` + `factory_asset_reference.png`

```text
Create a game-ready pixel-art factory security guard for Physics Quest.
Match the uploaded player sheet’s body proportions, pixel density, dark outlines, and top-down / three-quarter camera.
Idle front pose only, factory uniform, isolated, transparent background, no pose labels, no photorealism, no text.
```

**Worker** — same uploads as Guard:

```text
Create a game-ready pixel-art factory worker for Physics Quest.
Match the uploaded player sheet’s proportions and pixel density.
Idle front pose only, industrial coveralls, isolated, transparent background, no text, no extra tools unless a single wrench in hand.
```

**Director / Manager** — do **not** regenerate until Method D (crop existing JPG sheets) is tried. Existing files: `director_sheet.jpg`, `manager 1.jpg`, `manager 2.jpg`, `manager 3.jpg`.

## 34.4 Other-zone prompts (P3 — zone map unlocked first)

Upload `powerplant_select.jpg` + `factory_asset_reference.png`:

```text
Create a game-ready pixel-art electrical generator, isolated, transparent background, no text, matching the uploaded industrial pixel style. Physics Quest asset.
```

```text
Create a game-ready pixel-art industrial turbine, isolated, transparent background, no text, matching the uploaded industrial pixel style.
```

Upload `researchlab_select.jpg`:

```text
Create a game-ready pixel-art laboratory electromagnet coil, isolated, transparent background, no text, matching the uploaded scientific pixel style.
```

```text
Create a game-ready pixel-art horseshoe or lab magnet, isolated, transparent background, no text.
```

Observatory / thermodynamics: **do not mass-generate**. No on-disk style target. Mark **NOT YET DESIGNED**.

---

# 35. ZONE 02–05 DOCUMENTED DESIGNS (MAP B)

These Map B pages are **historical** for Zones **02–04 gameplay**. Canonical: Zone 02 **§43**, Zone 03 **§45**, Zone 04 **§46**. Hub exterior and Control Room descriptions may still guide Zone 02 **art**. Do **not** build Loading Dock / Drop Tower / Machine Shop, Matter Labs, or Wave Observatory as shipped zones.

## 35.1 Shared Map B skeleton (docs)

Each zone: 4 floors, Bloom tiers, **50 questions/floor**, one signature mini-game per floor, capstone on top. This **conflicts** with Zone 01’s “quizzes on floors + five emergency minigames after Floor 4.” Zone 02 **does not** follow this skeleton (Map C: 3 quiz rooms + stations). Zones 03–04 also did not ship 50 questions per floor.

## 35.2 Zone 02 Energy Refinery (Map B GDD — SUPERSEDED gameplay)

NPC: **Foreman Rina** (still used in Map C). Theme: potential → kinetic; fault is inefficiency (flavor only unless it appears in §43).

| Floor | Topic | Mini-game (docs) | Proposed rooms (scene design doc) | Zone 02 status |
|---|---|---|---|---|
| Hub | Entry | — | Exterior / hub, amber pipes, Rina at gate | **Art OK** (Map C hub) |
| 1 | Work & Power W=Fd, P=W/t | Loading Dock crate push + timer | Wide dock, force gauge, distance ticks | **Do not build** as a quiz room |
| 2 | KE/PE conservation | Drop Tower + pendulum | Tall rail, height markers | **Do not build** as a quiz room |
| 3 | Simple machines, MA | Machine Shop benches | Lever / pulley / ramp benches | **Do not build** as a quiz room |
| 4 | Efficiency capstone | Fix the Refinery chained system | Control room, schematic | **Art OK** (Map C Scene 5); capstone game is Create-MG, not this chained-upgrade MG |

Assets listed in that GDD (spec only): Rina sheet, workers, crates, force meter, drop tower, pendulum, modular machines, per-floor audio loops.

On disk today: **`powerplant_select.jpg` only** (Map A flavor). **No** Rina sprite. **No** Assessment Wing floors.

## 35.3 Zone 03 Matter Labs (Map B skeleton — SUPERSEDED)

Map B GDD describes Matter Labs (states of matter, pressure, density, buoyancy). **Do not implement.** Canonical Zone 03 is **Signal Station** (§45). Disk: `researchlab_select.jpg` unused.

## 35.4 Zone 04 Wave Observatory (Map B skeleton — SUPERSEDED)

Map B GDD describes Wave Observatory (thermal, heat, waves, sonar). **Do not implement.** Canonical Zone 04 is **The Substation** (§46). Disk: no unique env art.

## 35.5 Zone 05 Light & Circuits Citadel (skeleton, provisional)

Floors: mirrors; lenses; Ohm circuits; electromagnet lift. Docs flag possible split **05a/05b**. Disk: **nothing found**.

## 35.6 Map A proposed rooms (SUPERSEDED for Zones 02–04)

Map A did **not** win for Zones 02–04. Historical list only:

- Power Plant: exterior, entrance, generator, turbine, control, electrical challenge, quiz, final, Spark Emblem  
- Research Lab: magnetism challenge, Flux Badge  
- Observatory: optics, Lens Token  
- Industrial: thermodynamics, Heat Sigil  

Do not treat that list as Floor 1–4 locked design.

---

# 36. UI COMPONENT MASTER LIST

| Component | Required by | Now | Method |
|---|---|---|---|
| World map | Navigation | Painting + 1 hotspot | A + E |
| Zone markers (5) | Map | 1 factory only | E / C |
| Locked zone icon | Map | Missing | E or icon PNG |
| Dialogue box | Story | DialoguePanel | E done |
| Character nameplate | Story | Partial / text in line | E |
| Question box | Quiz | QuizPanel | E done |
| MCQ buttons | Quiz | QuizPanel | E done |
| One-word answer input | GDD | **Missing** | E |
| Submit button | Quiz | Present for MCQ | E |
| Correct / incorrect feedback | Quiz | Text | E; icons P2 |
| Explanation panel | Quiz | In panel | E |
| Progress bar | MG1/MG3 | Missing | E |
| Countdown | MG1 | Missing | E |
| Badge display | Zone clear | PNG unused | E + A |
| Inventory / badge collection | Meta | Missing | E |
| Pause menu | Polish | Missing | E |
| Retry button | MG fail | Missing | E |
| Continue button | Floors | Present | E |
| Interaction icon | Optional | Missing | C or E |
| Success banner PROBLEM SOLVED | MG1 | Missing | E |
| Failure banner GAME OVER | MG | Missing | E |
| Godot default theme | All UI | In use | — |
| Custom fonts | Bilingual? | Folder empty | B + UNKNOWN |

---

# 37. AUDIO REQUIREMENT MATRICES

## 37.1 School pack — DOWNLOADED, not played

| File | Suggested use | Wired? |
|---|---|---|
| `amb_classroom.ogg` | School loop | No |
| `music_opening_sting.ogg` | After teacher line / fade | No |
| `sfx_chair_scrape.ogg` | Stand up from desk | No |
| `sfx_footsteps_wood.ogg` | Walk to door | No |
| `sfx_paper_rustle.ogg` | Assignment beat | No |
| `sfx_school_bell.ogg` | Scene start | No |
| `sfx_typewriter_tick.ogg` | Dialogue optional | No |

Duplicates `(2)` exist for each; use canonical names only.

## 37.2 Factory / MG — MISSING (P1 after MG1 exists)

| Cue | Suggested filename | Pri |
|---|---|---|
| Machinery hum loop | `amb_factory.ogg` | P1 |
| Factory ambience | `amb_factory_floor.ogg` | P1 |
| Alarm / siren | `sfx_alarm.ogg` | P1 |
| Metal footsteps | `sfx_footsteps_metal.ogg` | P2 |
| Stair climb | `sfx_stairs.ogg` | P2 |
| Door / guard move | `sfx_door_metal.ogg` | P2 |
| Quiz correct | `sfx_quiz_correct.ogg` | P1 |
| Quiz incorrect | `sfx_quiz_wrong.ogg` | P1 |
| Badge reward | `sfx_badge_jingle.ogg` | P2 |
| Brake screech | `sfx_mg1_screech.ogg` | P1 |
| Crash | `sfx_mg1_crash.ogg` | P1 |
| Gear clank | `sfx_mg2_clank.ogg` | P1 |
| Belt snap | `sfx_mg2_snap.ogg` | P1 |
| Crane creak | `sfx_mg3_creak.ogg` | P1 |
| Impact | `sfx_mg3_crash.ogg` | P1 |
| Hydraulic hiss | `sfx_mg4_hiss.ogg` | P1 |
| Pipe burst | `sfx_mg4_burst.ogg` | P1 |
| Motor whir | `sfx_mg5_motor.ogg` | P1 |
| Rope snap | `sfx_mg5_snap.ogg` | P1 |
| Voice blip | `sfx_dialogue_blip.ogg` | P3 |

Method B (licensed SFX) is preferred over generating audio in image tools.

## 37.3 Zones 02–05

Map B dock/tower/shop loops are **not** Zone 02 audio. Map C Assessment Wing SFX: control hum, door unlock, quiz stingers, Engage/stall/fray, Radiant Crest — **MISSING**. No files.

---

# 38. CHARACTER POSE AND ANIMATION MATRIX

| Character | Idle front | Side | Back | Walk | Talk | Special | On disk | In scene |
|---|---|---|---|---|---|---|---|---|
| Player | Yes (sheet) | Yes | Yes | Partial SpriteFrames | Distinct talk **unconfirmed** | Seated crop used in School; climb stairs **MISSING** | player_transparent | School + floors |
| Teacher | Idle crop | Sheet unused | — | — | — | — | teacher_idle wired; full sheets unused | School |
| Guard | Sheet likely | Sheet likely | — | — | — | Side-step **MISSING as anim** | guard_shee unused | ColorRect |
| Manager 1–3 | JPG sheets | JPG | — | — | — | Shift off stairs **MISSING** | Unused JPG | Text only |
| Director | JPG | JPG | — | — | — | Worried / clap **unconfirmed as separate files** | Unused JPG | Text only |
| Workers | — | — | — | — | — | Working pose | **MISSING** | — |
| Foreman Rina | Packed sheet | Sheet | Sheet | Partial walk frames | Arms crossed idle | Gesture/turn in sheet unclear | `rina.png` unused | ColorRect scaffold |
| Assistant Nabila | Packed | Packed | Packed | — | Clipboard | Map C §43 | `farah karim and nabila.png` unused | — |
| Assistant Karim | Packed | — | — | — | Arms folded / glasses variants | Map C §43 | same sheet unused | — |
| Assistant Farah | Packed | Packed | Packed | — | Precise | Map C §43 | same sheet unused | — |
| Chief Anwar | Idle PNG | — | — | — | Hands on hips | Transparent | `char_anwar_idle.png` | Entry + Capstone |
| Tania | Idle PNG | — | — | — | Clipboard | Transparent | `char_tania_idle.png` | Deck 1 |
| Milon | Idle PNG | — | — | — | Headphones / meter | Transparent | `char_milon_idle.png` | Deck 2 |
| Shirin | Idle PNG | — | — | — | Clipboard / glasses | Transparent | `char_shirin_idle.png` | Deck 3 |
| Farid | Idle PNG | — | — | — | Scanner + clipboard | Transparent | `char_farid_idle.png` | Deck 4 |
| Z04 Proma–Imran | **MISSING** | — | — | — | Idle-front §12.8 | Remaining | — | Dialogue only |

Player scale in School/floors notes: **~0.17**. Match when cropping NPC idle frames (~429×587 teacher idle as a size hint, not a law).

---

# 39. GODOT IMPORT AND SPRITE-SCALE RULES

1. Import as **2D**.  
2. Filter: **Nearest**.  
3. No lossy 3D compression on pixel art.  
4. Resize outside Godot with **nearest neighbor** only.  
5. AtlasTexture crops must be integer pixels. Known School crops are documented in §3.1 / §15.  
6. Do not mix 3D-rendered assets into factory floors.  
7. After import, instance in a **sandbox scene** before replacing production `School.tscn` / floor scenes.  
8. Update this inventory and `PROGRESS.md`.

---

# 40. PHOTOPEA CLEANUP PROCEDURE (STEP-BY-STEP)

**CONFIRMED IN DOCUMENTATION** (chat dump). Use for JPG sheets and white-background PNG.

1. Open [photopea.com](https://www.photopea.com) → File → Open.  
2. Magic Wand (W), Tolerance **25–40** (start ~30).  
3. Click white/light background; Shift-click remaining islands.  
4. Inspect marching ants — if they eat the shirt, lower tolerance; if background remains, raise 5–10.  
5. Delete. Checkerboard = transparency.  
6. Select → Modify → Contract 1–2 px → Delete again to kill halo.  
7. Crop empty margin; keep integer size.  
8. Image Size only if needed; **constrain proportions**; interpolation **Nearest Neighbor**.  
9. File → Export as → **PNG**.  
10. Name with §14 (`guard_sheet.png`, not `guard_shee (1).png`).  
11. For multi-pose sheets, **leave pose labels** during BG removal; crop labels out in Godot AtlasTexture.  
12. Put file in the correct `asset/` folder; Godot import §39.  
13. Test in-scene.

**Do not** use blurry bicubic upscale. **Do not** export JPG for characters.

---

# 41. WHAT TO IMPLEMENT NEXT (RECIPES)

These are **next actions**, not claims of completion. After each, update `PROGRESS.md`.

## 41.1–41.5 — DONE 2026-08-18 (do not re-implement)

Guard sprite + E-talk + gate (`ProgressGate`); `factory_exterior (1).png`; MG1–5 physics UI + fail→MG1; manager/Director idle crops (chroma-key); Director emergency `post_pass_lines`. Photopea cleanup of those sheets is still open.

## 41.1 P1 — Slice Zone 02–03 NPC sheets into rooms (Asset D + Prog) — **DONE 2026-08-21**

Zone 02 packed sheets + Zone 03 `char_*_idle.png` are placed. Do not re-slice Zone 03 JPGs.

## 41.2 P1 — Photopea NPC sheets (Asset D)

Replace chroma-key stand-in with transparent PNGs (`char_guard_sheet.png`, managers, director). Keep originals until verify.

## 41.3 P2 — Remaining character generation

Generate **Zone 04 only**: Proma, Rumi, Dipa, Sabbir, Nusrat, Imran (`char_*_idle.png`). Shirin / Farid **done**. Do not invent Zone 05 cast.

## 41.4 P3 — Energy Mini-Games 1–2

Only after a written spec. **Do not invent** sort / diagnose.

## 41.5 P3 — Zone 05

Only after identity lock. Leave Hub–Capstone scaffold until then.

## 41.6 Do not do yet

- Replacing Zone 03 Signal Station with Matter Labs / Research Lab
- Replacing Zone 04 The Substation with Wave Observatory / Observatory
- Replacing Zone 05 **scaffold** with invented Citadel rooms
- Rebuilding Zone 02 as ColorRect Hub/Floors or Map B Floors 1–3 / Map A Power Plant
- Inventing Energy Mini-Games 1–2 (sort / diagnose)
- 50×4 question generation as a blocker  
- Scientist battles  
- Regenerating classroom/player  
- Mass Nano Banana of observatory/thermo props  

---

# 42. SCIENTIST / FLASH-CARD BATTLE (SIDE CONCEPT ONLY)

**CONFIRMED IN DOCUMENTATION** (late chat in `capstone,md.txt`): Pokémon-like scientist pick, HP, flash cards that unlock attacks via questions, per-zone battles, side content beside the main assignment.

**Status:** **PLANNED / OPTIONAL / NOT IN CODE.** Conflicts with current manager-quiz floors. **Do not implement** unless the team explicitly schedules it after Zone 01 MVP.

---

# 43. ZONE 02 ASSESSMENT WING + “BUILD THE SYSTEM” (MAP C)

**Evidence label:** **CANONICAL Zone 02 content** (user script 2026-08-17; map lock 2026-08-18).  
**Godot (2026-08-18 late):** **IMPLEMENTED** as Assessment Wing: `Zone02_Entry` → Rooms 1–3 (`Zone02Deck`) → Control Room (`Zone02_Capstone`) → `Zone02_MiniGame3` Build the System → `radiant_crest` + unlock Zone 03. Hub redirects to Entry. World Map pin goes to Entry. Floor 4 leftover scaffold file is **unused**. Energy MG1–2 still **NOT YET DESIGNED** — skipped, not invented.

**Curriculum:** Class 9–10 Bangladesh Physics — Work, Power, Energy, Conservation of Energy, Simple Machines, Mechanical Advantage, Velocity Ratio, Efficiency.

**Badge:** **Radiant Crest** (Zone 04 keeps Spark Emblem).

**Bloom intent:** Rooms 1–3 are Remember→Evaluate quizzes. Mini-game station 3 is **Create only**. Stations 1–2 are named in Rina’s line (“sort / diagnose / build”) but **have no design in this script** → **NOT YET DESIGNED**. Do not invent them.

**Fail rules (this script, different from Factory emergency):**

| Activity | Fail | Penalty |
|---|---|---|
| Quiz rooms 1–3 | < 80% | Door stays locked; retake allowed; **no extra penalty** |
| Build the System | Test does not meet MA + efficiency | Rebuild freely; **time cost only**, no GAME OVER, no progress loss |

**Flow (documented):**

```text
Hub
 → Scene 1 Assessment Wing corridor (Door 1 unlocked; 2–3 locked)
   → Scene 2 Room 1 Nabila (15 MCQ) ≥80% unlocks Door 2
     → Scene 3 Room 2 Karim (10 MCQ + 5 short answer) ≥80% unlocks Door 3
       → Scene 4 Room 3 Farah (5 MCQ + 10 short answer) ≥80% unlocks exit to Control Room
         → Scene 5 Rina’s Verdict → three stations
           → [Energy MG1 Sort — NOT YET DESIGNED]
           → [Energy MG2 Diagnose — NOT YET DESIGNED]
           → Scene 6 Energy MG3 Build the System (Create)
             → Radiant Crest
               → Fade World Map, Zone 03 unlock
               → Script also says return to the lab with Rina  ← UNKNOWN order (§22.18)
```

---

## 43.1 Scene 1 — Assessment Wing Entry

**Layout (CONFIRMED IN DOCUMENTATION):** Short corridor from the Hub to **three lab doors**. Each door has a number plus a difficulty icon:

| Door | Icon | Starts |
|---|---|---|
| 1 | Lightbulb | Unlocked |
| 2 | Gear | Locked overlay until Room 1 pass |
| 3 | Magnifying glass | Locked overlay until Room 2 pass |

**Assets:** Corridor painting `energy_assessment_wing.png` **wired** (1920×1072; cover-scale keeps all three doors). Door lock overlays use sliced `energy_door_locked.png` on UI buttons (not world-space `ProgressGate`). Rina **placed** as `ProctorNPC`.

**Script:**

*(Player enters from the Hub. Rina gestures down the corridor.)*

Rina: "Before you touch a single machine in this building, I need to know you're not just repeating what your teacher said. Three assistants, three rooms. Each one's harder than the last. Fail below 80% and the door stays shut — go back, study, try again. No shortcuts."

Player: "Understood."

Rina: "Room 1's through there. Don't keep Assistant Nabila waiting."

*(Rina exits toward the Control Room. Only Door 1 is unlocked; Doors 2 and 3 show a locked-icon overlay.)*

---

## 43.2 Scene 2 — Quiz Room 1: Recall Lab (Assistant Nabila)

**Layout:** Bright simple lab; whiteboard with basic energy diagrams; one desk terminal. Nabila beside it, clipboard, warm/encouraging.

**Quiz:** 15 MCQ. Bloom: Remember / Understand. Topics: forms of energy, energy transformations, basic work / power / energy definitions. Pass **≥ 80%**.

**On pass:**

Nabila: "See, that wasn't so bad. You've got the vocabulary. Whether you can use it — that's Assistant Karim's problem now."

*(Door 2 unlocks with a visible click / light change.)*

**On fail:**

Nabila: "Close, but not quite. Have another look at your notes — form and transformation, that's the whole game here. Come back when you're ready."

*(Quiz resets. Door stays locked. Retake only — low-stakes, matches Bloom base-tier tone.)*

**Assets:** Room BG `energy_quiz_room_1.png` **wired** (1920×1072; whiteboard + right desk survive cover-scale). Nabila **placed** from `farah karim and nabila.png`. Question JSON **CONFIRMED EXISTING** (`zone02_room1_questions.json`, 15 MCQ). `QuizPanel` supports 15 items.

---

## 43.3 Scene 3 — Quiz Room 2: Applied Lab (Assistant Karim)

**Layout:** Busier; toy pulley + spring scale on desk; formula sheets on wall. Karim clinical, arms folded, testing not teaching.

**Quiz:** 10 MCQ + **5 one-word / short answer**. Bloom: Apply / Analyze. Topics: W = Fd, P = W/t, KE/PE conservation, basic efficiency comparison of two setups.

**On pass:**

Karim: "...Alright. You can apply it. Whether you can break down a real system and tell me where it's failing — that's the last room, and it's not going to be gentle."

*(Door 3 unlocks.)*

**On fail:**

Karim: "You got the definitions right and the numbers wrong. That's the actual test, and you missed it. Go recalculate. I'm not opening this door on guesses."

**Godot:** Room 2 **is built** (`Zone02_Floor2.tscn` + `zone02_room2_questions.json`). Short-answer UI reused from Zone 03. Karim **placed** from the group sheet. BG is **1080×1080** — cover-scale crops ~22% top/bottom (formula-sheet tops + extra floor); desk stays. `zone02_room2.painted_norm` matches that 16:9 band.

---

## 43.4 Scene 4 — Quiz Room 3: Diagnostic Lab (Assistant Farah)

**Layout:** Sparse/serious; no props; wall screen with partial system diagrams and missing values; one terminal. Farah quiet, precise, no encouragement.

**Quiz:** 5 MCQ + **10 one-word**. Bloom: Analyze / Evaluate. Topics: diagnose efficiency loss, judge competing machine setups, predict changed variables, rank design trade-offs.

**On pass:**

Farah: "You reasoned through that correctly. That's rarer than you'd think." *(small pause)* "Rina's waiting for you."

*(Exit door unlocks toward the Control Room / Rina.)*

**On fail:**

Farah: "You answered what you remembered, not what the system was actually telling you. That's the mistake. Look again — slower this time."

**Assets:** Room BG `energy_quiz_room_3.png` **wired** (1920×1072 RGB, no alpha — does not break `TextureRect`/`Sprite2D`). Farah **placed** from the group sheet.

---

## 43.5 Scene 5 — Rina’s Verdict (Control Room)

**Layout:** Same Control Room language as Map B Floor 4 — schematic wall, central console, dim electrical hum. Rina faces the schematic, back to the player, then turns.

**Script:**

Rina: "Three for three. Farah doesn't say 'reasoned through that correctly' about just anyone."

*(She steps closer. Tone pointed, not dismissive.)*

Rina: "I'll be honest with you. I can see you understand the theory. But energy doesn't care what you can explain on paper — it cares what you can build, diagnose, and fix when something's actually running. That's a different kind of proof. And it's the only kind that earns you the Radiant Crest."

Player: "So the quizzes weren't the real test."

Rina: "They were the minimum. Now we find out if you've actually got it."

*(She gestures toward three lit stations along the wall — the mini-game triggers.)*

Rina: "Three stations. Sort what you know, diagnose what's broken, then build something that works from nothing. Get through all three, and the Crest is yours."

*(Fade into Mini-Game 1.)*

**UNKNOWN / DO NOT INVENT:** What Energy Mini-Game 1 (sort) and Mini-Game 2 (diagnose) actually are. Only the **third** station is specified below. Map B’s Loading Dock / Drop Tower / Machine Shop are **different games** — do not paste them in as if they were stations 1–2 unless the team explicitly reuses them.

---

## 43.6 Scene 6 — Mini-Game 3: Build the System (Create tier)

**Bloom:** Create **only**. No Remember/Apply/Analyze/Evaluate as the core loop. Multiple valid layouts. Binary pass against physics constraints, **not** a percentage and **not** a single answer key.

**Premise:** Empty workbench in the Control Room. Rina gives a target spec with local Bangladesh Class 9–10 flavor (water pump, rickshaw-garage hoist, market loading dock). Player designs an energy-transfer system from raw parts.

**Framing line before start:**

Rina: "No menu this time. No right answer waiting for you to pick it. Build something that actually works, and I'll know Farah wasn't wrong about you."

**Example brief (stay visible on console):**

> Lift a 60 kg water drum 3 m using no more than 200 N of effort force, and keep overall efficiency above 70%.

Console shows MA needed, max effort, efficiency floor for the whole attempt.

### Components (draggable palette) — all **MISSING** as files

| Component | Player control | Notes |
|---|---|---|
| Lever | Adjustable fulcrum | Syllabus simple machine |
| Fixed pulley | Place on rig | |
| Movable pulley | Place on rig | |
| Ramp | Adjustable angle / length | Inclined plane |
| Gear pair | Adjustable tooth ratio | Wheel-and-axle stand-in |
| Rope / chain | Connector | |
| Lubrication upgrade | Reduces friction loss | Efficiency booster |

### Play loop

1. **Receive the brief** — numeric constraints stay on screen.  
2. **Free assembly** — drag in any order; live **MA** readout and live **efficiency** readout; nothing locked until Engage.  
3. **Test run** — Engage simulates lift. Success: drum rises cleanly. Fail: stall or rope frays — **visual feedback, not a wrong-answer buzzer**. Partial attempts should feel like iteration.  
4. **Submit or revise** — success: log as “Player Design #1” on the wall schematic. Fail: rebuild with **no progress penalty**.  
5. **Justify (optional, not a new Bloom tier)** — one-line reason, typed or selected (example: “I used two movable pulleys to double my mechanical advantage”). **Not graded as Evaluate.**

**Pass:** Any valid design meeting MA and efficiency floors.

**On success (badge award):**

Rina: "There it is. Radiant Crest — yours. You didn't just remember the theory, foreman. You proved it."

*(Fade to World Map, Zone 03 unlocks.)*  
*(Script also: then return to the lab with Rina — **UNKNOWN** whether that is a victory scene after the map, a map that is skipped, or a mis-ordered note.)*

### Why this is Create (keep this when writing questions/code comments)

Player is not recalling a formula, computing a given scenario, diagnosing a fixed system, or ranking pre-made options. They **generate an original configuration**. The live sim is the world-check, not a designer-authored single key.

---

## 43.7 Map C asset checklist (2026-08-19 docs sync)

Legend: `[x]` wired in Godot · `[P]` packed on a sheet, not sliced/wired as Sprite2D · `[G]` Godot UI · `[~]` reuse Zone 01

### Characters

- [P] Rina idle + extra poses on `rina.png` (not sliced into scenes)
- [P] Nabila / Karim / Farah on `farah karim and nabila.png` (not sliced)
- [~] Player (existing)

### Environments

- [ ] Hub connection into Assessment Wing (optional unique exterior)
- [x] Assessment Wing corridor (`energy_assessment_wing.png` as `RoomArt` + walk colliders; isometric wall wedges in `zone02_entry`)
- [P] Locked overlay / door icons (on packed sheet; doors are Godot buttons)
- [x] Recall Lab (`energy_quiz_room_1.png`; right-side desk collider)
- [x] Applied Lab (`energy_quiz_room_2.png` 1080×1080; 16:9 `painted_norm` around center desk; formula-sheet tops cropped — do not stretch)
- [x] Diagnostic Lab (`energy_quiz_room_3.png`; right-side desk collider)
- [x] Control Room (`energy_control_room.png` on Capstone + MG3; console + left scaffold; RGB floor panels stay walkable)

### UI / icons

- [G] 15-question MCQ flow
- [G] One-word / short-answer field (Rooms 2–3 reuse `QuizPanel`)
- [P] Door icons: lightbulb, gear, magnifying glass (packed sheet)
- [G] Live MA readout
- [G] Live efficiency readout
- [G] Engage button
- [G] Optional justify line
- [~] `crest radiant.png` on disk; award is flag-only (no ceremony UI)
- [ ] Player Design #1 schematic stamp

### Create-MG palette

- [P] Lever, fixed pulley, ramp, gear pair, rope/chain, lube can, workbench/rig, water drum (`other.png`)
- [ ] Movable pulley (not clearly on `other.png`)
- [ ] Success lift / stall / rope-fray VFX

### Audio

- [ ] Control Room hum
- [ ] Door unlock click
- [ ] Engage / stall / fray
- [ ] Radiant Crest stinger

### Content (JSON)

- [ ] Room 1: 15 MCQ Remember/Understand
- [ ] Room 2: 10 MCQ + 5 short-answer Apply/Analyze
- [ ] Room 3: 5 MCQ + 10 short-answer Analyze/Evaluate
- [ ] Create-MG constraint set (at least the 60 kg / 3 m / 200 N / 70% example; more briefs **NOT YET DESIGNED** unless added later)

---

## 43.8 Create-MG asset table (acquisition)

| Asset | Purpose | Existing? | Download? | Nano Banana? | Animation? |
|---|---|---|---|---|---|
| Workbench / empty rig | Playfield | Packed `other.png` | No | Slice to `energy_mg3_workbench.png` | — |
| Lever + fulcrum | Draggable | Packed `other.png` | No | Slice | Fulcrum slide |
| Fixed pulley | Draggable | Packed `other.png` | No | Slice; do not use Zone 01 `pully` | Rope thread |
| Movable pulley | Draggable | **Not on sheet** | No | Generate | |
| Ramp | Draggable | Packed `other.png` | No | Slice | Angle tweak |
| Gear pair | Draggable | Packed `other.png` | No | Slice | Ratio |
| Rope/chain | Connector | Packed `other.png` | No | Slice | |
| Lubrication can | Upgrade | Packed `other.png` | No | Slice | Optional drip |
| Water drum 60 kg | Load | Packed `other.png` | No | Slice | Rise / stall |
| Radiant Crest | Badge | **MISSING** | No | Yes | Award |
| Console brief | Constraints | Godot Label | — | No | — |
| Wall schematic slot | Player Design #1 | No | No | Optional | Stamp |

**Critical vs decorative:** Palette + live readouts + Engage sim are **gameplay-critical**. Corridor flavor and whiteboard art are **P2**.

---

## 43.9 Implementation notes for a future AI (canonical Zone 02)

1. Short-answer / 15-item quiz support exists. Map C Rooms 1–3 **are built** (`zone02_room*_questions.json`).  
2. Door gating: Room N pass unlocks Door N+1; persist in `GameState.floor_passed` (do not overload Factory floor flags).  
3. Do **not** copy Factory “GAME OVER restarts MG1” onto Build the System.  
4. Validate Create-MG against **computed MA and efficiency**, not a hidden correct prefab. (`Zone02MiniGame3.gd` already does this.)  
5. Energy MG1–2 are still undesigned — **ask**, do not invent Sort/Diagnose games.  
6. Zone 03 **Signal Station** is implemented; Map C “unlock Zone 03” is a Zone 02 **MG3** beat (not the Control Room verdict).  
7. Do **not** rebuild Zone 02 as Hub/Floor1–4 ColorRect scaffold. Leftover `Zone02_Floor4.tscn` is unused.

---

# 44. ZONE 05 GODOT SCAFFOLD + ZONE 02 HISTORY (2026-08-18)

**Evidence:** Zone **05** remains **placeholder UI**. Zone **02 scaffold was replaced** the same evening with §43 Assessment Wing (see §43 Godot note). Do not rebuild Zone 02 as four ColorRect quiz floors.

**Zone 03 was this scaffold and is now replaced** — see §45.  
**Zone 04 was this scaffold and is now replaced** — see §46.

## 44.1 Unlock API

`GameState.is_zone_unlocked(zone_id)`  
`GameState.unlock_next_zone(current_zone_id)`  

Defaults: Zone 01 true; 02–05 false. Persisted inside `user://savegame.json` via GameManager. F5 resets these flags.

Zone 01 clear hook: `MiniGame05Pulley.gd` Engage success → `momentum_crest` + `unlock_next_zone("zone_01")`.

**Zone 02 clear hook:** Build the System awards `radiant_crest` and `unlock_next_zone("zone_02")`. Saves with existing `badge_radiant_crest` migrate Zone 03 on load.

**Zone 03 clear hook (not scaffold capstone):** Mini-Game 2 awards `spectrum_crest` and `GameState.unlock_next_zone("zone_03")`, which sets `zone_04_unlocked = true`. Saves with existing `badge_spectrum_crest` also migrate Zone 04 on load.

**Zone 04 clear hook (not scaffold capstone):** Build the Generator awards `spark_emblem` and `GameState.unlock_next_zone("zone_04")`, which sets `zone_05_unlocked = true`. Saves with existing `badge_spark_emblem` also migrate Zone 05 on load.

## 44.2 World Map pins

| Pin | Goes to |
|---|---|
| Zone 01 Factory | `Zone01_Exterior.tscn` (plus legacy factory hotspot) |
| Zone 02 Energy Refinery | `Zone02_Entry.tscn` |
| Zone 03 Signal Station | `Zone03_Entry.tscn` |
| Zone 04 The Substation | `Zone04_Entry.tscn` |
| Zone 05 Light & Circuits Citadel | `Zone05_Hub.tscn` |

## 44.3 Per-zone files

For X in **05** only: Hub, Floor1–4, Capstone under `res://scenes/Zone0X/` still use `ZoneScaffoldFloor.gd`.  
Zone 02 Floor4 leftover still uses the old scaffold script but is **not** on the play path.

Zone 03 file list: §3.11 / §45.  
Zone 04 file list: §3.12 / §46.

## 44.4 What a new AI must not do

- Do not delete Zone 05 scaffold without being asked to implement the real zone. Zone 02 play path is **already** §43 — do not restore ColorRect Hub/Floors as the play path.
- Do not claim Zone 05 is “complete.” Zone 02 gameplay loop is implemented; NPC sheets and Energy MG1–2 are not.
- Do not invent Mini-Games 1–2. Do not paste Map B Floors 1–3 as those stations.
- Do not unlock Zone 04 from Zone 03 capstone quiz, or Zone 05 from Zone 04 capstone quiz (those paths were removed on purpose).

---

# 45. ZONE 03 SIGNAL STATION (CANONICAL — IMPLEMENTED 2026-08-18)

**Evidence:** CONFIRMED EXISTING / VISIBLE IN GAMEPLAY. **Canonical Zone 03** (not Matter Labs / Research Lab). **Production Ready** for the scripted loop. Refined room paintings + player roaming/collision. **Full cast idle PNGs wired** (Anwar / Tania / Milon / Shirin / Farid) as of 2026-08-21.

No separate Anwar/Tania script file existed in the repo. Dialogue in `data/zone03_dialogue.json` was written to the task’s cast (Chief Anwar, Tania, Milon, Shirin, Farid) in the same register as Map C’s Rina/Nabila lines.

## 45.1 Scene inventory (`res://scenes/Zone03/`)

| Scene | Script | Notes |
|---|---|---|
| `Zone03_Entry.tscn` | `Zone03Entry.gd` | Anwar intro + `char_anwar_idle.png`; Door 1 open; Doors 2–4 gated; Capstone Exit after Deck 4 |
| `Zone03_Floor1.tscn` | `Zone03Deck.gd` | Tania (`char_tania_idle.png`) — Wave Basics — `zone03_room1_questions.json` |
| `Zone03_Floor2.tscn` | `Zone03Deck.gd` | Milon (`char_milon_idle.png`) — Sound & Vibration — `zone03_room2_questions.json` |
| `Zone03_Floor3.tscn` | `Zone03Deck.gd` | Shirin (`char_shirin_idle.png`) — 12 MCQ + 3 short — `zone03_room3_questions.json` |
| `Zone03_Floor4.tscn` | `Zone03Deck.gd` | Farid (`char_farid_idle.png`) — 12 MCQ + 8 short — `zone03_room4_questions.json` |
| `Zone03_Capstone.tscn` | `Zone03Capstone.gd` | Anwar verdict + `char_anwar_idle.png`; Start Mini-Games → MG1; **does not** unlock Zone 04 |
| `Zone03_MiniGame1.tscn` | `Zone03MiniGame1.gd` | Grid ray: empty / `/` / `\` / glass; Transmit; glass bends right→down |
| `Zone03_MiniGame2.tscn` | `Zone03MiniGame2.gd` | Three mounts; convex on centre; Engage |
| `Zone03_Hub.tscn` | `ZoneHub.gd` | Redirect: Enter Corridor → Entry |

## 45.2 Spectrum Crest and Zone 04 unlock

On Mini-Game 2 success:

1. `BadgeManager.award_badge("spectrum_crest")` → `GameManager.badge_spectrum_crest = true`  
2. `GameState.unlock_next_zone("zone_03")` → `zone_04_unlocked = true` and `zone_cleared["zone_03"] = true`  
3. Anwar win line, then World Map  

F5 clears the crest. Loading a save that already has the crest sets Zone 04 unlocked if it was missing.

## 45.3 Gating

Pass threshold **80%**. Fail: retry allowed; next door stays locked. Floor-pass keys: `zone_03_floor_1` … `zone_03_floor_4` in `GameState.floor_passed`.

## 45.4 Verify

Headless `verify_project.gd`: **580 checks, 0 failures** (2026-08-19). Includes painted `map.png` world map, Zone 01–04 roam/collision, Map C, Signal Station, Substation.

---

# 46. ZONE 04 THE SUBSTATION (CANONICAL — IMPLEMENTED 2026-08-18)

**Evidence:** CONFIRMED EXISTING / VISIBLE IN GAMEPLAY. **Canonical Zone 04** (not Wave Observatory / Observatory). **Production Ready** for the scripted loop. Refined room paintings + player roaming/collision. NPC sheets **MISSING**.

No separate Proma/Rumi script file existed in the repo. Dialogue in `data/zone04_dialogue.json` was written to the task’s cast (Chief Proma, Rumi, Dipa, Sabbir, Nusrat, Imran).

## 46.1 Scene inventory (`res://scenes/Zone04/`)

| Scene | Script | Notes |
|---|---|---|
| `Zone04_Entry.tscn` | `Zone04Entry.gd` | Proma intro; Door 1 open; Doors 2–5 gated; Control Room Exit after Bay 5 |
| `Zone04_Floor1.tscn` | `Zone04Deck.gd` | Rumi — Fundamentals — `zone04_room1_questions.json` (10 MCQ) |
| `Zone04_Floor2.tscn` | `Zone04Deck.gd` | Dipa — Circuit Basics — `zone04_room2_questions.json` (15 MCQ) |
| `Zone04_Floor3.tscn` | `Zone04Deck.gd` | Sabbir — Ohm's Law — `zone04_room3_questions.json` (15 MCQ) |
| `Zone04_Floor4.tscn` | `Zone04Deck.gd` | Nusrat — Diagnostics — `zone04_room4_questions.json` (10 MCQ + 5 short) |
| `Zone04_Floor5.tscn` | `Zone04Deck.gd` | Imran — Judgment — `zone04_room5_questions.json` (12 MCQ + 8 short) |
| `Zone04_Capstone.tscn` | `Zone04Capstone.gd` | Verdict only; Start Mini-Games → generator |
| `Zone04_MiniGame1.tscn` | `Zone04MiniGame1.gd` | Build the Generator; live EMF gauges |
| `Zone04_Hub.tscn` | `ZoneHub.gd` | Redirect: Enter Walkway → Entry |

## 46.2 Spark Emblem and Zone 05 unlock

On generator success (Spin Rotor with a valid assembly):

1. `BadgeManager.award_badge("spark_emblem")` → `GameManager.badge_spark_emblem = true`  
2. `GameState.unlock_next_zone("zone_04")` → `zone_05_unlocked = true` and `zone_cleared["zone_04"] = true`  
3. Proma win line, then World Map  

F5 clears the emblem. Loading a save that already has the emblem sets Zone 05 unlocked if it was missing.

## 46.3 Generator model

\(EMF = k \cdot N \cdot B \cdot v\) with \(k = 0.05\), spin \(v = 1\).  
Bar \(B = 0.4\); horseshoe \(B = 0.8\). Turns 50 / 100 / 200.  
Success: commutator on (steady DC), \(EMF \ge 6\,\mathrm{V}\), load current in \(0.35\)–\(1.25\,\mathrm{A}\).  
Worked lock: horseshoe + 200 turns + commutator + \(10\,\Omega\) → \(8\,\mathrm{V}\), \(0.8\,\mathrm{A}\).  
Bar magnet undershoots 6 V. \(2\,\Omega\) overloads. No commutator is not steady.

Parts tray click-assigns onto slots; slots also cycle. ColorRect rotor (no unique workshop art).

## 46.4 Gating

Pass threshold **80%**. Fail: retry allowed; next door stays locked. Floor-pass keys: `zone_04_floor_1` … `zone_04_floor_5`.

## 46.5 Verify

Included in the **580 / 0** headless run: five-bay door gating, Proma/proctor names, EMF cases, Spark Emblem + Zone 05 migrate, Zone 01–04 roam/collision, painted world map.

---

# 47. CAPSTONE PROJECT POSTER (CHAT 2026-08-18)

**Evidence:** **CONFIRMED IN DOCUMENTATION** (poster draft + chat copy). **No poster file in the repo.** Do not treat this as printed. Do not invent SUS / Hake / exam scores — those trials are **not run**.

Current draft on disk (user screenshot, not in `docs/`): Abstract, Introduction hub-and-spoke, Problem Statement on a pink board. That hub still used old labels (20 floors; Zone 5 nuclear). **Use the locked zone names in this section** when reprinting.

## 47.1 Board layout (A0 landscape or two boards)

| Placement | Section |
|---|---|
| Top bar, full width | 0 Title strip |
| Top-left | 1 Abstract |
| Top-center | 2 Introduction / zone map |
| **Top-right** | **7 Comparison table** |
| Mid-left | 3 Problem statement |
| Mid-center | 5 Architecture hierarchy + 6 data flow |
| Mid-right | 8 Methodology + Bloom |
| **Bottom-left** | **4 Objectives** |
| Bottom-center | 9 Journey + 10 status charts + 11 zone listing |
| **Bottom-right** | **12 Technology stack** |
| Footer | 13 Evaluation plan, 14 conclusion, 15 refs, 16 QR |

**Visual types:** hub-and-spoke (2); matrix (7); org tree (5); flowchart (6); Bloom pyramid (8); stacked bars (8, 10); chevrons (9); big number **580/0** (10); layered stack (12); numbered aims (4). Ogive / SUS curves only after a trial.

## 47.2 Copy — 0 Title strip

**Title:** Physics Quest  
**Subtitle:** A curriculum-aligned 2D physics RPG for Bangladesh Class 9–10  
**Line:** Department of CSE · [University] · Capstone 2026 · Authors · Supervisor  
**Chips:** 5 thematic zones · ≥ 80% quiz gate · 580 automated checks, 0 failures  
**Tiny:** Engine Godot 4.7 (GDScript) · Save `user://profiles/` (profile JSON; see PROGRESS)

## 47.3 Copy — 1 Abstract (top-left)

Physics education in Bangladesh is still mostly theory-first: textbooks and recall tests, with little chance to try a concept before an exam. **Physics Quest** is a Godot 4 educational RPG aligned to the Class 9–10 physics syllabus. The player leaves a classroom assignment, travels a world map, and clears themed sites through dialogue, ≥ 80% assessments, and hands-on mini-games. Five zones climb Bloom’s Taxonomy from Remember toward Create. Completing a zone awards a badge and unlocks the next site. The project combines three things generic apps usually split apart: local curriculum, playable systems, and taxonomy-based gates.

## 47.4 Copy — 2 Introduction hub (top-center)

**Center:** PHYSICS QUEST · Class 9–10 RPG loop · School → Map → Zone → Badge → next pin  

Do **not** print “5 Zones — 20 Floors” as if Godot were uniform. Floor counts vary (Zone 03 = four decks; Zone 04 = five bays).

| Spoke | Poster text |
|---|---|
| Zone 1 Mechanics Factory | Measurement, motion, force. Floor quizzes + five emergency mini-games. Badge: Momentum Crest. Status: **playable** (Guard/gate, 80% floors, MG1–5). |
| Zone 2 Energy Refinery / Assessment Wing | Work, power, energy, simple machines. Three locked labs (Nabila, Karim, Farah) then Build the System. Badge: Radiant Crest. Status: **implemented** (MG1–2 skipped). |
| Zone 3 Signal Station | Waves, sound, optics. Four 80% decks + two mini-games. Badge: Spectrum Crest. Status: **implemented**. |
| Zone 4 The Substation | Charge, circuits, magnetism. Five 80% bays + Build the Generator. Badge: Spark Emblem. Status: **implemented**. |
| Zone 5 Hall of Physics Legends | Capstone zone. Identity not locked. Status: Hub–Capstone scaffold only. |

**Caption:** Map pins unlock in order.

## 47.5 Copy — 3 Problem statement (mid-left)

- Abstract concepts, static delivery. Formulas arrive as one-way lecture and board work.  
- Little hands-on time. Students rarely run a system, fail, and retry with a new setup.  
- Generic edtech. Most apps are not written around the Bangladesh Class 9–10 syllabus.  
- Recall-heavy tests. Tools stop at MCQ memory; Analyze / Evaluate / Create are rare.  
- The gap. No local tool that is at once **syllabus-true**, **playable**, and **Bloom-gated**.

## 47.6 Copy — 4 Objectives (**bottom left**)

1. Deliver a playable loop: classroom briefing → world map → expert sites → badge → next zone.  
2. Assess with JSON question banks and a **≥ 80%** pass mark; mix MCQ and short answer where the zone requires it.  
3. Climb Bloom inside each site (Remember → Create), without inventing undesigned mini-games.  
4. Persist progress (floor passes, badges, zone unlocks) in a local save file; F5 resets that save.  
5. Treat Godot scenes as evidence: a zone is “done” only when the loop is playable and headless verify is green.  
6. Keep art and code honest: ColorRect is shipped gameplay, not finished environment art.

**Ticks:** Z1 Guard/gate + MG1–5 done · Z2 Assessment Wing + Build the System done · Z3–Z4 loops done · Z5 scaffold · Energy MG1–2 undesigned · SUS/pre-post planned.

## 47.7 Copy — 5 Architecture (hierarchy)

**Layer 1 Engine:** Godot 4.7, 2D (`canvas_items`), GDScript. Jolt 3D unused.  
**Layer 2 Autoloads (rebuild `d:\capstone 2`):** `GameState` · `SceneTransition` · `SaveManager` (`user://profiles/`). Legacy scaffold also described GameManager / SceneManager / BadgeManager — prefer rebuild autoloads for this tree.  
**Layer 3 Scenes:** `School.tscn` → World Map → Factory Exterior / zone Entry.  
**Layer 4 UI:** `DialoguePanel`, `QuizPanel` (MCQ + short answer).  
**Layer 5 Data:** `data/*_questions.json`, `zone02_dialogue.json`, `zone03_dialogue.json`, `zone04_dialogue.json`.  
**Layer 6 QA:** `verify_project.gd` headless (717 / 0, 2026-09-16). Data: `room_collisions.json`. World map: `worldmap/` bg + `factory.png` + other landmarks. Audio: Dummy driver until SFX.

## 47.8 Copy — 6 Data flow (flowchart boxes)

Input (WASD / UI) → scene → `DialoguePanel` → `QuizManager` + JSON → `QuizPanel` → ≥ 80%? **No:** retry, door stays locked. **Yes:** `floor_passed` → next door → mini-game (if any) → `BadgeManager` → `unlock_next_zone` → `user://savegame.json` → World Map pin.

**Note:** Zone 03/04 capstone does **not** unlock the next zone; the last mini-game does. Factory Mini-Game 5 success unlocks Zone 02.

## 47.9 Copy — 7 Comparison (**top right**)

| | Classroom textbook | Generic physics app | Physics Quest |
|---|---|---|---|
| Bangladesh 9–10 syllabus | Yes | Rarely | Designed around it |
| Story / RPG travel | No | No | School, map, named NPCs |
| Bloom climb inside a site | No | Rare | Rooms ordered Remember → Create |
| Hands-on system (not only MCQ) | Lab if available | Sometimes | Mini-games where specified |
| Progress gate | Exam | Often none | ≥ 80% per room |
| Offline game client | No | Varies | Godot 4 desktop |
| Measured learning gain / SUS | Board exam | Vendor claims | Protocol designed; **trial not run yet** |

## 47.10 Copy — 8 Methodology

**Process:** GDD / scene script → JSON banks + dialogue → Godot scenes → playtest → `verify_project.gd`.  
**Pedagogy:** Locked door = assessment gate. Fail = retake. Create-tier where specified (Zone 04 generator; Zone 02 Build the System **implemented**). Energy Mini-Games 1–2 named only — do not invent on the poster.  
**Bloom pyramid:** Remember / Understand → Apply → Analyze → Evaluate → Create.  
**Stacked-bar counts (honest):** Zone 01 5 MCQ/floor; Zone 02 Map C 15+15+15 mixed; Zone 05 5 MCQ placeholders; Zone 03 15+15+15+20 (short answers on decks 3–4); Zone 04 10+15+15+15+20 (short answers on bays 4–5). Proposal 50/floor **not shipped**.

## 47.11 Copy — 9 Player journey

School cutscene → World Map (pins 02–05 start locked) → Factory Guard/gate → floors 1–4 (80%) → five emergency mini-games → Momentum Crest → Zone 02 pin.  
Zone 02: Assessment Wing → three rooms → Rina verdict → Build the System → Radiant Crest → Zone 03.  
Zone 03: corridor → four decks → Anwar verdict → two optics mini-games → Spectrum Crest → Zone 04.  
Zone 04: walkway → five bays → Proma verdict → Build the Generator → Spark Emblem → Zone 05 pin.  
**Caption:** Schoolyard walk with road signs is GDD only, not the current cutscene.

## 47.12 Copy — 10 Implementation status (charts)

| Zone | Gameplay loop | Environment art | Spec |
|---|---|---|---|
| 1 Factory | Quizzes + MG1–5 | Exterior + floor paintings | Full GDD |
| 2 Energy | Assessment Wing + Build the System | Room paintings + roam collision | Map C in Godot |
| 3 Signal Station | Full loop | Room paintings + roam collision | Implemented |
| 4 Substation | Full loop | Room paintings + roam collision | Implemented |
| 5 Legends | Scaffold quizzes | ColorRect | Not locked |

**Big number:** 580 / 0. **Do not print** SUS, Hake gain, or exam %.

## 47.13 Copy — 11 Zone listing

| Zone | Structure | Gate | Signature challenge | Badge | In Godot |
|---|---|---|---|---|---|
| 01 Factory | Floors 1–4 | 80% MCQ | 5 mini-games (physics UI) | Momentum Crest | Yes |
| 02 Energy | 3 labs + Build the System | 80% | Create-MG (MG1–2 skipped) | Radiant Crest | Yes |
| 03 Signal Station | 4 decks + 2 MG | 80% | Signal path + optical rail | Spectrum Crest | Yes |
| 04 Substation | 5 bays + 1 MG | 80% | Build the Generator | Spark Emblem | Yes |
| 05 | Hub–Capstone | 80% placeholder | TBD | TBD | Scaffold |

## 47.14 Copy — 12 Technology stack (**bottom right**)

**In the repo:** Godot 4.7 · GDScript · JSON banks · Zone 01 pixel scenes · ColorRect UI (Zones 02–05) · QuizManager / QuizPanel · autoload save · headless verifier.  
**Documented only:** C# proposal · 50 questions/floor · factory audio wired · badge ceremony UI · remaining Nano Banana art.  
**Stack (bottom → top):** Godot 4.7 → GDScript autoloads → Scenes & UI → JSON → Pixel / ColorRect → Headless verify.

## 47.15 Copy — 13 Evaluation (planned)

1. Pre-test on the syllabus slice the zone teaches. 2. Play the zone. 3. Post-test → Hake gain. 4. SUS. 5. Optional time-on-task / retries.  
**Caption:** Fill gain/SUS charts after the trial. Do not invent curves.

## 47.16 Copy — 14 Conclusion

**Done:** Sequential map unlocks; 80% JSON quizzes; short-answer UI; Signal Station and Substation loops; Spectrum Crest and Spark Emblem as save flags.  
**Next:** Zone 02 Assessment Wing scenes and art; Zone 05 content lock; real Zone 01 mini-games; painted rooms for 03–04; learner trial; badge UI.  
**Close:** Physics Quest is a gated RPG shell with two complete later zones; remaining work is filling designed rooms, not choosing a new genre.

## 47.17 Copy — 15–16 References and footer

1. NCTB *Physics* Classes 9–10. 2. Bloom et al., *Taxonomy of Educational Objectives.* 3. Gee, *What Video Games Have to Teach Us…* 4. Brooke, SUS. 5. Hake, *Am. J. Phys.* 6. Godot 4.x docs. 7. This master document (2026). 8. Capstone proposal PDF if the committee requires it.

Acknowledgements: supervisor, department. QR: build or 60-second demo. **Legend on every diagram:** Implemented · Scaffold · Planned.

---

# APPENDIX A — CANONICAL PATHS

| Item | Path |
|---|---|
| Repo root | `C:\Users\Mufrid Johanee\Desktop\capstone\final\` |
| Godot project | `final-godot/` |
| Assets | `asset/` → `res://asset/` |
| This document | `docs/PHYSICS_QUEST_MASTER.md` |
| Living status | `docs/PROGRESS.md` |
| Zone 01 GDD dump | `docs/capstone,md.txt` |
| Map B GDD | `docs/physics_quest_zones_02-05_gdd (2).md` |
| Zone 02 rooms (Map B, superseded gameplay) | `docs/physics_quest_zone02_scene_design (2).md` |
| GameState | `final-godot/scripts/autoload/GameState.gd` |
| Zone 02 Assessment Wing scenes | `final-godot/scenes/Zone02/` (Entry, Floors 1–3, Capstone, MiniGame3) |
| Zone 05 scaffold | `final-godot/scenes/Zone05/` |
| Zone 03 Signal Station | `final-godot/scenes/Zone03/` (Entry, Floors, Capstone, MiniGame1–2) |
| Zone 03 scripts | `final-godot/scripts/zones/zone03/` |
| Zone 04 The Substation | `final-godot/scenes/Zone04/` (Entry, Floors 1–5, Capstone, MiniGame1) |
| Zone 04 scripts | `final-godot/scripts/zones/zone04/` |
| Zone 02 Assessment Wing (canonical, in Godot) | this file §43 |
| Zone 05 Godot scaffold + Zone 02 history | this file §44 |
| Zone 03 Signal Station (implemented) | this file §45 |
| Zone 04 The Substation (implemented) | this file §46 |
| Zone 02 Nano Banana catalog (filtered) | this file §12.5 |
| Zone 02 packed sheets / conventions | this file §12.6 |
| Zone 03 Signal Station art prompts | this file §12.7 |
| Zone 03–04 NPC prompts (Zone 03 cast wired; Zone 04 remaining) | this file §12.8 |
| Capstone poster copy | this file §47 |
| Style reference | `asset/sprites/Environment/factory_asset_reference.png` |
| Save file | `user://savegame.json` |

---

# APPENDIX B — STATUS LEGEND (REPEAT)

| Label | Meaning |
|---|---|
| CONFIRMED EXISTING | On disk in this repo |
| CONFIRMED IN DOCUMENTATION | Specified in GDD/proposal/chat |
| VISIBLE IN GAMEPLAY | Reachable in Godot |
| DOWNLOADED / AVAILABLE | File exists; may be unused |
| GENERATED BUT NEEDS CLEANUP | AI/export; JPG/typo/white bg/unwired |
| PLANNED | Intended |
| MISSING | Needed; no usable file |
| NOT YET DESIGNED | Named only |
| UNKNOWN / REQUIRES DECISION | Do not invent |

---

*End of master document. Evidence updated 2026-09-16 (School reference composition: teacher right/front of desk; student seated row-2/col-2; World Map `factory.png`; Z04 cast missing; verify **717 / 0**). Zone 05 identity still not locked. Update **this file** after any spec or implementation. Update `PROGRESS.md` only after code/scene/on-disk/verify.*
