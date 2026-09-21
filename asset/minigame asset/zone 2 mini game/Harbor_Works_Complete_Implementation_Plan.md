# Zone 2, Floor 4 — Harbor Works
## Complete Godot Implementation Plan

## 1. Overview

Harbor Works is the Zone 2, Floor 4 synthesis/Create-level mini-game.

The player acts as a harbor engineer designing a machine that lifts cargo onto a ship deck. The player:

1. Reads a brief.
2. Builds a machine chain using sliding tiles.
3. Adjusts available machine parameters.
4. Predicts the required input energy.
5. Launches the machine.
6. Observes the simulation.
7. Compares the prediction with the actual result.
8. Iterates on failed designs without resetting the board.
9. Earns up to three stars for each successful brief.

The implementation uses **only the existing visual assets listed in Section 4**. No additional PNG, sprite, icon, button image, grid image, particle image, arrow image, or other visual asset is required.

All other interface elements are created with native Godot Controls, text, containers, `StyleBoxFlat`, code-driven modulation, and animation.

---

## 2. Core Gameplay Concept

The game uses a **4×4 workshop grid**.

The machine begins at the left with an energy source and must connect through machine tiles to the cargo crate on the right.

```text
SOURCE                                      LOAD

[Motor] → [Pulley] [   .   ] [   .   ] ┐
          [   .   ] [ Ramp ] [   .   ] ├→ [Crate]
          [   .   ] [   .   ] [ Lever ] ┘
```

The player constructs a valid machine, predicts its performance, runs it, inspects the outcome, and revises the design.

---

# 3. Existing Asset Constraint

Use only these existing assets:

```text
harbor_works_bg.png
cargo_crate.png

motor_straight.png
motor_elbow.png
hand_crank_straight.png
hand_crank_elbow.png
counterweight_straight.png
counterweight_elbow.png
fixed_pulley_straight.png
fixed_pulley_elbow.png
movable_pulley_straight.png
movable_pulley_elbow.png
ramp_straight.png
ramp_elbow.png
liver_straight.png
liver_elbow.png

read_out_panel.png
star_empty.png
star_filled.png
```

Do not add additional image assets.

### Lever filename note

The current files are named `liver_straight.png` and `liver_elbow.png`. If these are the lever assets, rename them to `lever_straight.png` and `lever_elbow.png` before coding, or keep the existing names and reference them exactly.

---

# 4. Asset Inventory

## Background

`harbor_works_bg.png`

Use as the static Harbor Works environment.

Godot node:

```text
Background (TextureRect)
```

Recommended:

```text
Layout: Full Rect
Expand Mode: Ignore Size
Stretch Mode: Keep Aspect Covered
```

Do not bake the 4×4 grid into the background.

## Cargo

`cargo_crate.png`

Use as the moving load.

Godot node:

```text
CargoCrate (Sprite2D)
```

The mass is supplied by the active brief and must not be baked into the image.

## Machine tiles

### Motor

```text
motor_straight.png
motor_elbow.png
```

```text
Power = 400 W
MA = 1
η = 1.00
Adjustable = No
```

### Hand Crank

```text
hand_crank_straight.png
hand_crank_elbow.png
```

```text
Power = 100 W
MA = 1
η = 1.00
Adjustable = No
```

### Counterweight

```text
counterweight_straight.png
counterweight_elbow.png
```

```text
Stored potential-energy source
Drop height = 5 m
Mass = 50–200 kg
Step = 1 kg
```

### Fixed Pulley

```text
fixed_pulley_straight.png
fixed_pulley_elbow.png
```

```text
MA = 1
η = 0.95
Adjustable = No
```

### Movable Pulley

```text
movable_pulley_straight.png
movable_pulley_elbow.png
```

```text
MA = 2
η = 0.90
Adjustable = No
```

### Ramp

```text
ramp_straight.png
ramp_elbow.png
```

```text
MA = 1 / sin(θ)
η = 0.90
Angle = 10°–40°
```

Use a native Godot `HSlider` for the angle.

### Lever

```text
liver_straight.png
liver_elbow.png
```

```text
η = 0.95
Ratio = 1:1–1:4
```

Use a native `OptionButton` for the ratio.

## UI

`read_out_panel.png`

Use as the background for the simulation results panel.

`star_empty.png`

Use for an unearned star.

`star_filled.png`

Use for an earned star.

---

# 5. Recommended Project Structure

```text
Zone02_HarborWorks/
│
├── HarborWorks.tscn
│
├── scripts/
│   ├── HarborWorks.gd
│   ├── TileData.gd
│   ├── MachineTile.gd
│   ├── BoardGrid.gd
│   └── Simulator.gd
│
├── data/
│   └── briefs.json
│
└── assets/
    ├── harbor_works_bg.png
    ├── cargo_crate.png
    ├── motor_straight.png
    ├── motor_elbow.png
    ├── hand_crank_straight.png
    ├── hand_crank_elbow.png
    ├── counterweight_straight.png
    ├── counterweight_elbow.png
    ├── fixed_pulley_straight.png
    ├── fixed_pulley_elbow.png
    ├── movable_pulley_straight.png
    ├── movable_pulley_elbow.png
    ├── ramp_straight.png
    ├── ramp_elbow.png
    ├── liver_straight.png
    ├── liver_elbow.png
    ├── read_out_panel.png
    ├── star_empty.png
    └── star_filled.png
```

---

# 6. Main Scene

Create:

```text
HarborWorks.tscn
```

Root:

```text
HarborWorks (Control)
```

Recommended tree:

```text
HarborWorks
│
├── Background (TextureRect)
│
├── BoardArea (Control)
│   ├── SourceZone (Control)
│   ├── BoardGrid (GridContainer)
│   │   ├── Slot_00
│   │   ├── Slot_01
│   │   ├── ...
│   │   └── Slot_15
│   └── LoadZone (Control)
│       └── CargoCrate (Sprite2D)
│
├── TilePalette (Panel)
│
├── BriefPanel (Panel)
│
├── PredictionPanel (Panel)
│   ├── PredictionTitle (Label)
│   ├── PredictionInput (LineEdit)
│   └── LaunchButton (Button)
│
├── ReadoutPanel (TextureRect)
│   ├── EnergyLabel (Label)
│   ├── TimeLabel (Label)
│   ├── ForceLabel (Label)
│   ├── EfficiencyLabel (Label)
│   ├── PredictionLabel (Label)
│   ├── ErrorLabel (Label)
│   └── StatusLabel (Label)
│
└── StarsPanel (HBoxContainer)
    ├── Star1 (TextureRect)
    ├── Star2 (TextureRect)
    └── Star3 (TextureRect)
```

---

# 7. Background

Assign `harbor_works_bg.png` to `Background`.

The background remains static.

All gameplay elements are layered above it.

---

# 8. 4×4 Board

Use a `GridContainer` with:

```text
columns = 4
rows = 4
```

Create 16 slots.

Do not create a board image.

Use native `Panel` or `Control` nodes for slots. Style them with `StyleBoxFlat`.

Possible states:

- Normal
- Empty
- Selected
- Valid destination
- Invalid connection

---

# 9. Sliding-Tile Mechanic

Tiles may move only into an adjacent empty slot.

Example:

```text
Before:

[A][B][ ][C]

Move B right:

[A][ ][B][C]
```

Implementation:

1. Detect the selected tile.
2. Find the empty slot.
3. Check adjacency.
4. Move the tile.
5. Update the board array.
6. Update the tile's visual position.
7. Recalculate connections.

Do not allow arbitrary free dragging across the board.

---

# 10. Tile Scene

Create:

```text
MachineTile.tscn
```

Tree:

```text
MachineTile (Control)
└── Sprite (Sprite2D)
```

Attach:

```text
MachineTile.gd
```

Store:

```text
tile_id
tile_type
orientation
ports
eta
ma
adjustable
```

---

# 11. TileData Resource

Create:

```text
TileData.gd
```

Suggested properties:

```gdscript
@export var id: String
@export var type: String
@export var eta: float
@export var ma: float
@export var ports: Array[String]
@export var adjustable: bool
```

Additional properties may include:

```text
power_w
mass_kg
angle_deg
lever_ratio
drop_height_m
```

as appropriate.

---

# 12. Port System

Every tile has four possible connection directions:

```text
        UP
         ↑
         │
LEFT ← TILE → RIGHT
         │
         ↓
       DOWN
```

Represent ports in code.

Example straight:

```gdscript
["LEFT", "RIGHT"]
```

Example elbow:

```gdscript
["RIGHT", "DOWN"]
```

A valid machine requires adjacent ports to connect correctly.

---

# 13. Source and Load

The source enters from the left edge.

The cargo crate is the load at the right edge.

Validation must identify:

```text
Source → connected tiles → Load
```

A valid machine needs a continuous source-to-load path.

---

# 14. Tile Palette

Use the existing tile images directly as palette previews.

Suggested layout:

```text
MACHINE TILES

[Motor]       [Hand Crank]
[Counterweight]

[Fixed Pulley] [Movable Pulley]

[Ramp]         [Lever]
```

Use native `TextureButton`, `Button`, `Panel`, `HBoxContainer`, and `VBoxContainer`.

No additional icon assets are required.

---

# 15. Adjustable Tiles

## Counterweight

Use `SpinBox`:

```text
Mass: [100] kg
```

Range:

```text
50–200 kg
step = 1 kg
```

## Ramp

Use `HSlider`:

```text
Angle: 25°
```

Range:

```text
10°–40°
step = 1°
```

## Lever

Use `OptionButton`:

```text
Ratio:
1:1
1:2
1:3
1:4
```

Values update the selected tile's data.

---

# 16. Brief Panel

Generate the panel using native Godot controls.

Example:

```text
HARBOR WORKS

LOAD THE CARGO SHIP

Cargo: 60 kg
Lift height: 4 m

Maximum input energy: 3000 J
Maximum time: 10 s
```

All values come from `briefs.json`.

---

# 17. Prediction Input

Use a `LineEdit`.

Example:

```text
Predicted Input Energy

[ 2500 ] J
```

Reject:

- Empty values
- Invalid numeric input
- Negative values

The player must provide a prediction before launch.

---

# 18. Launch Button

Use a native Godot `Button` with text:

```text
LAUNCH
```

On press:

```text
Launch
→ Validate
→ Evaluate physics
→ Animate
→ Read out result
→ Award stars
```

No launch image is required.

---

# 19. Simulator

Create:

```text
scripts/Simulator.gd
```

The core function:

```gdscript
func evaluate(chain, brief) -> Dictionary:
```

Return:

```gdscript
{
    "energy_in": ...,
    "time": ...,
    "force": ...,
    "eta_total": ...,
    "ke_arrival": ...,
    "failed_constraints": [...]
}
```

Keep this function independent from scene nodes.

---

# 20. Physics Constants and Formulas

Use:

```gdscript
const G := 9.8
```

Required formulas:

```text
W = mgh
P = W/t
KE = ½mv²
η = W_out / W_in
```

For machine chains:

```text
η_total = η1 × η2 × η3 × ...
MA_total = MA1 × MA2 × MA3 × ...
```

---

# 21. Source Physics

## Motor

```text
Power = 400 W
```

Calculate time from the required input energy and power.

## Hand Crank

```text
Power = 100 W
```

Calculate time using the same physics model.

## Counterweight

```text
PE = mgh
```

with:

```text
h = 5 m
g = 9.8 m/s²
```

Delivered energy:

```text
PE × η_total
```

---

# 22. Machine Physics

## Fixed Pulley

```text
MA = 1
η = 0.95
```

## Movable Pulley

```text
MA = 2
η = 0.90
```

## Ramp

```text
MA = 1 / sin(θ)
η = 0.90
```

## Lever

```text
η = 0.95
ratio = 1:1–1:4
```

The selected ratio determines the effective mechanical advantage.

---

# 23. Brief Data

Create:

```text
data/briefs.json
```

Suggested structure:

```json
{
  "briefs": [
    {
      "id": "brief_1",
      "title": "Load the Cargo Ship",
      "mass_kg": 60,
      "height_m": 4,
      "max_energy_j": 3000,
      "max_time_s": 10,
      "sources": ["motor", "crank"]
    },
    {
      "id": "brief_2",
      "title": "Rescue the Lifeboat",
      "mass_kg": 120,
      "height_m": 2,
      "max_energy_j": 3200,
      "max_time_s": 12,
      "max_force_n": 400,
      "sources": ["motor", "crank"]
    },
    {
      "id": "brief_3",
      "title": "Storm Blackout",
      "mass_kg": 100,
      "height_m": 3,
      "counterweight_only": true,
      "max_arrival_speed_mps": 1,
      "sources": ["counterweight"]
    }
  ]
}
```

Do not add constraints that are not part of the agreed specification.

---

# 24. Brief 1 — Load the Cargo Ship

```text
Load = 60 kg
Height = 4 m
Maximum input energy = 3000 J
Maximum time = 10 s
```

Required gravitational work:

```text
W = 60 × 9.8 × 4
  = 2352 J
```

Every stated constraint must be satisfied.

---

# 25. Brief 2 — Rescue the Lifeboat

```text
Load = 120 kg
Height = 2 m
Maximum input energy = 3200 J
Maximum time = 12 s
Maximum effort force = 400 N
```

Required work:

```text
W = 120 × 9.8 × 2
  = 2352 J
```

All constraints must be satisfied.

---

# 26. Brief 3 — Storm Blackout

```text
Load = 100 kg
Height = 3 m
Source = Counterweight only
Maximum arrival speed = 1 m/s
```

Required gravitational work:

```text
W = 100 × 9.8 × 3
  = 2940 J
```

Delivered energy determines the arrival kinetic energy.

The arrival-speed constraint must be satisfied.

---

# 27. Simulation Sequence

When `LAUNCH` is pressed:

```text
1. Disable board editing.
2. Validate the source.
3. Validate the source-to-load path.
4. Validate tile connections.
5. Calculate total MA.
6. Calculate total efficiency.
7. Calculate input energy.
8. Calculate force.
9. Calculate time.
10. Calculate arrival KE where required.
11. Compare against brief constraints.
12. Animate the machine.
13. Animate the cargo.
14. Display actual results.
15. Calculate prediction accuracy.
16. Calculate stars.
17. Allow iteration if failed.
```

---

# 28. Energy Flow Animation

No energy-flow image is required.

Use existing tile sprites and code-driven effects.

During simulation, highlight tiles in source-to-load order using `modulate` or `self_modulate`.

Example:

```text
Source
  ↓
Tile 1 highlighted
  ↓
Tile 2 highlighted
  ↓
Tile 3 highlighted
  ↓
Cargo
```

This provides feedback without additional assets.

---

# 29. Cargo Animation

Use:

```text
cargo_crate.png
```

as a `Sprite2D`.

Animate with a Godot `Tween`:

```text
Launch
→ Energy travels through chain
→ Cargo rises
→ Cargo reaches target
→ Stop
```

For Brief 3, use the calculated arrival velocity to determine whether the speed constraint is met.

---

# 30. Readout Panel

Use:

```text
read_out_panel.png
```

as the visual background.

Place dynamic Labels over it.

Example:

```text
INPUT ENERGY       2904 J
TIME               7.26 s
FORCE              294 N
EFFICIENCY         81%

PREDICTED          3000 J
ERROR              3.31%

STATUS             PASSED
```

All values are generated at runtime.

---

# 31. Prediction Accuracy

Use:

```text
error_percent =
abs(prediction - actual) / actual × 100
```

Second star:

```text
error_percent <= 5
```

Do not round before checking the condition.

---

# 32. Star System

Three stars are possible.

### Star 1

All brief constraints pass.

### Star 2

Prediction error is at most 5%.

### Star 3

Overall efficiency is at least 85%.

Use:

```text
star_empty.png
star_filled.png
```

for three `TextureRect` nodes.

---

# 33. Failure Handling

A failed attempt must leave the board exactly as the player left it.

Flow:

```text
Simulation fails
→ Show readout
→ Explain failed constraint
→ Keep board unchanged
→ Player adjusts design
→ Launch again
```

Do not automatically reset the board after a failed attempt.

---

# 34. Failure Readout

Example:

```text
FAILED

ENERGY LIMIT EXCEEDED

Actual: 3226 J
Limit: 3000 J
Exceeded by: 226 J
```

Another example:

```text
FAILED

TIME LIMIT EXCEEDED

Actual: 24.0 s
Limit: 10.0 s
Exceeded by: 14.0 s
```

Or:

```text
FAILED

FORCE LIMIT EXCEEDED

Actual: 588 N
Limit: 400 N
Exceeded by: 188 N
```

Use Labels only.

---

# 35. Multiple Failed Constraints

Store all failures in:

```gdscript
failed_constraints
```

If multiple constraints fail, show all relevant values.

Example:

```text
FAILED

2 CONSTRAINTS FAILED

Energy: +226 J
Time: +4.2 s
```

---

# 36. Board State

Maintain a board array:

```gdscript
var board: Array = []
```

Each position contains either:

```text
null
```

or a tile/data reference.

Update the board data first, then update the visuals.

This keeps physics and visuals synchronized.

---

# 37. Connection Validation

Before simulation, check:

1. Valid source.
2. Valid load.
3. Source-to-load path.
4. Matching adjacent ports.
5. Brief source restrictions.
6. No broken connection along the active chain.

For Brief 3, reject a motor or crank because the source must be a counterweight.

---

# 38. UI Styling Without New Assets

Use native Godot controls:

```text
Panel
PanelContainer
Button
TextureButton
Label
LineEdit
SpinBox
HSlider
OptionButton
HBoxContainer
VBoxContainer
GridContainer
ColorRect
```

Use `StyleBoxFlat` for:

- panel borders
- buttons
- hover state
- pressed state
- disabled state
- selected tiles
- success state
- failure state

No additional images are needed.

---

# 39. Development Order

## Phase 1 — Scene

Create:

```text
HarborWorks.tscn
Background
BoardArea
TilePalette
BriefPanel
PredictionPanel
ReadoutPanel
StarsPanel
```

## Phase 2 — Asset Integration

Import and position:

```text
harbor_works_bg.png
cargo_crate.png
```

Verify scale and composition.

## Phase 3 — Board

Implement:

```text
4×4 grid
16 slots
empty-slot tracking
tile movement
```

## Phase 4 — Tiles

Implement all seven machine types.

Verify:

```text
straight
elbow
ports
selection
movement
```

## Phase 5 — Parameters

Implement:

```text
Counterweight mass
Ramp angle
Lever ratio
```

## Phase 6 — JSON

Load all three briefs dynamically.

## Phase 7 — Simulator

Implement and test:

```text
Simulator.gd
evaluate()
```

## Phase 8 — Connection Validation

Implement:

```text
source → tiles → load
```

## Phase 9 — Prediction

Add:

```text
LineEdit
prediction
error percentage
```

## Phase 10 — Launch

Connect:

```text
Launch
→ validation
→ physics
→ simulation
```

## Phase 11 — Animation

Add:

```text
tile highlighting
energy-flow effect
cargo movement
```

using code and existing sprites.

## Phase 12 — Readout

Connect `read_out_panel.png` to runtime values.

## Phase 13 — Stars

Implement the three-star system.

## Phase 14 — Failure Iteration

Keep failed board layouts intact and allow modification/retry.

## Phase 15 — Full Testing

Test all three briefs from a fresh state.

---

# 40. Final Runtime Flow

```text
HARBOR WORKS
      ↓
Read Brief
      ↓
Select Source
      ↓
Arrange 4×4 Machine
      ↓
Adjust Parameters
      ↓
Enter Predicted Energy
      ↓
LAUNCH
      ↓
Validate Machine
      ↓
Calculate Physics
      ↓
Animate Machine
      ↓
Lift Cargo
      ↓
Display Actual Results
      ↓
Compare Prediction
      ↓
Award Stars
      ↓
       ┌───────────────┐
       │               │
     FAIL            PASS
       │               │
       ↓               ↓
Modify Design      Record Stars
       │               │
       └──→ Retry      ↓
                   Next Brief
                       ↓
                   All 3 Pass
                       ↓
                 Floor Complete
```

---

# 41. Final Asset Usage Check

| Asset | Runtime use |
|---|---|
| `harbor_works_bg.png` | Static Harbor Works environment |
| `cargo_crate.png` | Animated cargo/load |
| `motor_straight.png` | Straight motor tile |
| `motor_elbow.png` | Elbow motor tile |
| `hand_crank_straight.png` | Straight crank tile |
| `hand_crank_elbow.png` | Elbow crank tile |
| `counterweight_straight.png` | Straight counterweight tile |
| `counterweight_elbow.png` | Elbow counterweight tile |
| `fixed_pulley_straight.png` | Straight fixed pulley |
| `fixed_pulley_elbow.png` | Elbow fixed pulley |
| `movable_pulley_straight.png` | Straight movable pulley |
| `movable_pulley_elbow.png` | Elbow movable pulley |
| `ramp_straight.png` | Straight ramp |
| `ramp_elbow.png` | Elbow ramp |
| `liver_straight.png` | Straight lever |
| `liver_elbow.png` | Elbow lever |
| `read_out_panel.png` | Simulation result panel |
| `star_empty.png` | Unearned star |
| `star_filled.png` | Earned star |

**No other image assets are required.**

---

# 42. Architecture Summary

Keep the implementation separated into:

```text
Visual Assets
      ↓
Godot Scene
      ↓
BoardGrid
      ↓
TileData
      ↓
Connection Validator
      ↓
Simulator
      ↓
Brief Constraints
      ↓
Readout
      ↓
Stars
```

The important separation is:

- **Board state** handles tile positions.
- **TileData** handles machine properties.
- **Connection validation** handles whether the machine is physically connected.
- **Simulator** handles physics.
- **Brief JSON** handles scenario constraints.
- **UI** displays the state and results.
- **Existing PNGs** provide all visual artwork.

This keeps the Harbor Works implementation testable and allows the physics, briefs, and tile parameters to be changed without rebuilding the visual scene.
