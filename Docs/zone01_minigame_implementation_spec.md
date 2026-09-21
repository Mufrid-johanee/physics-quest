# Physics Quest — Zone 1 (Mechanics) Mini-Game Implementation Spec

**For:** Cursor implementation pass — asset pipeline + Godot integration  
**Engine:** Godot 4 (GDScript)  
**Source:** Physics Quest GDD — Zone 01: Mechanics (Factory)  
**Scope:** The five-mini-game Factory Emergency sequence only (post Floor 4 Director quiz)  
**Document version:** 1.0 — generated from Physics Quest GDD Zone 01 source material  
**Master cross-ref:** `docs/PHYSICS_QUEST_MASTER.md` §5.3, §7, §33  
**Living status:** `docs/PROGRESS.md` (code/scenes only)

---

## Rebuild note (`d:\capstone 2`, 2026-09-21) — READ FIRST

This spec describes the **full five-MG** Factory Emergency chain (Brake → Gear → Balance → Pressure → Pulley → **Momentum Crest**).

**Current rebuild gate is different:** Zone 01 Floor 4 launches **only** Emergency Brake (`scenes/minigames/zone01/MiniGame01_Brake.tscn`). Success → `mark_minigame_successful(ZONE_01)` → World Map. MG2–MG5 are **not** the Floor4 unlock gate.

Authoritative current status: `Docs/MINIGAME_IMPLEMENTATION.md`. Treat the rest of this file as polish / historical target material unless a future task restores the five-MG sequence.

---

## Relationship to shipped Godot (read first)

| Topic | This spec (target polish) | Shipped today (`final-godot/`) |
|---|---|---|
| Orchestration | `MiniGameSequence.tscn` + `MiniGameBase.gd` | Direct scene chain: Floor4 → `minigames/MiniGame01_…` → … → MG5 → World Map |
| Data | `data/zone01_minigames.json` + random scenario pick | Hardcoded constants in each `MiniGame0X*.gd` |
| Interaction | Drag-and-drop (MG2, MG5); richer VFX/SFX | Click/toggle UI; most SFX unwired |
| MG1 extra force | Sample scenario uses **220 N** | Shipped / master §33: **150 N** (40 kg, μ 0.35, 7 m) |
| MG2 RPM band | Sample **180–220** | Shipped / master §33: **150–200** |
| MG4 force | Sample incorrectly shows **1000 N** | **Correct formula:** \(F_{in} = P_{out} \times A_{in} = 5000 \times 0.02 = \mathbf{100\,N}\). Shipped buttons: 60 / **100** / 140 N |
| Paths | Spec tree under `Zone01_Factory/scenes/` | Actual: `scenes/Zone01_Factory/minigames/` + `scripts/zones/zone01/` |

**Do not replace shipped physics numbers with unverified sample JSON.** When implementing `zone01_minigames.json`, use master §33 / current scripts as the default scenario; treat this doc’s sample objects as *shapes* for multi-variant pools after Argon verifies each variant.

**Flag for Argon:** MiniGame 4’s sample numeric scenario in §2.4 of the GDD dump (1000 N) does **not** match Pascal’s Law with the stated areas — recalculate before any new JSON pool ships.

---

## 0. Sequence Overview

Five mini-games trigger in fixed order after the player passes the Floor 4 Director's quiz. All five must be completed in a single attempt — failing any one ends the sequence and returns the player to the start of Mini-Game 1 (Floors 1–3 quiz progress is preserved; the mini-game sequence itself is not).

```
Director Quiz Pass
      ↓
[Cutscene: Factory Emergency]
      ↓
MiniGame 1: Emergency Brake (Friction)
      ↓ pass
MiniGame 2: Gear Swap (Gear Ratios)
      ↓ pass
MiniGame 3: Counterweight Balance (Moments)
      ↓ pass
MiniGame 4: Pressure Panic (Pascal's Law)
      ↓ pass
MiniGame 5: Pulley Rush (Mechanical Advantage)
      ↓ pass
[Cutscene: Momentum Crest Awarded]
      ↓
badge_momentum_crest = true → World Map → Zone 02 unlocks

Any FAIL at any stage → Game Over screen → restart from MiniGame 1
```

**Shipped today:** Emergency dialogue is Floor 4 `post_pass_lines`; crest is `BadgeManager.award_badge("momentum_crest")` on MG5 success (ceremony UI still missing). Fail → `SceneManager` reloads MG1.

---

## 1. Godot Architecture

### 1.1 Node/Scene Structure (target)

```
Zone01_Factory/
├── scenes/
│   ├── Zone01_Exterior.tscn
│   ├── Zone01_Floor1.tscn … Zone01_Floor4.tscn
│   ├── MiniGameSequence.tscn        # NEW — container; hosts MG1–5 in order
│   ├── MiniGame01_Brake.tscn
│   ├── MiniGame02_Gear.tscn
│   ├── MiniGame03_Balance.tscn
│   ├── MiniGame04_Pressure.tscn
│   └── MiniGame05_Pulley.tscn
├── data/
│   ├── zone01_questions.json         # floor quiz bank (out of scope)
│   └── zone01_minigames.json         # NEW — see Section 3
├── scripts/
│   ├── MiniGameSequence.gd           # NEW — MG1→MG5, Game Over / restart
│   ├── MiniGameBase.gd               # NEW — base class
│   ├── MiniGame01_Brake.gd … MiniGame05_Pulley.gd
└── assets/                            # see Section 5
```

**Actual repo paths today:**

- Scenes: `final-godot/scenes/Zone01_Factory/` and `…/minigames/`
- Scripts: `final-godot/scripts/zones/zone01/MiniGame01Brake.gd` … `MiniGame05Pulley.gd`
- Data: `final-godot/data/zone01_floor*_questions.json` (no `zone01_minigames.json` yet)

### 1.2 Base Class Contract (target)

`MiniGameBase.gd` (extends `Control` — panel/HUD over static background, no free roam):

```gdscript
class_name MiniGameBase
extends Control

signal mini_game_passed
signal mini_game_failed

var mini_game_id: String
var is_active: bool = false

func start() -> void:
    is_active = true
    load_scenario()

func load_scenario() -> void:
    # override — pull from zone01_minigames.json
    pass

func evaluate_outcome(player_choice) -> void:
    # override — compare against correct answer
    pass

func _pass() -> void:
    is_active = false
    emit_signal("mini_game_passed")

func _fail() -> void:
    is_active = false
    emit_signal("mini_game_failed")
```

`MiniGameSequence.gd` orchestrator (target):

```gdscript
class_name MiniGameSequence
extends Node

const MINIGAME_ORDER = [
    "MiniGame01_Brake",
    "MiniGame02_Gear",
    "MiniGame03_Balance",
    "MiniGame04_Pressure",
    "MiniGame05_Pulley"
]

var current_index: int = 0

func start_sequence() -> void:
    current_index = 0
    _load_current()

func _load_current() -> void:
    var scene_name = MINIGAME_ORDER[current_index]
    # Prefer: res://scenes/Zone01_Factory/minigames/%s.tscn
    var mg = load("res://scenes/Zone01_Factory/minigames/%s.tscn" % scene_name).instantiate()
    add_child(mg)
    mg.mini_game_passed.connect(_on_passed)
    mg.mini_game_failed.connect(_on_failed)
    mg.start()

func _on_passed() -> void:
    current_index += 1
    if current_index >= MINIGAME_ORDER.size():
        # Shipped API: BadgeManager.award_badge("momentum_crest")
        # + GameState.unlock_next_zone("zone_01") — not GameManager.award_badge("badge_momentum_crest")
        pass
    else:
        _load_current()

func _on_failed() -> void:
    current_index = 0
    _load_current()  # restart from MiniGame 1
```

**Integration note:** Autoload badge API is `BadgeManager.award_badge("momentum_crest")`. Zone unlock is `GameState.unlock_next_zone("zone_01")`. Do not invent a second badge id string.

---

## 2. Per-Mini-Game Specification

### MiniGame 1 — Emergency Brake (Friction)

**Concept:** Friction force, \(F = \mu N\), deceleration  
**Interaction type:** Binary choice (YES/NO) → conditional 3-option select

**Logic:**
1. Display block mass, surface type, μ (from reference table), and a countdown/distance bar.
2. Player answers: "Will friction alone stop the block?"
3. If the correct answer is NO, player then selects the required additional braking force from 3 options.
4. Correct final answer → block decelerates to stop → `_pass()`. Incorrect → crash → `_fail()`.

**Scenario object shape:**

```json
{
  "id": "mg01_brake_scenario",
  "block_mass_kg": 40,
  "surface_label": "Steel block on concrete ramp",
  "mu": 0.35,
  "friction_sufficient": false,
  "correct_additional_force_n": 150,
  "distractor_forces_n": [50, 250],
  "countdown_seconds": 12,
  "distance_m": 7
}
```

Default numbers above match **shipped / master §33**. GDD dump sample used 220 N — treat as unverified variant only after physics check.

**Assets required:** ramp bg, countdown bar, YES/NO + force buttons, μ reference popup, slide/stop/crash VFX, skid/thud/crash SFX. Existing: `mg1_ramp_bg.png`, `mg1_block (1).png`.

---

### MiniGame 2 — Gear Swap (Gear Ratios)

**Concept:** Gear ratio = teeth driven / teeth driving; output RPM  
**Interaction type (target):** Drag-and-drop onto a rig slot *(shipped: button select + Test + Confirm)*

**Logic:**
1. Display input gear tooth count and target output RPM range.
2. Player chooses among 4–5 candidate gears; confirms Engage.
3. RPM in range → `_pass()`. Else belt snap → `_fail()`.

**Scenario object shape (shipped band preserved):**

```json
{
  "id": "mg02_gear_scenario",
  "input_teeth": 20,
  "input_rpm": 120,
  "target_output_rpm_min": 150,
  "target_output_rpm_max": 200,
  "candidate_gears": [
    {"teeth": 15, "correct": true},
    {"teeth": 10, "correct": false},
    {"teeth": 8, "correct": false},
    {"teeth": 24, "correct": false}
  ]
}
```

GDD dump sample used 180–220 RPM and teeth/RPM pairs that assume a different input RPM — verify before adding variants.

**Assets:** housing, 4–5 gear sizes, RPM dial, Engage button, snap/startup VFX/SFX. Existing: `mg2_housing.png`, `mg2_gear_a (1).png`.

---

### MiniGame 3 — Counterweight Balance (Moments)

**Concept:** \(F_1 d_1 = F_2 d_2\)  
**Interaction type:** Select-and-confirm under time pressure

**Logic:** Load + distances shown; five weights; descent timer; Place Counterweight. Correct → balance `_pass()`. Wrong/timeout → crash `_fail()`.

**Scenario (matches shipped):**

```json
{
  "id": "mg03_balance_scenario",
  "load_force_n": 300,
  "load_distance_m": 2,
  "counterweight_distance_m": 3,
  "correct_counterweight_n": 200,
  "candidate_weights_n": [150, 180, 200, 220, 250],
  "descent_timer_seconds": 15
}
```

**Assets:** crane/lever, weight blocks, timer bar, Place button, creak/clunk/crash SFX. Existing: `crane.png`, `load (1).png`, `weights (1).png`.

---

### MiniGame 4 — Pressure Panic (Pascal's Law)

**Concept:** \(P = F/A\), \(P_{in} = P_{out}\)  
**Interaction type:** 3-option select with live gauge feedback

**Verified derivation (authoritative):**

\[
F_{in} = P_{out} \times A_{in} = 5000\,\mathrm{Pa} \times 0.02\,\mathrm{m}^2 = 100\,\mathrm{N}
\]

**Scenario (matches shipped — do not use 1000 N):**

```json
{
  "id": "mg04_pressure_scenario",
  "input_area_m2": 0.02,
  "output_area_m2": 0.1,
  "required_output_pressure_pa": 5000,
  "correct_input_force_n": 100,
  "distractor_forces_n": [60, 140]
}
```

**Assets:** press, gauge + needle, force buttons, steam/burst VFX/SFX. Existing: `press.png`, `guage (2).png`.

---

### MiniGame 5 — Pulley Rush (Mechanical Advantage)

**Concept:** \(MA = \mathrm{Load}/\mathrm{Effort}\); need \(MA \ge 4\)  
**Interaction type (target):** Drag-and-drop assembly *(shipped: toggle buttons + Engage)*

**Scenario (matches shipped):**

```json
{
  "id": "mg05_pulley_scenario",
  "load_n": 600,
  "motor_effort_n": 150,
  "required_ma": 4,
  "available_components": [
    {"type": "single_fixed", "ma_contribution": 1},
    {"type": "single_movable", "ma_contribution": 2},
    {"type": "combo_2movable", "ma_contribution": 4}
  ]
}
```

On pass: Momentum Crest + unlock Zone 02. On fail: rope snap → MG1.

**Assets:** rig, pulley types, engine block, MA readout, Lift/Engage. Existing: `rig.png`, `pully (1).png`.

---

## 3. Consolidated Data File

Target file: `final-godot/data/zone01_minigames.json`

```json
{
  "zone": "01_mechanics",
  "minigames": {
    "mg01_brake": { "scenarios": [ /* §2 MG1 shapes; default = shipped numbers */ ] },
    "mg02_gear": { "scenarios": [ /* §2 MG2 */ ] },
    "mg03_balance": { "scenarios": [ /* §2 MG3 */ ] },
    "mg04_pressure": { "scenarios": [ /* §2 MG4 — VERIFIED 100 N */ ] },
    "mg05_pulley": { "scenarios": [ /* §2 MG5 */ ] }
  }
}
```

Each mini-game’s `load_scenario()` should pick a random entry from its `scenarios` array on `start()` so Game Over restarts are not always identical — **only after** each variant is physics-checked.

---

## 4. Shared UI/UX Conventions

- Background art: Zone 01 factory direction — pixel art, 1px dark outline, 2-tone cel, warm afternoon / sodium-lamp palette.
- Reference formulas (μ table, gear ratio, moments, P=F/A, MA) as toggleable **reference cards**, not permanent clutter.
- Countdown bars (MG1, MG3) share one widget style.
- Fail: shared factory-alarm visual/audio sting → Game Over → restart MG1.
- Success transitions between MGs: near-instant (Factory Emergency pacing).

---

## 5. Asset Pipeline Folder Structure (target)

```
Zone01_Factory/assets/   # or keep under asset/sprites/Environment/ (current)
├── backgrounds/   mg01_brake_bg … mg05_pulley_bg
├── sprites/       gears, weight blocks, lever states, pulley parts, engine block
├── ui/            countdown_bar, pressure_gauge_*, ma_indicator, reference_card_*, buttons/
├── vfx/           dust / crash / spark / steam sheets
└── audio/         per-MG SFX + sfx_factory_alarm_fail.ogg (shared)
```

**Workflow:** Nano Banana + Zone 01 reference → Krita cleanup (especially text) → PNG at resolutions matching existing Zone 01 floors / `mg1_ramp_bg.png` (1376×768 playfield class) → short .ogg SFX, consistent levels.

Current project keeps MG art under `asset/sprites/Environment/` (see master §7). Prefer extending that tree over inventing a second parallel folder unless relocating as a deliberate rename pass.

---

## 6. Integration Checklist

- [ ] Create `MiniGameBase.gd`; migrate five scripts to extend it (or wrap without breaking SceneManager paths)
- [ ] Build `zone01_minigames.json` — **MG4 uses 100 N**, not 1000 N
- [ ] Implement `MiniGameSequence.gd` + optional `MiniGameSequence.tscn` OR keep scene-to-scene chain with shared Game Over sting
- [ ] Wire `mini_game_passed` / `mini_game_failed` (or keep SceneManager next/MG1 until sequence lands)
- [ ] Final MG5 pass → `BadgeManager.award_badge("momentum_crest")` + `GameState.unlock_next_zone("zone_01")` + crest cutscene (ceremony UI still MISSING)
- [ ] Any-stage fail → shared factory-alarm Game Over → restart MG1 (floors 1–3 stay passed)
- [ ] Confirm export resolution against existing Zone 01 assets before batch-generating
- [ ] Randomize scenario pick from JSON `scenarios` arrays on each `start()`

---

*End of implementation spec. Authoritative short design + shipped numbers remain in `PHYSICS_QUEST_MASTER.md` §33.*
