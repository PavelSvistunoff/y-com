# AEGIS — Product specification (initial)

## Vision

A lightweight, offline Android-first alien-invasion strategy game combining a global strategic layer, an expandable base, investigations, manufacturing, and granular, high-stakes turn-based tactical missions. The story evolves from isolated terrestrial signals to a connected undersea/orbital invasion. All lore and visuals must be original.

## Principles

- **No backend:** no cloud dependencies, accounts, tracking or advertisements.
- **Meaningful choices:** persistent soldiers, finite resources, permanent death, risk/reward.
- **Classic action economy:** action points (not limited to modern two-action turns), visibility, ammunition, inventory and cover.
- **Touch-first:** horizontal layout, generous tappable controls, legible fonts, clear hit chances, pan/zoom in later iterations.
- **Cross-platform:** Android target, desktop preview for development.
- **Multilingual:** Ukrainian and English from the start; never scatter gameplay strings across scripts.
- **Copyright-safe:** original world, equipment, art, aliens, locations and writing.

## Phase 0 — Playable vertical slice (seed implementation)

A single screen-driven demo with one mission, three soldiers, three enemies, tactical movement, line-of-sight, shooting, simple enemy turns, basic campaign economy, base/research screens and local save/load. This proves the architecture and input loop; it is **not** a full campaign.

## Phase 1 — Robust tactical engine

- Unit data resources; initiative, injuries, death and multi-mission roster.
- Procedural map pieces, destructible obstacles, cover, line of sight, elevation later.
- Route preview and reachable tile highlights, hit probability preview, reliable pathfinding, camera pan/zoom.
- Multiple weapons, ammunition types, equipment, inventory and reaction fire.
- Enemy behavior profiles; deterministic test fixtures and seeded RNG.
- Save and restore battles in progress (not only strategic state).

## Phase 2 — Strategic campaign

- Meaningful world map with regional finance and threat, time scaling, alert queue.
- Radar detection, craft construction/maintenance and UFO interception.
- Mission site generation, squad transport, equipment selection and interception aftermath.
- Base grid with placement rules, costs, build duration and staff capacity.
- Research dependencies, manufacturing queues, inventory and recovery economy.

## Phase 3 — World and campaign

- Original alien factions and motivations, escalating invasion, original cutscenes/text.
- Distinctive ocean threat requiring underwater operations with different mobility and equipment.
- Mission variety: crash sites, defense, retrieval, assaults, rescue, infiltration.
- Diplomacy, funding shifts, victory/loss conditions and multiple difficulty levels.

## Phase 4 — Android release quality

- Test on mid-range devices; set FPS/performance budget, pause/resume correctness.
- Responsive landscape layouts at different aspect ratios, accessibility and localization QA.
- Offline tutorial, sound/music with licensed original content, settings and local backups.
- Android signing and reproducible build docs, smoke tests, privacy statement.

## Acceptance criteria for next iteration

1. The project imports without parse errors and starts a tactical fight with no missing assets.
2. All visible tactical actions work via mouse and touch.
3. AP and obstacles prevent invalid moves; empty ammunition prevents firing.
4. A battle reaches victory/defeat and returns to geoscape; the result saves.
5. Strategic screens work after restart; saved progress survives closing the app.
6. Ukrainian and English screens are legible on 16:9 and tall/short landscape Android displays.
