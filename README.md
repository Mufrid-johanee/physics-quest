# Physics Quest

2.5D educational RPG built with **Godot 4.7.1** and **GDScript** (Bangladesh Class 9–10 Physics flavor).

**Local / repo root:** open `project.godot` in Godot 4.7+.  
**Living docs:** `Docs/PROGRESS.md` · `Docs/MASTER_GAME_SPEC.md` · `Docs/SCENE_IMPLEMENTATION.md` · `Docs/MINIGAME_IMPLEMENTATION.md`

## Features (this rebuild)

- Main Menu New / Load / Quit + profile saves under `user://profiles/` (manual **S** after checkpoint; no autosave)
- World Map click landmarks → Zones 01–04
- Zone 01–04: Exterior + Floors 1–4, quizzes (≥80%), ambient characters, Floor4 mini-game gate
- **Real mini-games:** Emergency Brake (Z01) · Harbor Works (Z02) · Fiber Escape (Z03)
- Zone 04 mini-game still a temporary SUCCESSFUL placeholder
- Shared **Gameplay Status Bar** (**BADGES**) → **Badge Screen** collection UI
- Canonical badges: Momentum Crest · Radiant Crest · Spectrum Crest · Spark Emblem · Atomic Amber

## Run

1. Open this folder in Godot 4.7.1.
2. Main scene: `scenes/ui/MainMenu.tscn` (F5 / Play).

## Controls (typical)

| Input | Action |
|-------|--------|
| WASD / Arrows | Move |
| E / F | Interact (doors / some prompts) |
| S | Manual save (after checkpoint) |
| Mouse | World Map clicks, quizzes, mini-games, BADGES button |

## Project structure

```
asset/          # Sprites, mini-game art
data/           # Quiz banks, MG JSON
Docs/           # Living + historical documentation
scenes/         # UI, World Map, zones, mini-games
scripts/        # Autoloads, zones, quiz, UI, tools
shaders/        # e.g. chroma-key for JPG MG art
```

## License

Educational capstone project. Third-party asset packs retain their original licenses — see folders under `asset/`.
