# MINIGAME IMPLEMENTATION — Physics Quest

**Living status:** See also `Docs/PROGRESS.md` and `Docs/SCENE_IMPLEMENTATION.md`.  
**Last updated:** 2026-09-24 (Zone 02 → PLAY/SUCCESSFUL placeholder; Harbor Works unused legacy)

This document tracks mini-game implementation for the **current rebuild** (`d:\capstone 2`).

**Rules that still apply:**
- Do **not** start mini-games from ambient character proximity (`AmbientProximity`).
- Floor **Supervisors** remain assessment-only; exterior guides remain guide-only.
- Unlock gate: `floor4_passed AND minigame_successful` via `GameState.mark_minigame_successful` → `sync_world_map_unlocks()`.
- Ambient system guide: `Docs/AMBIENT_CHARACTERS.md`.
- **Do not** instance `GameplayStatusBar` inside mini-game scenes.

---

## Status by zone

| Zone | Mini-game | Status | Scene | Controller | Badge (canonical) |
|------|-----------|--------|-------|------------|-------------------|
| 01 | Emergency Brake (friction) | **REAL** | `scenes/minigames/zone01/MiniGame01_Brake.tscn` | `scripts/minigames/zone01/MiniGame01Brake.gd` | Momentum Crest |
| 02 | Harbor Works (machine grid) | **UNUSED LEGACY** (Floor4 uses PLAY→SUCCESSFUL placeholder) | `scenes/minigames/zone02/MiniGame02_HarborWorks.tscn` (not launched) | — | Radiant Crest (set by Floor4 placeholder) |
| 03 | Fiber Escape (beam routing) | **REAL** | `scenes/minigames/zone03/MiniGame03_FiberEscape.tscn` | `scripts/minigames/zone03/MiniGame03FiberEscape.gd` | Spectrum Crest |
| 04 | (deferred Build the Generator) | **PLACEHOLDER** PLAY → SUCCESSFUL | Floor4 demo UI only | — | Spark Emblem |
| 05 | — | **DEFERRED** | Exterior stub only | — | Atomic Amber |

**No `MiniGameBase`** in the current rebuild. Each real MG is a self-contained `Control` scene.

### Badge flag wiring (honest)

| Zone | Sets `zoneN_badge_earned` on MG success? |
|------|------------------------------------------|
| 01 | **No** (map unlock only today) |
| 02 | **Yes** (Floor4 placeholder sets `zone02_badge_earned`) |
| 03 | **No** (map unlock only today) |
| 04 | **No** (placeholder must not award Spark Emblem in Badge Screen) |
| 05 | Flag does not exist yet |

Badge collection UI: `Docs/SCENE_IMPLEMENTATION.md` (Status Bar + Badge Screen).

---

## Zone 01 — Emergency Brake (IMPLEMENTED)

**Gate:** Zone01 Floor4 quiz pass → Mini-Game Area → PLAY → `MiniGame01_Brake.tscn`.

**Assets:** `asset/minigame asset/zone 1 mini game/mini game 1 asset/`  
**Data:** `data/zone01_minigames.json`  
**Success:** `GameState.mark_minigame_successful(ZONE_01)` → World Map → Zone 02 unlock  
**Fail:** FACTORY DAMAGED overlay → retry new scenario  

**Verifier:** `scripts/tools/verify_mg01_brake.gd` → `VERIFY_MG1 fail=0`

**Note:** Older GDD five-MG sequence (Brake → Gear → Balance → Pressure → Pulley → Momentum Crest) remains reference-only. This rebuild uses **one** Floor4 mini-game gate (Emergency Brake). Badge art `badge_momentum_crest (1).png` exists; set `zone01_badge_earned` when wiring Badge Screen unlock for Momentum Crest.

Source material (historical / polish target):
- `Docs/zone01_minigame_implementation_spec.md`
- `Docs/PHYSICS_QUEST_MASTER.md` (§5.3, §7, §33)

---

## Zone 02 — Mini-game 02 PLACEHOLDER (active) / Harbor Works UNUSED

**Active gate:** Zone02 Floor4 DemoCompleteUI → PLAY MINI-GAME 02 → SUCCESSFUL (no scene change).

**Success:** `zone02_badge_earned = true` + `mark_minigame_successful(ZONE_02)` → unlocks Zone 03 → RETURN TO WORLD MAP.

**Harbor Works (unused legacy):** `MiniGame02_HarborWorks.tscn` / `.gd` / `zone02_harbor_briefs.json` / `mini_games_2_asset/` remain on disk but are **not launched**.

---

## Zone 03 — Fiber Escape (IMPLEMENTED)

**Gate:** Zone03 Floor4 quiz pass → Mini-Game Area → PLAY MINI-GAME 03 → `MiniGame03_FiberEscape.tscn`.

**Design ref:** `asset/minigame asset/zone 3 mini game/fiber_escape_implementation_plan.md` (HTML sprite plan; adapted to Godot — no HTML/JS shipped).  
**Assets:** `asset/minigame asset/zone 3 mini game/mini game 3 asset/` (**JPG**, exact casing: `Sensor_ring.jpg`, `Icon_clear.jpg`, …).

| Stage | Name | Critical angle θc |
|-------|------|-------------------|
| 1 | SERVER ROOM | 55° |
| 2 | TRANSOCEANIC CABLE | 68° |

Lab Bench is **not** a stage.

**Success:** Stage 2 clear only → `GameState.mark_minigame_successful(ZONE_03)` → World Map → Zone 04 unlock  
**Failure:** leak / obstacle feedback + RETRY; Zone 04 stays locked  
**Hints:** 1 text · 2 hazard clearance (`hazard_stripe_tile.jpg`) · 3 ghost waypoints (`waypoint.jpg` low alpha)

**Verifier:** `scripts/tools/verify_mg03_fiber_escape.gd` → `VERIFY_MG3 fail=0`

Canonical badge: **Spectrum Crest** (`spectrum _badge.png` — space before `_`).  
Does **not** currently set `zone03_badge_earned`.

---

## Zone 04 — deferred

Floor4 still uses temporary **PLAY → SUCCESSFUL**.  
Sets `zone04_minigame_successful` (map unlock) but **must not** be treated as Spark Emblem earned — Badge Screen reads `zone04_badge_earned` only (unset).  
Canonical badge: **Spark Emblem** (`ui_badge_spark_emblem.png`).

---

## Zone 05 — deferred

Canonical badge: **Atomic Amber** (`asset/sprites/Environment/Zone_5_badge.png`).  
No `zone05_badge_earned` in GameState yet. Badge Screen always shows Atomic Amber locked.

---

## Obsolete five-MG Zone 01 sequence (reference only — not current gate)

```
Director Quiz Pass (Floor 4 path)
      ↓
[Cutscene: Factory Emergency]
      ↓
MG1 Emergency Brake (Friction)
      ↓
MG2 Gear Swap (Gear Ratios)
      ↓
MG3 Counterweight Balance (Moments)
      ↓
MG4 Pressure Panic (Pascal's Law)
      ↓
MG5 Pulley Rush (Mechanical Advantage)
      ↓
[Momentum Crest]
      ↓
World Map / Zone 02 unlock
```

Do **not** rebuild `MiniGameBase` / MG2–MG5 chain unless a future task explicitly restores that architecture.
