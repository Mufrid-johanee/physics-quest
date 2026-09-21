# Mini-Game 1: Emergency Brake — Implementation Notes

## Game Flow

1. The player passes the Floor 4 Director quiz.
2. `Zone01Manager` plays the Factory Emergency cutscene.
3. When the cutscene ends, call `MiniGameSequence.start_sequence()`. That loads `MiniGame01_Brake.tscn` first.

## Where Things Go

Put the JSON at:

```text
Zone01_Factory/data/zone01_minigames.json
```

Put the script at:

```text
Zone01_Factory/scripts/MiniGame01_Brake.gd
```

Put all PNGs in:

```text
Zone01_Factory/assets/
```

Use the `backgrounds`, `sprites`, `ui`, and `vfx` subfolders specified for the project.

Build `MiniGame01_Brake.tscn` with this node tree and attach the script to the root. The script looks nodes up by these exact names.

```text
MiniGame01_Brake (Control, full rect)
├── Background (TextureRect)      mg01_brake_bg.png, Expand On, Stretch Mode Keep Aspect Covered
├── BlockSprite (Sprite2D)        mg01_steel_block.png
├── CrashBurst (Sprite2D)         crash_burst_spritesheet.png, visible off
└── HUD (Control, full rect)
    ├── InfoLabel (Label)         top left
    ├── QuestionLabel (Label)     center top
    ├── CountdownBar (TextureProgressBar)   texture_progress = countdown_bar.png, max 100
    ├── YesButton (TextureButton)      texture_normal = button_yes.png
    ├── NoButton (TextureButton)       texture_normal = button_no.png
    ├── ForceBox (HBoxContainer)       hidden at start
    │   ├── Force1 (TextureButton)     force_option_button.png, with a child Label named "Label"
    │   ├── Force2 (same)
    │   └── Force3 (same)
    ├── ReferenceToggle (Button)       plain default button, text "Formulas"
    ├── ReferenceCard (TextureRect)    reference_card_friction.png, hidden
    └── ResultLabel (Label)            center, big font
```

### Inspector Settings

On the root node:

- Set `block_start_x` so the block starts at the ramp top.
- Set `crash_x` so the block ends at the wall in the background.
- Set `burst_hframes` and `burst_vframes` to match the grid in `crash_burst_spritesheet.png`.
- The current guess is `6 × 1`; check the actual spritesheet before testing.
- Center each `Label` inside its force button.
- Set the font color to something readable against the button artwork.

## Game Logic

Each attempt:

1. Picks YES or NO at random (50/50).
2. Picks a random scenario from that pool.
3. Avoids showing the same scenario twice in a row.

The screen shows:

- Surface
- Mass
- μ
- Braking force needed to stop before the wall

The question is:

> **Will friction alone stop the block?**

### YES Scenario — Friction Is Enough

The player must answer **YES**.

- YES → pass.
- NO → fail.

### NO Scenario — Friction Falls Short

The player must answer **NO**.

- YES → fail.
- NO → hide the YES/NO buttons.
- Show three force buttons.
- Shuffle the three options.
- The player selects the extra force needed.

The required extra force is:

```text
required force − friction
```

### Timer

The countdown bar and block position share the same countdown.

The block gradually moves toward the wall as time runs out.

- YES scenarios: **12 seconds**
- NO scenarios: **15 seconds**, because they contain two steps
- Timeout → fail

### Friction Calculation

Use:

```text
Friction = μ × mass × 10
```

with:

```text
g = 10
```

This keeps the numbers clean.

### Example

For:

```text
Mass = 40 kg
μ = 0.35
```

The calculation is:

```text
Friction = 0.35 × 40 × 10
         = 140 N
```

If the required braking force is:

```text
360 N
```

then:

```text
Extra force = 360 N − 140 N
            = 220 N
```

Therefore, the correct additional force is:

```text
220 N
```

The two distractors represent common student mistakes:

1. Giving the total required force because friction was not subtracted.
2. Giving the friction value itself.

## What the Missing Assets Are Replaced With

### Hover and Pressed States

Hover and pressed states are handled in code by brightening or darkening the button's `modulate`.

No extra art is required.

Buttons use the same values on mouse-over and press.

### Pass

When the player succeeds:

- The block eases to a stop.
- The result label turns green.
- The result label displays `BLOCK STOPPED`.
- The game waits about **1.3 seconds**.

### Fail

When the player fails:

- The block slides to the wall.
- The crash-burst spritesheet plays over the block.
- The block disappears.
- The result label turns red.
- The result label displays the reason:
  - Wrong answer
  - Wrong force
  - Time's up

### Audio

No sound is currently wired.

Add audio later where:

- `_success()` runs
- `_crash()` runs

## Pass and Fail Outcomes

### Pass

`_pass()` emits:

```text
mini_game_passed
```

The sequence then loads Mini-Game 2.

After MG5 passes:

- The crest is awarded.
- Zone 02 unlocks.

### Fail

`_fail()` emits:

```text
mini_game_failed
```

The sequence:

1. Shows a Game Over overlay.
2. Uses a `ColorRect` and a `Label`.
3. The label reads:

```text
FACTORY DAMAGED
```

4. Reloads MG1 after **2 seconds**.
5. A fresh random scenario is selected.

Floors 1–3 stay unlocked.

## Important Orchestrator Fix

In the spec's orchestrator, `_load_current()` never frees the old mini-game scene.

Add:

```gdscript
queue_free()
```

to the old mini-game scene before loading the next one.

Otherwise, old scenes will pile up behind the new one after each failure.

## Check Before You Test

The file:

```text
reference_card_friction.png
```

may list μ values or a `g` value that differs from the JSON.

The current JSON uses:

```text
g = 10
```

The card contents cannot be verified from the file list.

Before testing:

1. Open `reference_card_friction.png`.
2. Check its μ values.
3. Check its g value.
4. Compare them with `zone01_minigames.json`.
5. Edit whichever source is wrong.

The reference card and the question data must agree; otherwise the physics information presented to the player could conflict with the scenario.
