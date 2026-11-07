# Codex agent instructions for AEGIS (y-com)

## Goal
Build a legally distinct, Android-first, offline strategy/tactics game with the mechanical depth of classic 1990s alien-invasion tactics games. Do not clone copyrighted assets or plot.

## Tech stack
- Godot 4.7.2 Standard, GDScript, 2D Control nodes.
- GL Compatibility renderer for broad Android support.
- Portrait is not a requirement: prioritize landscape touch.
- Default language Ukrainian; secondary language English.

## Working method
1. Read `README.md` and `SPEC.md` before changing code.
2. Inspect current behavior and implement small, independently testable features.
3. Keep domain/gameplay rules separate from visual UI nodes where practical.
4. Preserve existing save data; version and migrate save files when the schema changes.
5. Prefer data-driven content (Resources or JSON) over hard-coded special cases as the game grows.
6. Make every screen and action work offline; no backend, account or analytics.
7. Do not import original X-COM/UFO assets, names, text, music, scenarios or copyrighted maps.
8. Add automated headless tests for pure rules. Run Godot headless import and tests when available.
9. Verify touch behavior and responsiveness before calling a feature Android-ready.
10. Update documentation and acceptance checks with each finished milestone.

## Architecture
- `game_state.gd`: persistent strategic economy and research.
- `main.gd`: navigation/UI, should remain thin as features grow.
- `battle_view.gd`: encounter state, soldier actions and enemy-turn workflow.
- `battle_board.gd`: board drawing and input, not business logic.
- `tactics_rules.gd`: reusable pure calculations.
- `texts.gd`: localization dictionary (replace with translation resources later).

## Immediate next task
Validate the seed project on Godot 4.7.2 (including a device), fix any compile/input issues, add headless tests, then move on to route preview/highlighting, tactical persistence and character roster. Do not claim Android builds are verified unless an APK was exported and installed.
