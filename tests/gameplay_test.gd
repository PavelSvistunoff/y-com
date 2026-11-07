extends SceneTree
## Exercises the real scene and battle controller using an isolated campaign save.
## Run with AEGIS_TEST_DIR set to a writable temporary directory if user:// is unavailable.

var failures := 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    call_deferred("run_test")

func run_test() -> void:
    var test_dir := OS.get_environment("AEGIS_TEST_DIR")
    if test_dir.is_empty():
        test_dir = "user://"
    var path := test_dir.path_join("aegis_smoke_%d_%d.json" % [OS.get_process_id(), Time.get_ticks_usec()])
    var state := root.get_node("GameState")
    state.save_path = path
    state.reset_campaign()
    var main = load("res://scenes/main.tscn").instantiate()
    root.add_child(main)
    check(main.current_screen == "geoscape", "Main scene must open the geoscape")
    main.show_screen("base")
    check(main.current_screen == "base", "Base screen must open")
    main.show_screen("research")
    check(main.current_screen == "research", "Research screen must open")
    main.show_screen("geoscape")
    main._deploy()
    check(main.current_screen == "battle", "Deploy must open a battle")
    var battle = main.content.get_child(0)
    var soldier: Dictionary = battle.soldiers[0]
    var start: Vector2i = soldier["pos"]
    var destination := start + Vector2i.RIGHT
    check(battle.reachable.has(destination), "Adjacent empty visible tile must be reachable")
    battle.handle_board_tap(destination)
    check(soldier["pos"] == start and soldier["ap"] == 10, "Preview must not spend AP or move")
    battle.handle_board_tap(destination)
    check(soldier["pos"] == destination and soldier["ap"] == 8, "Confirmed movement must spend two AP")
    battle.handle_board_tap(Vector2i(4, 2))
    check(soldier["pos"] == destination and soldier["ap"] == 8, "Walls must prevent movement")
    battle.aliens[0]["pos"] = Vector2i(3, 2)
    battle._refresh_visibility()
    battle._set_mode("fire")
    soldier["ammo"] = 0
    battle.handle_board_tap(Vector2i(3, 2))
    check(battle.preview_target == -1 and soldier["ap"] == 8, "Empty ammunition must prevent firing")
    battle._reload()
    check(soldier["ammo"] == 4 and soldier["ap"] == 4, "Reload must consume AP and refill ammunition")
    soldier["ap"] = 8
    battle.handle_board_tap(Vector2i(3, 2))
    check(battle.preview_target == 0 and soldier["ammo"] == 4, "Shot preview must not spend ammunition")
    battle.handle_board_tap(Vector2i(3, 2))
    check(soldier["ammo"] == 3 and soldier["ap"] == 4, "Confirmed shot must spend AP and ammunition")
    battle._end_turn()
    check(battle.round_number == 2 and soldier["ap"] == 10, "Enemy turn must restore surviving soldiers' AP")
    # Resolve the encounter through actual combat, with bounded retries for random misses.
    battle.aliens[1]["hp"] = 0
    battle.aliens[2]["hp"] = 0
    battle.aliens[0]["pos"] = Vector2i(3, 2)
    battle.aliens[0]["hp"] = 1
    soldier["hp"] = 4
    battle._refresh_visibility()
    for attempt in range(100):
        if main.current_screen != "battle":
            break
        soldier["ap"] = 10
        soldier["ammo"] = 4
        battle._shoot(0)
    check(main.current_screen == "geoscape" and state.mission_wins == 1, "Victory must return and update campaign")
    var restored = load("res://scripts/game_state.gd").new()
    restored.save_path = path
    restored.load_game()
    check(restored.mission_wins == 1 and not restored.mission_available, "Victory must persist")
    restored.free()
    state.mission_available = true
    main._deploy()
    battle = main.content.get_child(0)
    for unit in battle.soldiers:
        unit["hp"] = 0
    battle._end_turn()
    check(main.current_screen == "geoscape" and state.mission_losses == 1, "Defeat must return and update campaign")
    main.free()
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    if failures == 0:
        print("GAMEPLAY_TEST_PASS")
    quit(0 if failures == 0 else 1)
