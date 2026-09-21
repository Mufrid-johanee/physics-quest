# Zone 01 Audit

**Date:** 2026-09-18  
**Phase:** 9 — Full Zone 01 implementation audit  
**Scope:** Physical foundation only (School → Map → Exterior → F1–F4).  
**Policy:** Read-only audit. No MG1–MG5 implementation. No layout redesign. No collision/NPC/camera retuning.

### Amendment 2026-09-20 — Ambient + Supervisor

Post-audit: Zone 01–04 floors gained ambient proximity dialogue + body collision; Zone 01 Manager display role → Supervisor; Teacher additive Supervisor line. Assessment / door flows unchanged.  
**Authoritative upgrade guide:** `Docs/AMBIENT_CHARACTERS.md` · **Verify:** `scripts/tools/verify_ambient_characters.gd`  
This audit’s “no NPC retuning” snapshot is historical; ambient collision shapes were added without moving character transforms.

### Amendment 2026-09-21 — Real Floor4 mini-game

Floor 4 Mini-Game Area now launches the **real Emergency Brake** scene (`scenes/minigames/zone01/MiniGame01_Brake.tscn`). Fake SUCCESSFUL mark removed. Canonical badge: **Momentum Crest**. See `Docs/MINIGAME_IMPLEMENTATION.md` and `Docs/PROGRESS.md`. Sections below that say “MG stub only” are **historical audit snapshot** (2026-09-18).

### Amendment 2026-09-21 — Badge UI

Zone floors instance shared `GameplayStatusBar` under `$UI`. Collection UI: `BadgeScreen`. Does not change assessment/door audit findings below.

**Sources compared:**
- `Docs/MASTER_GAME_SPEC.md`
- `Docs/SCENE_IMPLEMENTATION.md`
- `Docs/PROGRESS.md`
- `Docs/MINIGAME_IMPLEMENTATION.md`
- `Docs/PHYSICS_QUEST_MASTER.md` (GDD)
- `Docs/zone01_minigame_implementation_spec.md`
- Actual `scenes/zone01/*`, `scripts/zone01/*`, autoloads, player/NPC/components

---

## 1. Audit Scope

Audited:

| Area | Files |
|------|--------|
| Exterior | `Zone01_Exterior.tscn`, `Zone01Exterior.gd` |
| Floor 1–4 | matching `.tscn` / `.gd` |
| MG stub | `MiniGame01_Brake_Stub.tscn`, `MiniGame01Stub.gd` |
| Upstream | `SchoolOpening`, `WorldMap` |
| Systems | `Player*`, `NPC*`, `Interactable`, `SceneTrigger`, `GameState`, `SceneTransition` |
| Tests | All `scripts/tools/verify_*.gd` listed in §11 |

**Not audited visually in editor.** Collision walkability and NPC placement eye-checks = **NOT TESTED**.

---

## 2. Physical Progression

| Area | Expected | Actual | Status |
|------|----------|--------|--------|
| School → World Map | Yes | `SchoolOpening.gd` → `WorldMap.tscn` | **PASS** |
| World Map → Zone 01 Exterior | Yes | `WorldMap.gd` → `Zone01_Exterior.tscn` | **PASS** |
| Exterior → Floor 1 | After guard grant | Gate + `Floor1Entrance`; `zone01_guard_granted` | **PASS** |
| Floor 1 → Exterior | Yes | `ExteriorExit` | **PASS** (structural/script) |
| Floor 1 → Floor 2 | Yes | `Floor2Entrance` | **PASS** |
| Floor 2 → Floor 1 | Yes | `Floor1Entrance` | **PASS** |
| Floor 2 → Floor 3 | Yes | `Floor3Entrance` | **PASS** |
| Floor 3 → Floor 2 | Yes | `Floor2Entrance` | **PASS** |
| Floor 3 → Floor 4 | Yes | `Floor4Entrance` | **PASS** |
| Floor 4 → Floor 3 | Yes | `Floor3Entrance` | **PASS** |
| Exterior → World Map | Optional / not required for Phases 1–8 physical chain | **No** MapExit interact | **MISSING (non-blocking)** |
| Floor1 → MG stub | Phase 5 placeholder only | `MG1_Handoff` → stub | **PRESENT (non-GDD)** |
| Floor4 → MG stub | Future handoff placeholder | `MiniGameHandoff` → stub | **PRESENT (GDD-aligned location)** |

Complete forward chain School → … → Floor 4 is supported. Bidirectional floor links exist for F1↔F2↔F3↔F4 and F1↔Exterior.

---

## 3. NPC Cast Audit

| Scene | Expected NPCs | Actual NPCs | Status |
|-------|---------------|-------------|--------|
| Exterior | 1 Guard + 8 Workers (3 pairs + 2 solos) | Guard + Worker_01…08; pairs 01/02, 03/04, 07/08; solos 05, 06 | **PASS** |
| Floor 1 | 1 Manager + 3 Workers | Manager + Worker_01…03 | **PASS** |
| Floor 2 | **Exactly** 1 Manager + 1 Lab Assistant | Manager + LabAssistant (2 nodes) | **PASS** |
| Floor 3 | 1 Manager + 2 Workers | Manager + Worker_01, Worker_02 | **PASS** |
| Floor 4 | Director only | Director only | **PASS** |

**GDD vs rebuild notes:**
- Master GDD emphasizes Guard / Managers / Director for quizzes; ambient workers are rebuild decisions (D21, D28) and match `MASTER_GAME_SPEC` / Phase prompts.
- Floor 2 lock (Manager + Lab only) matches Phase 6 / D26 — **no undocumented extras**.
- Exterior workers: `can_interact=false`, `enable_collision=false` — ambient, non-blocking as intended.

---

## 4. Player / Manual Override Audit

### Pattern search (Zone 01 scripts)

| Location | Assignment | Classification |
|----------|------------|----------------|
| All Floor* + Exterior `_ready` | `player.global_position = player_spawn.global_position` | **GOOD** — spawn snap from scene marker |
| `Zone01Exterior.gd` ~L89 | Tween Guard → `GuardAsidePoint` after grant | **GOOD** — documented gameplay aside |
| `PlayerController` / `NPCController` | Conditional `sprite_scale` if still `Vector2.ONE` | **NEUTRAL** — does not overwrite authored scales |
| Zone 01 scripts | NPC/collision `position`/`scale` resets on load | **None found** |
| Zone 01 scripts | `StaticBody2D.new` / `CollisionShape2D.new` | **None found** |
| Zone 01 scripts | Random NPC placement | **None found** |

### Per-scene ownership

| Scene | PlayerSpawn | Scene-authored NPCs | Script resets layout? |
|-------|-------------|---------------------|------------------------|
| Exterior | `(180, 500)` | Guard + 8 workers + GuardAsidePoint | No (aside only after grant) |
| Floor 1 | `(648, 960)` | Manager + 3 workers | No |
| Floor 2 | `(648, 960)` | Manager + LabAssistant | No |
| Floor 3 | `(648, 960)` | Manager + 2 workers | No |
| Floor 4 | `(648, 960)` | Director | No |

**Verdict:** Manual override architecture **PASS**. Scene tree owns layout; runtime does not regenerate collision or reposition ambient NPCs on load.

---

## 5. Collision Audit

| Scene | Scene-authored? | Giant room fill? | Runtime generation? | Notes |
|-------|-----------------|------------------|---------------------|-------|
| Exterior | Yes — Boundaries + FactoryFootprint + CrateApprox + Gate barrier | No | No | Perimeter matches 1376×768 yard |
| Floor 1 | Yes — split bottom walls + machines/crates/stairs block | No | No | Bottom center gap for ExteriorExit |
| Floor 2 | Yes — walls + consoles/conveyor/press/barrels | No | No | Largest interior ~420×160 conveyor — not room-wide |
| Floor 3 | Yes — walls + consoles/servers/debris | No | No | — |
| Floor 4 | Yes — walls + bookshelf/desk/consoles/crates | No | No | Matches GDD prop list intent |

**Questionable for manual editor testing (NOT TESTED visually):**
- Floor 1 `StairsBlock (1180, 420)` vs `Floor2Entrance (1120, 560)` proximity
- Floor 2 `ConveyorBlock` / `PressBlock` walk corridors
- Floor 4 `DirectorDesk` vs Director standing position
- Exterior `FactoryFootprint` vs gate / Floor1Entrance approach

**Do not retune in Phase 9** — report only.

---

## 6. Camera Audit

| Scene | Camera2D | Position | Zoom | Limits | Script follow/reposition? |
|-------|----------|----------|------|--------|---------------------------|
| Exterior | Yes | `(688, 384)` | `0.93` | None (fixed full view) | No |
| Floor 1 | Yes | `(648, 540)` | `0.667` | None | No |
| Floor 2 | Yes | `(648, 540)` | `0.667` | None | No |
| Floor 3 | Yes | `(648, 540)` | `0.667` | None | No |
| Floor 4 | Yes | `(648, 540)` | `0.667` | None | No |

Consistent with World Map (0.93 / 1376×768) and floor art (0.667 / 1296×1080). **PASS** — fixed cameras, scene-authored, no continuous script reposition.

---

## 7. Interaction Audit

| Scene | Interactions | Notes |
|-------|--------------|-------|
| Exterior | Guard dialogue → grant; Floor1Entrance (enabled after grant) | Gate barrier toggled; workers non-interact |
| Floor 1 | Manager talk; ExteriorExit; Floor2Entrance; **MG1_Handoff** | Manager lines only — **no quiz gate** (deferred) |
| Floor 2 | Manager + LabAssistant talk; Floor1/Floor3 entrances | No quiz gate; prompt still says Floor 3 “stub” |
| Floor 3 | Manager talk; Floor2/Floor4 entrances | Prompt still says Floor 4 “stub” |
| Floor 4 | Director talk; Floor3Entrance; **MiniGameHandoff** | Director intro only — **no quiz / emergency** |

GDD full loop (80% quizzes blocking stairs, Director emergency) is **intentionally absent** from Phases 1–8 physical foundation.

---

## 8. Mini-Game Placeholder Audit

| Item | Type | Evidence |
|------|------|----------|
| `MiniGame01_Brake_Stub.tscn` | **PLACEHOLDER** | ColorRect + label; `MiniGame01Stub.gd` `_ready = pass`; no Player/physics/score |
| Floor 1 `MG1_Handoff` | **PLACEHOLDER** (wrong GDD location) | Transitions to stub only |
| Floor 4 `MiniGameHandoff` | **PLACEHOLDER** (GDD-aligned entry *site*) | Transitions to stub only |

**No real MG1–5 leaked:** no friction/force UI, no scoring, no quiz systems, no reward/crest award in Zone 01 scripts.

Stub scenes are **dead-ends** (no return interact) — acceptable for placeholder; must be replaced/wired in MG phase.

---

## 9. Actual MG1 Location From GDD

**Documented MG1 location (authoritative GDD):**

> Five mini-games trigger **after the player passes the Floor 4 Director's quiz**, then emergency phone / cutscene, then MG1 Emergency Brake.  
> Sources: `PHYSICS_QUEST_MASTER.md` §2.3 / §3.7 / §32; `zone01_minigame_implementation_spec.md` scope lines.

**Actual current placeholder location(s):**
1. Floor 4 `Interactions/MiniGameHandoff` `(1100, 520)` → stub — **GDD-aligned site**
2. Floor 1 `Interactions/MG1_Handoff` `(980, 820)` → stub — **Phase 5 leftover; not GDD**

**Recommended implementation entry point (docs only — do not implement yet):**

```
Floor 4 Director quiz ≥80%
  → emergency / post_pass dialogue
  → MG1 Emergency Brake (real scene)
```

Use Floor 4 handoff (or direct Floor4 Continue after emergency) as the sole player-facing entry.  
**Disable or remove Floor 1 `MG1_Handoff` before shipping real MG1** so there is one entry path.

---

## 10. Game State / Progression Audit

| Flag / API | Present | Used as intended? |
|------------|---------|-------------------|
| `zone01_guard_granted` | Yes | Persists across Exterior reloads; gate + Floor1Entrance | **PASS** |
| `zone01_entered` | Yes | Set true on Exterior→Floor1 | **PASS** (light) |
| Zone unlock map | Yes | Zone 01 unlocked; 02–05 locked | **PASS** for current scope |
| Floor quiz pass flags | **No** | Expected deferred | Deferred |
| `zone01_director_passed` | **No** | Expected deferred | Deferred |
| MG completion / crest | **No** | Expected deferred | Deferred |

`SceneTransition` only fades and changes scenes — does not clear Zone 01 flags.  
No temporary test unlock of all zones in production `GameState` (unlike older master mention of `TRIAL_UNLOCK_ALL`).

**Placeholder stub is not treated as completed gameplay** — no pass flags written on stub enter.

---

## 11. Automated Test Results

| Test | Result |
|------|--------|
| `verify_foundation.gd` | **PASS** |
| `verify_school_opening.gd` | **PASS** |
| `verify_school_sequence.gd` | **PASS** |
| `verify_world_map.gd` | **PASS** |
| `verify_world_map_flow.gd` | **PASS** |
| `verify_zone01_exterior.gd` | **PASS** |
| `verify_zone01_exterior_flow.gd` | **PASS** |
| `verify_zone01_floor1.gd` | **PASS** |
| `verify_zone01_floor1_flow.gd` | **PASS** |
| `verify_zone01_floor2.gd` | **PASS** |
| `verify_zone01_floor2_flow.gd` | **PASS** |
| `verify_zone01_floor3.gd` | **PASS** |
| `verify_zone01_floor3_flow.gd` | **PASS** |
| `verify_zone01_floor4.gd` | **PASS** |
| `verify_zone01_floor4_flow.gd` | **PASS** |
| Full School → … → Floor 4 as single chained script | **NOT TESTED** as one script (covered piecewise by flow verifies) |
| Visual / manual placement | **NOT TESTED** |

---

## 12. Documentation Drift

| Item | Severity | Detail |
|------|----------|--------|
| Floor 2 / Floor 3 UI prompts still say “stub / later phase” | Docs/UX | Floors are implemented; prompts outdated in `Zone01Floor2.gd` / `Zone01Floor3.gd` |
| Floor 3 flow verify print still says “Floor4 stub” | Docs/test label | Floor 4 is real; test label leftover |
| Floor 1 `MG1_Handoff` documented as placeholder but still live path | Medium | Easy to confuse with real MG entry |
| `MINIGAME_IMPLEMENTATION.md` correctly deferred | OK | Matches code |
| Scene prompts for Floor 4 as “later phase” on Floor 3 | Docs | Should say Floor 4 (office) once UX polish allowed |
| Older `PHYSICS_QUEST_MASTER` describes shipped quizzes/MG as Yes | Context | Describes prior/shipped build; this rebuild intentionally stops at physical foundation |
| `School.tscn` stub vs `SchoolOpening.tscn` | Docs | Main path is SchoolOpening; stub remains for BootTest |

No silent history rewrite performed in this audit.

---

## 13. Known Issues

### Critical

*None found that break School → Map → Exterior → F1 → F2 → F3 → F4 progression or the manual-override architecture.*

### Medium

1. **Dual MG stub entries** — Floor 1 `MG1_Handoff` and Floor 4 `MiniGameHandoff` both load the same stub. GDD allows only Floor 4 post-Director path for real MG1.
2. **MG stub dead-end** — no return to Floor 4/1; fine for placeholder, bad if playtesters enter it often.
3. **No Exterior → World Map exit** — not required for Phases 1–8 chain; players cannot leave the zone without reload/boot. Confirm design before polish.
4. **Stale “stub” prompts** on Floor 2→3 and Floor 3→4 interactions.
5. **GDD quizzes / stair gates absent** — expected for foundation; must be designed before claiming full Zone 01 gameplay parity with master GDD.

### Manual Visual Tuning

1. Exterior worker positions / facing (pairs verified structurally; eye-check spacing).
2. Guard / gate / Floor1Entrance approach vs FactoryFootprint.
3. All floor NPC placements relative to desks/machines.
4. Floor 1 StairsBlock vs Floor2Entrance.
5. Floor 4 Director vs desk / bookshelf collision.
6. MiniGameHandoff alcove position vs intended emergency staging art.

### Documentation Only

1. Flow verify strings still saying “stub” for completed floors.
2. Cross-reference clarity: rebuild PROGRESS vs older PHYSICS_QUEST_MASTER “IMPLEMENTED” MG claims.
3. Phase 9 should be recorded as audit-complete in PROGRESS / SCENE_IMPLEMENTATION.

---

## 14. Phase 10 Readiness

### Status: **READY WITH FIXES REQUIRED**

Physical Zone 01 foundation is complete and structurally verified. Real MG1 may proceed **after** resolving the entry-path conflict and confirming the Floor 4 emergency handoff design.

### Must fix / decide before implementing real MG1

1. **Single MG1 entry:** Disable/remove Floor 1 `MG1_Handoff` (or stop routing it to MG1) so only the Floor 4 Director → emergency → MG1 path remains.
2. **Confirm Floor 4 start beat:** Director quiz + emergency dialogue (or interim Continue) before loading real `MiniGame01_Brake` — do not treat the current stub interact as completed design.
3. **Replace stub scene** with real MG1; do not add scoring/physics to the ColorRect stub in place.
4. **GameState:** Add only the flags the MG phase needs (`director_passed`, MG progress, etc.) when implementing — not before.

### Optional (not blocking MG1 code start)

- Soften stale Floor 2/3 “stub” prompt strings.
- Add Exterior → World Map return if product requires mid-zone exit.
- Manual collision/NPC eye-tuning.

---

## 15. Audit Actions Taken

- Created this report: `Docs/ZONE01_AUDIT.md`
- Updated `Docs/PROGRESS.md` and `Docs/SCENE_IMPLEMENTATION.md` with Phase 9 notes
- **No scene/script behavioral changes**
- **No MG1–MG5 implementation**
