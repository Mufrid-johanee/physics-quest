# Zone 02 — Energy Refinery: Scene Design
**Companion to:** physics_quest_zones_02-05_gdd.md
**Format:** 2D pixel art, single-screen scenes with parallax background layers (matches locked art direction: 1px dark outline, 2-tone cel shading, warm afternoon palette)

### Rebuild note (`d:\capstone 2`, 2026-09-21)

This file is **design exploration** for an Energy Refinery layout. **Canonical Zone 02** in the rebuild is the Assessment Wing / Map C path with badge **Radiant Crest**. Floor4 mini-game is a simple **PLAY → SUCCESSFUL placeholder** (sets `zone02_badge_earned`); Harbor Works (`MiniGame02_HarborWorks.tscn`) remains on disk as unused legacy. Living status: `Docs/PROGRESS.md`, `Docs/MINIGAME_IMPLEMENTATION.md`, `Docs/MASTER_GAME_SPEC.md`.

Working assumption, flag if wrong: each floor is one primary screen (not a scrolling level) containing a dialogue/quiz kiosk zone and a mini-game trigger zone, connected to the next floor via a stairwell/elevator transition screen — same shape as Zone 01's factory floors. Interior lighting stays warm (sodium-vapor industrial lamps, dusty light shafts) to keep the palette consistent even though these are indoor scenes.

---

## 0. Refinery Exterior / Hub

**Purpose:** Entry point, establishes scale and industrial identity before the player goes inside. Doubles as the zone-select/return screen.

- **Layout:** Wide single screen, refinery building fills most of the frame — reuse and re-skin the approved Zone 01 factory silhouette language (tall, industrial, vertical pipework) but swap the color-coded pipe accents to signal "energy" rather than "mechanics" — amber/copper piping instead of Zone 01's palette, with a few visibly glowing conduits to hint at the "potential → kinetic" conversion theme before the player even steps inside.
- **Set dressing:** Storage tanks, a loading crane silhouette, a sign reading the refinery's name, steam/heat-shimmer particle effect over one stack.
- **NPC placement:** Foreman Rina stands at the entrance, arms crossed, functions as the zone's gatekeeper/tutorial trigger.
- **Interactive elements:** Door/gate = transition to Floor 1. Optional side path to a "records office" prop if you want a lore/flavor-text kiosk (non-mandatory, matches Zone 01's optional flavor content if that pattern exists).
- **Lighting/mood:** Late-afternoon warm key light from screen-left, long shadows off the tanks, one or two amber window-glows to foreshadow the interior lighting.
- **Audio cue:** Distant industrial hum, occasional steam-release hiss — establishes the ambient bed before Floor 1's loop kicks in.

---

## 1. Floor 1 — Loading Dock (Work & Power)

**Purpose:** Home of the crate-pushing mini-game; visually reads as a shipping/receiving bay.

- **Layout:** Ground-level single screen, wide and shallow (readable sightline for a horizontal push mechanic). Loading bay doors along the back wall, floor marked with distance-tick lines (doubles as a diegetic ruler for the work/distance mechanic).
- **Set dressing:** Stacked crates of varying visual weight (small/medium/large, hinting at mass differences before the player even touches the mini-game), a wall-mounted force gauge prop (big analog dial — this becomes the mini-game's live readout), a conveyor belt frame in the background (idle, not yet functional — visual setup for later floors).
- **Interactive elements:**
  - Mini-game trigger: the marked floor lane with crates, stage-left.
  - Quiz kiosk: a wall terminal stage-right, styled as a shift-log clipboard station.
  - Rina's dialogue mark: standing near the force gauge, so her lines can reference it directly.
- **Lighting/mood:** Harsh-but-warm sodium lamps overhead, dusty light shafts from high windows, slight motion-blur dust particles for atmosphere.
- **Audio cue:** Metal-on-concrete crate scrape (tied to the mini-game action), background clank loop.

---

## 2. Floor 2 — Drop Tower Room (Energy & Conservation)

**Purpose:** Vertical scene to sell the PE→KE drop mechanic; also houses the pendulum variant.

- **Layout:** Tall vertical single screen (this floor should read taller than Floor 1 — a good visual cue that "we've moved up a level" both narratively and literally). Drop-tower rig dominates the center: a vertical rail with an adjustable-height platform.
- **Set dressing:** Height markers along the rail (diegetic h for PE = mgh), a pendulum rig off to one side sharing the same rail structure re-used as a swing arm, a floor-level "catch basin" with a soft-looking cushion pad for tonal safety (keeps the drop mechanic visually playful rather than alarming).
- **Interactive elements:**
  - Mini-game trigger: the drop rig itself, center screen.
  - Secondary mini-game state: pendulum rig, screen-right (same trigger, second phase).
  - Quiz kiosk: mounted at the base of the rail, styled as a control console with the live PE/KE readout above it.
- **Lighting/mood:** Slightly cooler-warm than Floor 1 to differentiate (still within the warm palette but shifted toward late-afternoon gold rather than sodium-amber), a single strong light shaft down the rail's vertical axis for visual drama on drop moments.
- **Audio cue:** Rail creak, a soft impact thud on landing, pendulum swing whoosh.

---

## 3. Floor 3 — Machine Shop (Simple Machines)

**Purpose:** The most prop-dense scene — this is where the player assembles machines, so it needs modular, readable pieces.

- **Layout:** Wide single screen split into modular "workbenches," each pre-fitted for one simple machine type (lever bench, pulley frame, ramp bay). Player interacts bench-to-bench rather than one central rig.
- **Set dressing:** A lever bench with a visible fulcrum track, a pulley frame bolted to the ceiling with hanging rope/chain, an adjustable ramp on wheels, background pegboard wall with tool silhouettes (pure flavor, reinforces "workshop" identity), a friction-grime visual variant applied to select benches once the friction mechanic unlocks (worn, oil-stained versions of the same props).
- **Interactive elements:**
  - Mini-game trigger: each bench is its own interaction point, selected via a bench-select prompt.
  - Quiz kiosk: a shared terminal at the shop's entrance, framed as a job-ticket board.
  - Rina's dialogue mark: floating between benches depending on which one is active (simplifies to "stands near whichever bench the player just approached").
- **Lighting/mood:** Warmest of the four floors — deliberately, since this is the emotional midpoint before the efficiency reveal on Floor 4. Overhead work-lamps over each bench, warm pooled light rather than even coverage.
- **Audio cue:** Chain rattle, rope creak, wood-on-wood ramp adjustment — each bench gets a distinct small foley cue.

---

## 4. Floor 4 — Control Room (Efficiency & Capstone)

**Purpose:** The synthesis/boss scene — needs to feel like the "brain" of the refinery, visually tying the previous three floors together.

- **Layout:** Single screen, control-room framing — a bank of monitors/gauges along the back wall showing simplified schematic views of Floors 1–3's machines (small stylized icons: a crate lane, a drop rig, a lever bench), all feeding into one central console.
- **Set dressing:** The central console is the capstone interaction point — its screen shows the input/output energy readout described in the GDD. A large wall schematic behind it visually chains the three prior floors' icons into one pipeline, so the player can *see* the energy-loss chain they're diagnosing, not just read numbers.
- **Interactive elements:**
  - Capstone trigger: the central console.
  - Upgrade-selection panel: a secondary console beside it, styled as a parts/budget requisition screen.
  - Rina's dialogue mark: standing beside the console for the final beat, tonal shift from terse-taskmaster to something closer to proud, since this is the zone's payoff.
- **Lighting/mood:** Cooler-toned monitor glow mixed into the warm base palette — the one floor allowed a slight color contrast, to signal "this is the analytical/climax room" without breaking the overall warm identity (monitor light reads as an accent, not a palette shift).
- **Audio cue:** Low electrical hum, console beeps tied to the efficiency calculation, a distinct rising stinger on successful repair (ties to the "efficiency gain" audio file already specced).

---

## 5. Stairwell / Elevator Transition Screen

**Purpose:** Reusable connective scene between floors, keeps floor-to-floor travel diegetic without needing a new background per transition.

- **Layout:** Narrow vertical single screen, industrial stairwell or freight elevator (pick one — elevator is cheaper to animate since it's a static cage plus a moving floor-number readout; stairwell needs a walk-cycle loop but reinforces the "climbing toward the answer" metaphor). Recommend elevator for asset economy, matching the constraint-driven choice already made to go 2D over 2.5D.
- **Set dressing:** Floor-number indicator (also doubles as a progress UI element), a small maintenance sign per floor reinforcing the topic ("Loading Dock — Work & Power," etc.) for wayfinding.
- **Interactive elements:** Floor-select if you want free backtracking for quiz review, or a simple forward-only prompt if progression is linear — flag which model Zone 01 uses so this stays consistent.
- **Lighting/mood:** Dimmer and more neutral than the floors themselves — a deliberate visual "breath" between busier scenes.
- **Audio cue:** Elevator mechanism hum/clunk on arrival.

---

## Open Questions Before Art Prompts

1. **Elevator vs. stairwell** for the transition scene — recommending elevator for asset economy, but confirm against whatever Zone 01 used.
2. **Floor navigation model** — linear-only or free backtrack between floors for quiz review?
3. Should Floor 3's multi-bench layout be one scene with bench-select, or should each bench (lever/pulley/ramp) get its own dedicated sub-scene? One-scene is cheaper to produce; sub-scenes give more visual variety. Flagging since it affects how many background assets we generate.

Once these are settled I'll turn each scene above into full image-generation prompts (background, prop sheets) in the locked art direction, same process used for the opening classroom scene.
