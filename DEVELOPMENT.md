# Development tasks

This list distinguishes implemented work from checks that require the engine or a device.

## Current iteration

- [x] Audit the prototype, existing tests, and local Android toolchain.
- [x] Enable touch-to-mouse emulation for standard controls and correct the specimens status translation.
- [x] Implement AP-limited reachable tiles, route and hit-chance previews, and symmetric line of sight; add rule and campaign regression checks. Engine validation is still pending.
- [ ] Run a Godot 4.7.2 headless import, tactical and campaign tests, and a scene smoke test. Godot is not installed in the current environment; network access is unavailable.
- [ ] Verify every screen, tactical action, and touch target on landscape Android devices at several aspect ratios.
- [ ] Install matching export templates and Android SDK/JDK, create and verify an Android export preset, then export, install, and test a debug APK.

## Next milestones

- [ ] Persist and resume an in-progress encounter safely, including mission outcome and migration of existing saves.
- [ ] Add a persistent soldier roster, injuries, experience, and permanent death.
- [ ] Add equipment, weapon and ammunition definitions, inventory, and tactical AI improvements.
- [ ] Implement campaign progression, mission generation, construction, research dependencies, and manufacturing incrementally.
- [ ] Test layout, localization, app pause/resume, persistence, and performance on physical Android devices.

## Known limitations

- Battle progress and soldiers currently do not persist across application restarts or missions.
- Enemy pursuit is greedy and can get stuck behind obstacles; it does not consider alternate visible targets.
- Movement is resolved immediately rather than step by step; visibility and interruptions are not updated along a route.
- Real-device touch, scaling, Android export, and pause/resume have not been validated.
