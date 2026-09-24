# MG1 Specification Audit

**Date:** 2026-09-18  
**Phase:** 10 — MG1 specification + asset audit  
**Policy (at audit time):** Documentation and planning only. **No MG1 gameplay implemented.**

### Amendment 2026-09-21

Emergency Brake is now **implemented** in this rebuild (`MiniGame01_Brake.tscn`). Canonical badge: **Momentum Crest**. This audit remains useful for asset/spec conflict notes; living status: `Docs/MINIGAME_IMPLEMENTATION.md` + `Docs/PROGRESS.md`.

---

## 1. Authoritative Sources

### Source hierarchy for this rebuild (`d:\capstone 2`)

| Priority | Document | Authority for |
|----------|----------|---------------|
| 1 | `Docs/ZONE01_AUDIT.md` + `Docs/MASTER_GAME_SPEC.md` + `Docs/PROGRESS.md` | **Where** MG1 attaches to this project; physical chain; placeholder status; rebuild scope |
| 2 | `Docs/PHYSICS_QUEST_MASTER.md` **§33.1** (+ §7 MG1 asset table, §32 beat 7–8) | **Authoritative GDD** for MG1 identity, numbers, steps, success/fail presentation |
| 3 | `Docs/zone01_minigame_implementation_spec.md` | Scenario object shape, UI pieces, fail→MG1 sequence; **defaults must match §33** |
| 4 | `Docs/MINIGAME_IMPLEMENTATION.md` | **Current** MG status (Z01 Brake + Z03 Fiber Escape real; Z02 + Z04 placeholders; Harbor Works unused legacy) |
| 5 | `Docs/SCENE_IMPLEMENTATION.md` | Current Floor 4 / MG wiring |

### Conflict resolution (do not invent)

| Conflict | Resolution |
|----------|------------|
| Sample JSON force **220 N** vs §33 / shipped **150 N** | Use **150 N** (`zone01_minigame_implementation_spec` explicitly prefers §33) |
| Older master says MG1–5 “IMPLEMENTED” in a prior Godot tree | **Not true for this rebuild** — placeholders only (`ZONE01_AUDIT`) |
| Floor 1 `MG1_Handoff` vs Floor 4 post-Director | **Floor 4 path only** (GDD + Phase 9 audit) |
| Momentum Crest after MG1 vs after MG5 | Crest / Zone 02 unlock after **MG5** success, not MG1 |
| Drag-and-drop GDD vs click/toggle shipped style | Either is valid UX; §33 describes choices; prior ship used click/toggle. **UNSPECIFIED for this rebuild** — pick one in Phase 11 design note, do not invent new physics numbers |

---

## 2. MG1 Identity

| Field | Value |
|-------|--------|
| **Full name** | Emergency Brake |
| **Short id** | MG1 / `MiniGame01_Brake` |
| **Educational topic** | Friction (\(f = \mu N\) / \(f = \mu mg\)), Newton’s Second Law, deceleration |
| **Narrative purpose** | First challenge in the Floor 4 **Factory Emergency** run; stop a sliding block before crash |
| **Where it occurs** | Dedicated mini-game scene after Floor 4 Director path — **not** on Floor 1 walkaround |

---

## 3. Narrative Context

Documented Factory beat (§32 item 7–8):

1. Floor 4 — Director office  
2. Director quiz **≥ 80%**  
3. About to award badge → **phone emergency**  
4. Player offers help → emergency dialogue (`post_pass_lines`)  
5. Continue → **MG1**, then MG2–MG5 in one continuous run  
6. Any GAME OVER → restart from **MG1**  
7. MG5 success → Momentum Crest + unlock Zone 02  

This rebuild currently has Floor 4 Director **intro dialogue only** (no quiz, no emergency). Physical floors are ready; narrative gates are **not** implemented yet.

---

## 4. Entry Condition

### Required (GDD)

| Requirement | Status in this rebuild |
|-------------|------------------------|
| Player on **Floor 4** | Implemented |
| Director interaction / quiz path | Dialogue only — **quiz not implemented** |
| Quiz score **≥ 80%** | **Not implemented** |
| Emergency / `post_pass_lines` beat | **Not implemented** |
| Load MG1 scene | Only via **stub** handoffs |

### Exact state flags (documented / needed)

| Flag | Documented? | In current `GameState.gd`? |
|------|-------------|----------------------------|
| `zone01_director_passed` | Yes (master Floor 4) | **No** |
| Floor quiz passes F1–F3 | Yes (GDD stair gates) | **No** |
| MG sequence index / MG1 complete | Implied by sequence | **No** |
| `zone01_guard_granted` | Exterior | Yes (unrelated to MG1 start) |

### Entry condition summary (canonical)

```
Floor 4
  → Director quiz ≥ 80%
  → set zone01_director_passed (or equivalent)
  → emergency post_pass dialogue
  → player Continue
  → load MiniGame01_Brake (real scene)
```

**Not canonical:** Floor 1 `MG1_Handoff`.

---

## 5. Gameplay Objective

Stop the sliding metal block before it crashes by:

1. Correctly judging that **friction alone is not enough**, then  
2. Selecting the **correct additional braking force**.

Correct path (default scenario): **NO** → **150 N**.

---

## 6. Core Mechanics

### Mechanic A — Data presentation

| | |
|--|--|
| **Player action** | Read mass, surface, μ, distance (and countdown / distance bar) |
| **Game response** | Display scenario constants |
| **Physics** | Informational; \(f = \mu mg\) available for reasoning |
| **Success** | N/A (setup) |
| **Failure** | N/A |

### Mechanic B — Friction-alone question (YES/NO)

| | |
|--|--|
| **Player action** | Choose YES or NO: “Will friction alone stop the block?” |
| **Game response** | Accept choice; branch to force select or fail |
| **Physics** | Default scenario: friction **not** sufficient (`friction_sufficient: false`) |
| **Success condition** | Answer **NO** |
| **Failure condition** | Answer **YES** → crash / GAME OVER → reload MG1 |

### Mechanic C — Additional braking force (3 options)

| | |
|--|--|
| **Player action** | Select one of three force buttons |
| **Game response** | Resolve pass/fail; play stop or crash presentation |
| **Physics** | Extra force supplements friction to stop within distance |
| **Success condition** | Select **150 N** (default) |
| **Failure condition** | Wrong force (documented distractors **50 N**, **250 N**) → crash → GAME OVER → reload MG1 |

### Mechanic D — Outcome presentation

| | |
|--|--|
| **Success** | Block decelerates / stops; screech/dust (optional art); green **PROBLEM SOLVED**; proceed to **MG2** |
| **Failure** | Crash, sparks/alarm (optional); **GAME OVER**; restart **MG1** |

**Interaction style:** GDD mentions side-view sliding block + buttons. Prior ship used **click/toggle**, not full drag physics. Rebuild may use kinematic presentation driven by choices — **do not require** RigidBody2D unless Phase 11 explicitly chooses it.

---

## 7. Physics Requirements

### Documented parameters (default scenario)

| Parameter | Value | Source |
|-----------|-------|--------|
| Mass \(m\) | **40 kg** | §33.1 |
| Surface | Steel on concrete | §33.1 / scenario JSON |
| \(\mu\) | **0.35** | §33.1 |
| Distance | **7 m** | §33.1 |
| Friction alone sufficient? | **false** (correct answer NO) | scenario |
| Correct extra force | **150 N** | §33.1 / master table |
| Distractors | **50 N**, **250 N** | `zone01_minigame_implementation_spec` |
| Countdown | **12 s** (scenario sample) | minigame spec JSON shape |

### Bodies / objects

| Object | Role |
|--------|------|
| Sliding metal **block** | Primary actor |
| Ramp / floor | Visual playfield; stop distance metaphor |
| UI data panel | Numbers, not a physics body |

### Forces / concepts (taught)

- Friction \(f = \mu N\) with \(N = mg\) (horizontal/along-ramp teaching model as documented)  
- Newton’s Second Law / deceleration  
- Extra braking force as additive stopping effort  

### Explicitly UNSPECIFIED (requires design decision — do not invent in docs as fact)

| Item | Status |
|------|--------|
| Gravity magnitude \(g\) (9.8 vs 10) | **UNSPECIFIED** |
| Initial speed \(v_0\) | **UNSPECIFIED** |
| Ramp angle (numeric) | **UNSPECIFIED** (art is diagonal; may be illustrative) |
| Whether simulation is live RigidBody vs choice-driven animation | **UNSPECIFIED** (prior: UI-driven) |
| Exact deceleration formula tying 150 N to 7 m | **UNSPECIFIED** in prose (numbers are authoritative outcomes, not a derived worksheet in GDD) |
| Pixel↔meter scale on `mg1_ramp_bg.png` | **UNSPECIFIED** |
| Countdown zero behavior vs wrong-answer crash timing | Countdown “crash at zero” mentioned; exact tie to wrong answer **partially specified** |

---

## 8. Scoring Requirements

MG1 is **pass/fail**, not a numeric scoreboard.

| Question | Answer from docs |
|----------|------------------|
| What is scored? | Correctness of YES/NO + force choice (binary outcomes) |
| Point formula? | **None documented** |
| Does time matter? | **Yes** — red countdown; crash at zero (§33.1); sample `countdown_seconds: 12` |
| Do attempts matter? | Fail restarts MG1 (and emergency sequence from MG1); attempt count **not** scored |
| Accuracy? | Must pick correct branch; no partial credit documented |
| Thresholds? | N/A beyond correct answers |
| Completion criteria? | Correct NO + correct 150 N → PROBLEM SOLVED → next MG |

**Do not invent** percentage scores for MG1 itself. Floor **quiz** ≥80% is a **separate** gate before entry.

---

## 9. Educational Requirements

| Layer | Documented content |
|-------|-------------------|
| **Concept** | Friction, \(f=\mu mg\), need for additional force, deceleration |
| **Learner action** | Interpret given \(m, \mu, d\); decide if friction alone stops; choose force |
| **Feedback** | Stop + PROBLEM SOLVED vs crash + GAME OVER |
| **Explanation** | μ reference popup / reference card (minigame spec UI list) |
| **Misconception handling** | YES (friction enough) fails — teaches insufficiency |
| **Assessment** | In-challenge binary + 3-option; not a separate quiz bank inside MG1 |

---

## 10. Success / Failure / Retry

| State | Behavior |
|-------|----------|
| **Success** | PROBLEM SOLVED → continue emergency sequence to **MG2** |
| **Failure** | GAME OVER (crash/alarm) → **reload MG1** |
| **Retry** | Full MG1 restart; floors 1–3 quiz progress preserved if those flags exist (spec); mini-game sequence resets to MG1 |
| **Exit mid-run** | **UNSPECIFIED** for this rebuild (pause/quit to map) |
| **Progression flag after MG1 alone** | Sequence advances to MG2 — **not** zone complete |
| **Reward after MG1** | **None** — Momentum Crest after **MG5** |

---

## 11. Asset Inventory

Search: `asset/` for `mg1`, `ramp`, `brake`, `block`, `momentum`, `friction`, related zone 1 MG files.  
**Inspected images:** `mg1_ramp_bg.png`, `badge_momentum_crest (1).png`.

| Asset | Dimensions | Type | Likely Purpose | Confirmed by Docs? |
|-------|------------|------|----------------|--------------------|
| `asset/sprites/Environment/zone 1/mg1_ramp_bg.png` | **1376×768** | Background PNG (RGBA) | Side-view factory ramp playfield | **Yes** — §7 / §33.1 |
| `asset/sprites/Environment/zone 1/badge_momentum_crest (1).png` | **1080×1080** | Badge icon (circular crest on transparent field) | Zone 01 completion reward (**after MG5**, not MG1) | **Yes** — zone reward art |
| `mg1_block (1).png` | — | Sliding block actor | Documented MG1 actor | **Documented but MISSING on disk** |
| `mg1_emergency_brake_block.png` | — | Alternate generation name in master catalog | Block | **Name only — MISSING** |

### Not Zone 01 MG1 (exclude from MG1 wiring)

| Asset | Note |
|-------|------|
| `zone 3/signal_station_mg1_*` | Zone 03 mini-games |
| `zone 4/substation_mg1_*` | Zone 04 mini-game |

### Other zone 1 files (MG2–MG5 / shared — not MG1 playfield)

`mg2_*`, `crane.png`, `load (1).png`, `press.png`, `guage (2).png`, `pully (1).png`, `rig.png`, `weights (1).png` — inventory for later MGs; **do not assign to MG1**.

### `mg1_ramp_bg.png` visual notes (inspection)

- Diagonal metal ramp with yellow/black hazard edges; railings; industrial purple warehouse  
- **Baked-in** foreground crates, barrels, tools — **do not duplicate** as separate prop sprites unless intentionally layered  
- Open upper area suitable for UI overlay  
- Playfield aspect matches World Map / Exterior class (**1376×768**), not floor maps (1296×1080)

### Missing critical art

**Sliding block sprite is required by GDD and is not present** in this project’s `asset/` tree. Phase 11 must restore/import `mg1_block (1).png` (or equivalent) before claiming visual MG1 complete.

---

## 12. Asset-to-Gameplay Mapping

| Gameplay element | Asset / implementation | Notes |
|------------------|------------------------|-------|
| Playfield | `mg1_ramp_bg.png` | Scene-authored Sprite2D; preserve 1376×768 aspect |
| Sliding block | **MISSING** `mg1_block (1).png` | Must add; animate along ramp (runtime motion OK) |
| Mass / μ / distance | Godot UI Labels | No art file required |
| YES / NO | Godot Buttons | §7 |
| Force choices | Godot Buttons (3) | 50 / 150 / 250 default |
| Countdown bar | Godot ProgressBar | Optional shared widget later |
| Speed indicator | **MISSING** art; optional Label/needle | §7 optional |
| μ reference popup | Godot UI Panel | Spec |
| PROBLEM SOLVED / GAME OVER | Godot UI (art optional) | §7 |
| Screech/dust/crash VFX | **MISSING** | Optional polish |
| Momentum Crest | `badge_momentum_crest (1).png` | **Wire on MG5 win**, not MG1 |
| SFX skid/thud/crash | **MISSING / unverified in this audit** | Spec lists need |

---

## 13. Proposed Scene Architecture

Dedicated scene (replace ColorRect stub):

```
MiniGame01_Brake                          # Node2D + MiniGame01Brake.gd
├── Background
│   └── RampArt                           # Sprite2D → mg1_ramp_bg.png (scene scale/pos)
├── World
│   ├── RampPath                          # Path2D or Marker2D Start/End (scene-authored)
│   ├── Block                             # Sprite2D (+ optional AnimatableBody) — MISSING tex
│   └── CrashZone                         # Marker2D / Area2D at downhill end (authored)
├── Camera2D                              # Fixed; zoom to fit 1376×768 (scene-authored)
├── UI                                    # CanvasLayer
│   ├── DataPanel                         # mass, μ, surface, distance
│   ├── CountdownBar
│   ├── QuestionPrompt
│   ├── YesNoRow                          # YES / NO
│   ├── ForceRow                          # 3 force buttons (hidden until step 2)
│   ├── ReferenceCard                     # μ / formula toggle
│   ├── OutcomeBanner                     # PROBLEM SOLVED / GAME OVER
│   └── ContinueButton                    # after success → MG2 (or stub until MG2 exists)
└── Audio                                 # optional players
```

**Player CharacterBody2D:** Not required for classic MG1 UI (player is operator). If present for consistency, use `set_scripted_control(true)` / hide — **UNSPECIFIED**. Prefer **no roaming player** in MG1 unless design insists.

**Do not** embed MG1 inside `Zone01_Floor4.tscn` as the playfield — GDD uses a dedicated mini-game scene.

---

## 14. Scene-Authored vs Runtime State

### SCENE-AUTHORED (manual editor authoritative — never reset on `_ready`)

- RampArt position, scale, z-index  
- Camera position / zoom / limits  
- Block **initial** position / scale / rotation  
- Path points / CrashZone transforms  
- UI Control anchors/offsets (layout)  
- Button labels may be data-driven but positions authored  

### RUNTIME (gameplay state — allowed to change)

- Block velocity / path follow progress / animated offset  
- Countdown remaining  
- Current step (YES/NO vs force select)  
- Selected answers  
- Pass/fail outcome  
- Feedback visibility  
- Transition to MG2 or reload MG1  

### Rule

Initial layout = scene. Physics/gameplay motion = runtime. No procedural regeneration of the playfield from pixels.

---

## 15. MG1 Entry Flow

### Verified GDD flow

```
Floor 4 Director
  → Quiz (≥80%)
  → post_pass_lines (emergency phone)
  → Continue
  → MiniGame01_Brake
```

### Between quiz success and MG1 load

1. Mark director quiz passed (`zone01_director_passed` or rebuild equivalent).  
2. Play emergency dialogue lines (not invent new story beyond documented beat).  
3. On Continue → `SceneTransition.change_to(MiniGame01_Brake.tscn)`.  

Floor 4 `MiniGameHandoff` Area2D is **not** required by GDD if Continue loads MG1; see §17.

### Branch table

| Situation | Documented behavior |
|-----------|---------------------|
| Quiz **&lt; 80%** | Fail / retake; **no** emergency; **no** MG1 (floor quiz pattern) |
| Player leaves Floor 4 before pass | **UNSPECIFIED** — likely no MG access |
| Player retries quiz | Standard retake until ≥80% (**assumed** from other floors; confirm when quiz ships) |
| MG1 fails | GAME OVER → **reload MG1** |
| MG1 succeeds | Advance to **MG2** (MG2 may still be stub in early Phase 11) |

---

## 16. Floor 1 Placeholder Treatment

**Node:** `Zone01_Floor1` → `Interactions/MG1_Handoff` → `MiniGame01_Brake_Stub.tscn`

| Option | Recommendation |
|--------|----------------|
| Remove | OK after Phase 11 entry is live |
| **Disable** | **Preferred near-term** — set `enabled=false` or disconnect transition; keep node for one release if needed |
| Convert to non-MG flavor text | Optional (“machinery inspection”) — **not required by GDD** |

**GDD-based recommendation:** **Disable, then remove.** It is obsolete for the real game and conflicts with the single Floor 4 entry.  
**Phase 10:** do **not** modify yet (per audit policy). Phase 11 checklist includes this fix.

---

## 17. Floor 4 Handoff Treatment

**Node:** `Interactions/MiniGameHandoff` `(1100, 520)` → stub

| Option | Fit to GDD |
|--------|------------|
| Actual MG1 entry interaction (E to start) | Weak — GDD uses **post-quiz Continue**, not a side alcove interact |
| Narrative / debug trigger only | Acceptable temporary |
| **Disable Area2D; Floor4 script loads MG1 after emergency Continue** | **Best match to GDD** |

**Recommendation:** Treat MiniGameHandoff as **temporary scaffolding**. Phase 11 should drive MG1 from **Director quiz success → emergency → Continue**. Keep or remove the Area2D only as a **debug skip** behind a flag if needed — do not make it the sole production entry.

---

## 18. Reusable Architecture for Future Mini-Games

### Reusable (share lightly — no giant framework required)

| Piece | Why |
|-------|-----|
| `SceneTransition` | Load MG scenes / reload on fail |
| `GameState` flags | director_passed; later MG index / crest / zone unlock |
| `DialoguePanel` | Emergency lines on Floor 4 |
| Shared outcome UI pattern | PROBLEM SOLVED / GAME OVER + alarm sting (MG1–5) |
| Optional thin `MiniGameBase` API | `start()`, `_pass()`, `_fail()` as in minigame spec — **only if** it stays small |
| Reference-card UI pattern | Formula popups across MGs |
| Countdown bar Control | MG1 + MG3 |

### MG1-specific

| Piece | Why |
|-------|-----|
| Ramp background + block actor | Unique art/logic |
| YES/NO → force select state machine | Unique interaction |
| Friction scenario constants | Unique data |
| `MiniGame01Brake.gd` | Dedicated controller |

### Wait until MG2–MG5

| Piece | Why |
|-------|-----|
| Full `MiniGameSequence.tscn` container | Useful but optional; scene-chain also documented |
| JSON multi-variant scenario pools | Only after Argon verifies variants |
| Badge ceremony UI | After MG5 |
| Drag-and-drop gear/pulley systems | MG2/MG5 specific |
| Shared physics engine abstraction | Not required if each MG stays UI/kinematic |

**Do not** build a universal physics sandbox in Phase 11.

---

## 19. Unspecified / Missing Information

1. Exact \(g\), \(v_0\), ramp angle, pixel scale  
2. Live physics vs animated UI resolution presentation  
3. Full text of Director `post_pass_lines` for this rebuild (old project had them; not ported)  
4. Floor 1–3 quiz content / gating for this rebuild (deferred; affects “full GDD parity” but MG1 can still be prototyped after a **temporary** Floor 4 debug Continue if product allows)  
5. Mid-run quit / pause behavior  
6. Whether MG2 stub or real loads after first MG1 success in Phase 11  
7. **Missing `mg1_block` art**  
8. VFX/SFX packs  
9. Speed-indicator art  
10. Quiz question bank for Floor 4 Director in this repo  

---

## 20. Implementation Risks

| Risk | Impact |
|------|--------|
| Dual stub entries (F1 + F4) | Players skip Director path |
| Missing block sprite | Cannot ship visual MG1 |
| Baked props on ramp BG duplicated as sprites | Visual clutter / false collision |
| Over-building RigidBody sim without numbers for \(v_0\) | Invented physics |
| Awarding Momentum Crest on MG1 clear | Breaks GDD (crest on MG5) |
| Implementing Floor quizzes + all MG1–5 in one phase | Scope blowout |
| Treating stub visit as `director_passed` | Soft-locks progression logic |
| Stretching 1376×768 ramp to floor camera zoom blindly | Aspect distortion |

---

## 21. MG1 Implementation Checklist

Concrete Phase 11 inputs (still **do not implement in Phase 10**):

### A. Preconditions / entry hygiene

- [ ] Disable Floor 1 `MG1_Handoff` transition (then remove when stable)  
- [ ] Decide production entry: **emergency Continue → MG1** (recommended) vs debug handoff  
- [ ] Add `GameState` fields as needed: e.g. `zone01_director_passed`, optional `zone01_mg_index`  
- [ ] Do **not** set completion flags when entering the current ColorRect stub  

### B. Assets

- [ ] Locate or restore **`mg1_block (1).png`** (or approved replacement); import; document path  
- [ ] Confirm `mg1_ramp_bg.png` 1376×768 wired without destructive stretch  
- [ ] Do not duplicate baked crates/barrels as extra sprites  
- [ ] Leave `badge_momentum_crest` unwired until MG5  

### C. Scene

- [ ] Create `scenes/zone01/minigames/MiniGame01_Brake.tscn` (or agreed path)  
- [ ] Replace stub target paths to real scene when ready  
- [ ] Scene-author camera + RampArt + block spawn + UI layout  
- [ ] Script must **not** reset authored transforms on load  

### D. Controller

- [ ] `MiniGame01Brake.gd` with steps: show data → YES/NO → force select → resolve  
- [ ] Default constants: \(m=40\), \(\mu=0.35\), \(d=7\), correct NO, force **150**, distractors **50/250**, countdown **12** (or document change)  
- [ ] Success → transition toward MG2 (stub OK initially)  
- [ ] Fail → GAME OVER presentation → reload MG1  
- [ ] Use `SceneTransition`; optional `set_scripted_control` if any player node exists  

### E. Floor 4 narrative (minimum for canonical entry)

- [ ] Director quiz ≥80% **or** explicitly documented interim debug gate  
- [ ] `post_pass_lines` emergency dialogue  
- [ ] Continue loads MG1  
- [ ] Disable production reliance on alcove `MiniGameHandoff`  

### F. Verification (Phase 11+)

- [ ] Headless: scene loads; art present; no Floor1→MG1 in production config  
- [ ] Structural: YES→fail, NO→forces, 150→pass, wrong→fail  
- [ ] Regression: School → … → Floor 4 still works  
- [ ] Visual: ramp + block placement eye-check  

### G. Explicitly out of Phase 11 unless scoped

- [ ] Real MG2–MG5  
- [ ] Momentum Crest ceremony  
- [ ] Full Floor 1–3 quiz banks (unless required for entry gate)  
- [ ] JSON multi-scenario random pools  

---

## Phase 10 status

**MG1 specification and asset audit completed.**  
**MG1 is not implemented.**  
Phase 11 readiness: **READY WITH BLOCKERS** — missing block art + entry hygiene (disable Floor1 handoff + Director/emergency gate design) must be addressed as Phase 11 starts.
