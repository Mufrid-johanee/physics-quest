# Physics Quest — Zones 02–05 GDD
**Status:** Skeleton locked for Zones 03–05, full design for Zone 02
**Curriculum:** Bangladesh Class 9–10 Physics
**Engine:** Godot 4, 2D pixel art (1px dark outline, 2-tone cel shading, warm afternoon palette)
**Companion docs:** Master Context MD, Zone 01 GDD MD

### Rebuild note (`d:\capstone 2`, 2026-09-21) — SUPERSEDED zone identities for gameplay

This GDD’s Zone 03–05 names (Matter Labs / Wave Observatory / Citadel) are **not** the shipped rebuild identities. Prefer `Docs/MASTER_GAME_SPEC.md` + `Docs/PHYSICS_QUEST_MASTER.md` decided map:

| Zone | Canonical location | Canonical badge |
|------|--------------------|-----------------|
| 01 | Mechanics Factory | Momentum Crest |
| 02 | Energy / Assessment Wing | Radiant Crest |
| 03 | Signal Station | Spectrum Crest |
| 04 | The Substation | Spark Emblem |

Keep this file for historical / alternate design ideas only.

---

## 1. Zone Map Overview

| Zone | Name | Curriculum Topics | Setting Hook |
|---|---|---|---|
| 01 | Mechanics Factory | Measurement, Motion, Force | Factory floor — *(locked, built)* |
| 02 | Energy Refinery | Work, Power, Energy, Simple Machines | A plant that turns raw "potential" into usable "kinetic" output |
| 03 | Matter Labs | States of Matter, Pressure, Density, Buoyancy | A research campus studying how matter behaves under stress |
| 04 | Wave Observatory | Heat, Waves, Sound | A cliffside observatory tracking things that travel — heat, ripples, noise |
| 05 | Light & Circuits Citadel | Optics, Electricity, Magnetism | A fortified control citadel running the city's power and signal grid |

Note flagged for later: Zone 05 is curriculum-dense (three sizeable chapters). Once we scope its floor count, we may split it into 05a (Optics) and 05b (Electricity & Magnetism) rather than force three chapters into four floors. Revisit after Zone 04 is designed.

Each zone keeps Zone 01's skeleton: 4 floors, each floor built around one Bloom's Taxonomy tier (Remember/Understand → Apply → Analyze → Evaluate/Create), 50 questions per floor (200 per zone), one signature mini-game per floor, a capstone challenge on the top floor.

---

## 2. Zone 03 — Matter Labs (skeleton)

**Curriculum:** States of matter & change of state, pressure in solids/liquids/gases, density, Archimedes' principle & buoyancy.

**Hub flavor:** A campus of glass-walled labs where the player's job is to keep matter behaving — or figure out why it isn't.

| Floor | Topic | Bloom's Tier | Mini-Game Concept |
|---|---|---|---|
| 1 | States of matter, change of state (melting/boiling/condensing) | Remember/Understand | Sort particles into solid/liquid/gas bins as temperature dial changes in real time |
| 2 | Pressure (P = F/A), pressure in liquids | Apply | Balance pressure gauges by adjusting force/area sliders on sealed chambers before they blow |
| 3 | Density, relative density | Analyze | Identify unknown substances by measuring mass/volume and matching to a density table |
| 4 | Buoyancy, Archimedes' principle | Evaluate/Create | Design a vessel (adjust shape/material) that floats at a target displacement — ties density + buoyancy together |

**Capstone concept:** A "sinking submarine" puzzle — player must diagnose whether the fault is pressure, density, or buoyancy-related using floor 1–3 skills combined, then fix it.

---

## 3. Zone 04 — Wave Observatory (skeleton)

**Curriculum:** Heat & temperature, thermal expansion, specific heat, heat transfer (conduction/convection/radiation), wave properties, sound (speed, pitch, loudness, echo).

**Hub flavor:** An old observatory repurposed to track anything that "travels" — heat through metal, sound through air, waves through water.

| Floor | Topic | Bloom's Tier | Mini-Game Concept |
|---|---|---|---|
| 1 | Temperature vs. heat, thermal expansion | Remember/Understand | Match materials to their expansion behavior as a furnace heats a test rig |
| 2 | Heat transfer (conduction, convection, radiation), specific heat | Apply | Route heat through a building model using the correct transfer method per material |
| 3 | Wave properties (amplitude, wavelength, frequency, speed = fλ) | Analyze | Tune a wave generator to match a target wave read off a graph |
| 4 | Sound (speed of sound, pitch/loudness, echo/reflection) | Evaluate/Create | Design an echo-based "sonar" puzzle — time delay tells you distance to a hidden wall |

**Capstone concept:** A resonance puzzle combining wave tuning (floor 3) and sound reflection timing (floor 4) to "unlock" a vibrating door at its resonant frequency.

---

## 4. Zone 05 — Light & Circuits Citadel (skeleton — provisional)

**Curriculum:** Reflection & refraction, lenses & mirrors, electric circuits (Ohm's law, series/parallel), magnetism & electromagnets.

**Hub flavor:** The city's control citadel — half of it runs on light and signal routing, half on the power grid.

| Floor | Topic | Bloom's Tier | Mini-Game Concept |
|---|---|---|---|
| 1 | Reflection & refraction, mirrors | Remember/Understand | Redirect a light beam through mirrors to hit a target sensor |
| 2 | Lenses (convex/concave), image formation | Apply | Position a lens at the correct distance to focus a beam/image on a screen |
| 3 | Circuits — Ohm's law, series vs. parallel | Analyze | Wire a circuit board to hit a target current/voltage reading |
| 4 | Magnetism, electromagnets, simple motors | Evaluate/Create | Build an electromagnet strong enough to lift a target load by adjusting coil turns/current |

**Open flag:** if four floors feel cramped once we're mid-design, split into 05a (Optics, 2 floors) and 05b (Electricity & Magnetism, 2–3 floors) rather than compress. Decide once Zone 02–04 patterns are proven.

---

## 5. Zone 02 — Energy Refinery (full design)

### 5.1 Narrative Hook

The refinery converts stored "potential" into usable "kinetic" output for the city grid — except output has been dropping and nobody can explain why. The player is sent in as a trainee technician under **Foreman Rina**, a blunt, efficiency-obsessed NPC who treats every physics concept as a production-line problem to be solved, not a textbook fact to be memorized. Across four floors, the player traces the energy loss from raw input (Floor 1: Work & Power) to final output (Floor 4: Simple Machines), discovering by the top floor that the real fault is *inefficiency* — energy isn't vanishing, it's leaking as heat and friction through poorly maintained machines. This sets up the thematic bridge into Zone 03 (Matter Labs), where "what happens to matter under stress" becomes the next question.

**Recurring NPC:** Foreman Rina — same visual/dialogue role Zone 01's teacher played, but industrial rather than academic in voice. She reappears floor to floor with short, task-oriented dialogue rather than long exposition (matches Zone 01's beat-by-beat dialogue pattern, just terser).

### 5.2 Floor Breakdown

**Floor 1 — Work & Power (Remember/Understand)**
- Learning objectives: define work (W = Fd, only the force component along displacement counts), define power (P = W/t), correctly identify when work is/isn't done (e.g., holding a weight stationary = zero work).
- Mini-game — "Loading Dock": player pushes crates across a floor with a force meter and distance markers visible; a scoring readout shows work done in real time. A second phase adds a timer to convert the same task into a power calculation (same work, less time = more power). Deliberately includes a "trick" crate that's held in place, not moved, to test the zero-work misconception directly.
- Quiz distribution (50 Qs): ~20 Remember (definitions, units — Joule, Watt), ~20 Understand (identify work/no-work scenarios), ~10 mixed calculation.

**Floor 2 — Forms of Energy & Conservation (Apply)**
- Learning objectives: calculate kinetic energy (KE = ½mv²) and gravitational potential energy (PE = mgh), apply conservation of energy across a transformation (e.g., falling object, pendulum, roller coaster).
- Mini-game — "Drop Tower": player releases objects of varying mass from adjustable heights on a vertical rig; the game displays PE at the top and asks the player to predict/enter KE at the bottom before it's revealed, reinforcing PE→KE conservation rather than two disconnected formulas. A pendulum variant repeats the same conservation logic sideways.
- Quiz distribution: ~15 Remember/Understand (energy types, units), ~25 Apply (plug values into KE/PE formulas), ~10 conservation-across-a-system word problems.

**Floor 3 — Simple Machines & Mechanical Advantage (Analyze)**
- Learning objectives: identify the six simple machines relevant to the syllabus (lever, pulley, inclined plane, wheel & axle, screw, wedge), calculate mechanical advantage (MA = output force / input force, or load arm ratios for levers), compare ideal vs. real MA when friction is introduced.
- Mini-game — "Machine Shop Floor": player is given a target load and must choose and configure the right simple machine (lever fulcrum position, pulley count, ramp angle) to move it with the input force available. A "friction" toggle on later levels drops actual output below the ideal calculation, forcing the player to notice and explain the gap — this is the direct setup for Floor 4's efficiency theme.
- Quiz distribution: ~10 Remember (name/identify machines), ~20 Apply (MA calculations), ~20 Analyze (ideal vs. real MA, explain the discrepancy).

**Floor 4 — Efficiency & Capstone (Evaluate/Create)**
- Learning objectives: calculate efficiency (useful output energy / total input energy × 100%), evaluate a multi-machine system for energy loss, propose a fix.
- Mini-game / Capstone — "Fix the Refinery": player is shown a chained system (e.g., pulley → conveyor → lever) with an input energy value and a measured (lower) output value. They must calculate the efficiency, identify which stage is losing the most energy, and choose an upgrade (lubrication, better pulley ratio, shorter lever arm) within a limited budget to hit a target efficiency. This is the "boss" — it requires reusing Floor 1–3 skills (work, energy conservation, mechanical advantage) inside one integrated problem, matching Zone 01's pattern of a synthesis-style top floor.
- Quiz distribution: ~10 Remember/Understand (efficiency definition/formula), ~15 Apply (efficiency calculations), ~25 Analyze/Evaluate (diagnose loss points, justify an upgrade choice).

### 5.3 Asset Needs (spec level — not yet prompted)

- **Backgrounds:** refinery exterior/hub, Floor 1 loading dock, Floor 2 drop-tower rig room, Floor 3 machine shop, Floor 4 control room capstone.
- **Sprites:** Foreman Rina (teacher-equivalent role — same rig/pipeline as the Physics Teacher sprite sheet), refinery worker NPCs (background dressing, no dialogue needed).
- **Props:** crates, force meter, drop-tower rig, pendulum rig, pulley/lever/ramp modular pieces, control panel for the capstone.
- **Audio:** distinct machinery hum/loop per floor (loading dock clank vs. drop-tower creak vs. machine shop grind vs. control-room ambient), a "success" chime shared across zones if one already exists from Zone 01, an "efficiency gain" stinger for the capstone.

This mirrors Zone 01's seven-audio-file, sprite-sheet-plus-background asset pattern — happy to turn this into full image-generation prompts once you approve the floor designs above, the same way we locked the classroom scene prompts.

---

## 6. Suggested Next Steps

1. Confirm Zone 02 floor designs above (or flag changes) before I build the 50×4 question bank JSON and dialogue script.
2. Once Zone 02 is locked, I'll deepen Zone 03, then 04, then resolve the Zone 05 split question.
3. Update the Master Context MD to reflect the 2D (not 2.5D) art direction and this zone map once Zone 02 is fully approved.
