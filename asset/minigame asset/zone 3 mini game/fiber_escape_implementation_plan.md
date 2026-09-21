# Fiber Escape — Sprite Integration Implementation Plan (v2, 2 stages / 16 assets)

Goal: replace every procedurally-drawn canvas element in `fiber_escape.html` with the **16** PNG sprites from `fiber_escape_asset_manifest_v2.md`, without touching any game logic (bend math, obstacle collision, stage data, firing animation). Scope is **Server Room (55°)** and **Transoceanic Cable (68°)** only — Lab Bench is dropped entirely, and this plan assumes it's already gone from `STAGES`.

The defining constraint of v2 is the **reuse rule**: one texture per *type* of thing, not per stage/state/instance. Every step below draws from a single file and differentiates stage/state/animation purely through runtime parameters (`ctx.filter` hue-rotate, alpha, scale) — never a second file.

---

## 0. Prerequisites

- All 16 PNGs delivered, named exactly per the manifest (`emitter.png`, `sensor_ring.png`, `waypoint.png`, `beam_glow_01.png`, `beam_glow_02.png`, `beam_segment_tile.png`, `particle.png`, `obstacle_block.png`, `hazard_stripe_tile.png`, `icon_tab.png`, `icon_fire.png`, `icon_undo.png`, `icon_clear.png`, `icon_hint.png`, `icon_status.png`, `favicon.png`).
- PNGs placed in a flat `/assets/` folder next to `fiber_escape.html` during development.
- Final shipped artifact stays a single self-contained HTML file, so every PNG is ultimately **base64-inlined**. Development can use real file paths; a build step converts them.
- No background art, no cursor art, no header-logo art — those are cut per the manifest and stay code-only (`drawStageWash()` + CSS radial gradient, browser default crosshair, text-only title).

---

## 1. Asset pipeline (once)

1. Create `/assets/`, drop in the 16 PNGs at their listed sizes.
2. `build_assets.py` (local, not shipped): reads every PNG, base64-encodes it, writes `assets.generated.js`:
   ```js
   const ASSET_DATA = {
     "emitter": "data:image/png;base64,...",
     "sensor_ring": "data:image/png;base64,...",
     "waypoint": "data:image/png;base64,...",
     "beam_glow_01": "data:image/png;base64,...",
     "beam_glow_02": "data:image/png;base64,...",
     "beam_segment_tile": "data:image/png;base64,...",
     "particle": "data:image/png;base64,...",
     "obstacle_block": "data:image/png;base64,...",
     "hazard_stripe_tile": "data:image/png;base64,...",
     "icon_tab": "data:image/png;base64,...",
     "icon_fire": "data:image/png;base64,...",
     "icon_undo": "data:image/png;base64,...",
     "icon_clear": "data:image/png;base64,...",
     "icon_hint": "data:image/png;base64,...",
     "icon_status": "data:image/png;base64,...",
     "favicon": "data:image/png;base64,..."
   };
   ```
3. Re-run any time an artist updates a file. Never hand-edit the generated file. 16 keys total — this file should stay small.

---

## 2. Preloader

1. Build one `Image` object per key in `ASSET_DATA` (16 total, not 40 — this loop is now trivially cheap).
2. `Promise.all` so the game waits for all 16 before the first `draw()`.
3. Reuse the existing `.status-banner` styling for a "Loading assets…" state while waiting.
4. Per-image `onerror` falls back to the current procedural shape for *that key only*; log the failed key to console. Never block the whole game on one bad file.

```js
const SPRITES = {};
function loadSprites(){
  const promises = Object.entries(ASSET_DATA).map(([key, src]) => new Promise((resolve) => {
    const img = new Image();
    img.onload = () => { SPRITES[key] = img; resolve(); };
    img.onerror = () => { SPRITES[key] = null; resolve(); };
    img.src = src;
  }));
  return Promise.all(promises);
}
loadSprites().then(() => {
  renderStageTabs();
  resetPath();
  requestAnimationFrame(idleLoop);
});
```

---

## 3. Draw helper with tint + fallback

Because every canvas sprite in v2 is state-differentiated by `ctx.filter` rather than by file, the helper needs a `tint`/`hueRotate` option baked in from the start — this is the one piece of new plumbing v2 needs beyond v1's `drawSprite()`.

```js
function drawSprite(key, x, y, w, h, opts = {}){
  const img = SPRITES[key];
  ctx.save();
  if(opts.alpha !== undefined) ctx.globalAlpha = opts.alpha;
  if(opts.filter) ctx.filter = opts.filter; // e.g. 'hue-rotate(110deg) saturate(1.4)'
  if(opts.rotate){ ctx.translate(x + w/2, y + h/2); ctx.rotate(opts.rotate); ctx.translate(-w/2, -h/2); x = 0; y = 0; }
  if(img){
    ctx.drawImage(img, x, y, w, h);
  } else if(opts.fallback){
    opts.fallback(ctx, x, y, w, h);
  }
  ctx.restore();
}
```

`obstacle_block.png` already has `stage().tint` wired via `ctx.filter` in `drawObstacle()` — this helper generalizes that exact pattern to every other sprite instead of introducing a second mechanism.

Keep the old procedural drawing code for each element as a closure passed via `opts.fallback` — art can ship sprite-by-sprite without ever producing a broken frame.

---

## 4. Core object rendering — state via filter/alpha/scale only

| Sprite | Draws / reused for | State handling (no new files) |
|---|---|---|
| `emitter.png` (32×32) | Source marker | Idle vs. active = `opts.alpha` + an additive glow drawn *behind* it in code (existing glow logic), not a second sprite. |
| `sensor_ring.png` (48×48) | Target, all states | `sensor_idle`: no filter. `armed` (`!computeBlocked() && !fired`): `filter: 'brightness(1.2)'`. `success`: green `hue-rotate` + slight scale-up via `w,h` bump, driven by the same `fireDone && fireFailAt === -1` check already in the code. |
| `waypoint.png` (24×24) | Every bend marker, both stages | `pass`: green `hue-rotate`. `fail`: amber `hue-rotate`. `dragging` (`i === dragging`): scale to 28×28, no rotate needed since amber/green covers pass/fail already. Same file also serves the Hint-3 ghost marker (Section 8) and the cut-list's "ghost-hint" — low alpha + violet `hue-rotate`, still the same file. |
| `beam_glow_01.png` / `beam_glow_02.png` (16×16 each) | Traveling beam head (2-frame flicker) **and** sensor success pulse | Beam head: alternate frame by `Math.floor(performance.now()/120) % 2`, no tint. Sensor success pulse: same 2-frame alternation, green `hue-rotate`, drawn at ~1.5x scale over `sensor_ring`. |
| `beam_segment_tile.png` (8×64) | Beam stroke, both stages | Replace `drawFiredBeam`'s stroked line: for each path segment, compute angle via `Math.atan2(dy,dx)`, tile the 8×64 texture along the segment length using `opts.rotate`. No per-stage variant — stage feel comes from `drawStageWash()`, not the beam. |
| `particle.png` (8×8) | Leak burst **and** success spark | Leak: amber `hue-rotate`, `opts.alpha = pt.life` (unchanged simulation, only the draw call changes). Success spark (if/when added): green `hue-rotate`, same file, same draw path. |

---

## 5. Obstacle rendering

1. `obstacle_block.png` already has stage-tinting wired via `stage().tint` in `drawObstacle()` per the manifest note — **no code change needed here**, just confirm the existing routine now reads sprite pixels instead of a flat fill:
   ```js
   function drawObstacle(r){
     drawSprite('obstacle_block', r.x, r.y, r.w, r.h, {
       filter: `hue-rotate(${stage().tint}deg)`,
       fallback: oldFillRectCode
     });
   }
   ```
2. Collision math is untouched: collision still reads `r.x, r.y, r.w, r.h` off the obstacle object. Sprite is scaled to fit the rect (per manifest: "120×300, scales to fit each rect") — **never let the drawn size drift from the hitbox**, since that's the one way a sprite swap could visibly desync from gameplay.
3. All 5 obstacle instances across both stages use this one file + one filter line — no per-instance or per-stage sprite fields needed in `STAGES`.
4. Hazard stripes (`hazard_stripe_tile.png`, 32×32): `createPattern(SPRITES['hazard_stripe_tile'], 'repeat')` over the obstacle's existing clip region, amber (default) in both stages. The **same pattern, violet-tinted**, doubles as the Hint-2 clearance-zone overlay (Section 8) — one `createPattern` call, two `ctx.filter` values, no second tile asset.

---

## 6. Backgrounds — cut, no code change

Per the manifest this is explicitly **not** an asset task: `drawStageWash()` (already live) plus the CSS radial gradient carries both stages' visual identity. Nothing in this plan adds a `bg_*` key, an `Image` load, or a `draw()` step for backgrounds. If a future manifest revision adds background art, it slots in as a new step here — do not pre-build hooks for it now.

---

## 7. UI icons

Regular `<img>` / CSS `background-image`, not canvas sprites — simplest section.

| Sprite | Target | Notes |
|---|---|---|
| `icon_tab.png` (20×20) | Both stage tabs | Tinted per stage the same way `obstacle_block` is — reuse the `stage().tint` value via a CSS `filter: hue-rotate(...)` on the `<img>` (or an inline SVG-filter wrapper if CSS `filter` on `<img>` proves inconsistent across the two tab elements). |
| `icon_fire.png` | Fire button | Single state, no tint. |
| `icon_undo.png` | Undo button | Single state, no tint. |
| `icon_clear.png` | Clear button | Single state, no tint. |
| `icon_hint.png` | All 3 hint-tier buttons | Same icon for all three tiers — no per-tier art, per manifest. Tier is communicated by existing button label/position, not icon. |
| `icon_status.png` | Status banner | Amber `hue-rotate` for blocked/fail, green `hue-rotate` for success — replaces what would otherwise be two icon files, matched to the `blocked`/`fail`/`success` class already set by `renderStatus()`. |

All six go through the Section 1 base64 pipeline and are set via `img.src = ASSET_DATA['icon_fire']` (or the CSS custom-property pattern if preferred) rather than a raw file path, to stay consistent with the self-contained shipped build.

**Favicon:** `favicon.png` becomes an actual `<link rel="icon">` in `<head>` via its base64 data URI, for anyone who saves/opens the HTML file directly outside the Artifact viewer. The `Artifact` publish tool's `favicon` parameter only accepts a single emoji — keep the emoji favicon for the *published card* as-is; the two are independent and both fine to keep.

---

## 8. Hint overlays — both reuse existing files, zero new assets

| Item | Change |
|---|---|
| Hint-3 ghost waypoints | `drawSprite('waypoint', x, y, 24, 24, { alpha: 0.35, filter: 'hue-rotate(260deg)' })` in the existing `hintLevel >= 3` block — replaces the `ctx.arc` fill, no new file per the manifest's cut-list ("Ghost-hint waypoint marker — reuses `waypoint.png` at low alpha + violet tint"). |
| Hint-2 clearance zone | Reuses the **same** `hazard_stripe_tile` pattern from Section 5, violet-tinted instead of amber, filled along the existing rounded-rect clearance region. If the tile doesn't read well at clearance-zone scale once art is in, fall back to the current dashed stroke — judgment call post-integration, not a blocker. |

No cursor asset, no drag-handle sprite — both are explicitly cut in the manifest (kept as browser-default crosshair).

---

## 9. Rollout order

1. **Preloader + `drawSprite()` w/ filter support + fallback wiring** (Sections 2–3) — plumbing only, no visual change.
2. **Obstacles + hazard stripe pattern** (Section 5) — biggest visual win for lowest risk; hitboxes untouched, and this file is already partially wired via `stage().tint`.
3. **Core objects: emitter, sensor, waypoints, beam, particles** (Section 4) — highest complexity (frame cycling, rotation, multi-purpose files), do after obstacles.
4. **UI icons + favicon** (Section 7) — independent of canvas work, can happen in parallel with step 3.
5. **Hint overlays** (Section 8) — last, since both items reuse files that only exist once steps 4–5 are wired.

(No background step — cut per Section 6.)

---

## 10. Testing checklist

- [ ] Game loads and is playable with **zero** PNGs supplied (full fallback path).
- [ ] Game loads and is playable with **some** PNGs missing/corrupt (partial fallback, no crash, console warning per key).
- [ ] `obstacle_block` never visually overhangs its hitbox rect — check all 5 instances across both stages against a temporary debug outline.
- [ ] Every reused file renders correctly in **all** of its listed reuse contexts in one pass: e.g. `waypoint.png` checked as pass / fail / dragging / Hint-3 ghost in the same test session, not just once.
- [ ] `ctx.filter` hue-rotate values are visually distinct enough between stage tints, pass/fail, and hint-violet — no two states read as the same color at a glance.
- [ ] Animated sprites (`beam_glow_01/02`, `sensor_ring` success pulse) cycle at a readable frame rate.
- [ ] Sprites stay crisp at 2x+ scale on high-DPI displays (canvas is fixed 800×480 logical, scaled by CSS).
- [ ] Final base64-inlined build (16 files, smaller than the old 40-file plan) stays comfortably under the 16 MB artifact limit.
- [ ] Republish via the `Artifact` tool and re-test the **published** version specifically — confirm data-URI sprites and `ctx.filter` tints render identically inside the hosted artifact viewer, not just locally.

---

## 11. What does *not* change

- `turnAndIncidence()`, `segIntersectsRect()`, `computeBends()`, `computeBlocked()` — untouched.
- `STAGES` obstacle coordinates, `criticalAngle` values (55° / 68°), ghost-path data — untouched; no per-instance or per-stage sprite fields are added anywhere, since v2's reuse rule means every sprite reference is a **file key + runtime filter**, not a data-driven asset path.
- Firing animation timing/speed, leak particle physics (`x/y/vx/vy/life`) — untouched; only the draw call for each particle changes.
- All logic in `step()`, `fireBtn` click handler, pointer event handlers — untouched.
- Lab Bench stays removed; no code path in this plan reintroduces a third stage.
