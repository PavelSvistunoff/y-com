# AEGIS: Alien Earth Defense

A standalone, offline, turn-based tactics and strategy game for Android, inspired by the *mechanical depth* of 1990s alien-invasion strategy games. All art, setting and characters must be original. The GitHub repository is named **y-com**.

**Status:** early playable Godot prototype, not a production-ready Android release.

## Run locally

1. Install **Godot 4.7.2 Standard** (not the .NET editor).
2. Clone this repository, then use **Import** in Godot and select `project.godot`.
3. Press **F6** to preview the scene or **F5** to run the project.
4. On the globe choose **Deploy Squad**. Tap a teal soldier to select them; tap a reachable tile to move or a visible orange alien to fire. Use **End Turn** to let enemies act. **Retreat** ends the mission as a defeat.

No downloads, external assets, API keys, login, networking, analytics or third-party plugins are needed to run the desktop prototype.

Basic headless rule checks: `godot --headless --path . --script res://tests/tactics_test.gd` (requires an installed Godot executable).

## Implemented vertical slice

- Fictional geoscape overview with a mission marker, time advancement and weekly funding.
- Base screen: purchase additional facilities with credits.
- Research screen: start a project and progress it as days advance.
- Tactical 16x12 battlefield with original procedural graphics, tap/click controls, three soldiers vs. three aliens.
- Action points, BFS tile movement, walls, line of sight, fog of war, ranged combat, ammunition and reloads, simple enemy AI, wins/losses.
- Save/load strategic progress with `user://aegis_save.json`.
- Ukrainian and English UI toggle (battle locked to one language during a mission).

**Not yet implemented:** UFO interception, nuanced alien AI, destructible terrain, elevation, equipment loadouts, large-scale research tree, underwater layer, polished art/audio, Android export validation, testing on real devices.

## Android build

The project is designed around landscape touch controls, but an APK is **not** included.

1. In Godot choose **Editor → Manage Export Templates** and install templates matching your editor version.
2. Install/configure Android SDK and a suitable JDK, then set paths in **Editor Settings → Export → Android**.
3. Add an **Android** export preset under **Project → Export**, set a unique application ID and configure signing as needed.
4. Export an APK and test touch targets, scaling, performance, app resume and save persistence on a physical device.

Official guide: <https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html>

## Repository structure

```text
project.godot           Godot settings, autoloads and landscape display
scenes/main.tscn        Entry scene
scripts/main.gd         Navigation, geoscape/base/research UI
scripts/game_state.gd   Strategy state and save/load
scripts/globe_view.gd   Procedural geoscape graphic
scripts/battle_view.gd  Tactical turn controller and enemy AI
scripts/battle_board.gd Procedural board renderer and touch handling
scripts/tactics_rules.gd Pure rules (distance, visibility, accuracy)
scripts/texts.gd        UK/EN strings
tests/tactics_test.gd  Headless rules smoke tests
SPEC.md                 Product scope and staged roadmap
AGENTS.md               Instructions for Codex and contributors
```

## License and intellectual property

This project is a spiritual successor, not a remake or licensed X-COM game. Do not reuse X-COM/UFO game assets, text, maps, music, names or specific stories. No license is assigned to the code yet; contributors should not assume reuse rights without an explicit license.
