extends SceneTree
## Run: godot --headless --path . --script res://tests/game_state_test.gd
## Uses a separate temporary save, never the campaign's normal save file.
const STATE = preload("res://scripts/game_state.gd")

var failures: int = 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    var path := "user://aegis_test_%d_%d.json" % [OS.get_process_id(), Time.get_ticks_usec()]
    var state = STATE.new()
    state.save_path = path

    check(not state.build_facility("unknown"), "Unknown facilities must not be built")
    check(state.build_facility("lab"), "A valid facility should be built")
    check(state.credits == 780000 and state.facilities["lab"] == 2, "Facility cost and count")
    state.credits = 0
    check(not state.build_facility("hangar") and state.facilities["hangar"] == 1, "Insufficient funds must prevent construction")
    state.credits = 780000

    check(not state.begin_research("unknown"), "Unknown research must be rejected")
    check(state.begin_research("biology"), "Valid research should start")
    check(not state.begin_research("signals"), "Only one project may be active")
    state.advance_days(7)
    check(state.day == 8 and state.credits == 825000, "Day advancement and weekly funding")
    check(state.research_progress == 84 and state.active_research == "biology", "Research must use laboratory count")
    state.advance_days(2)
    check(state.active_research == "" and state.completed_research.has("biology"), "Research completion")
    check(not state.begin_research("biology"), "Completed research cannot restart")

    state.report_mission(true)
    check(not state.mission_available and state.mission_wins == 1 and state.materials == 1 and state.credits == 925000, "Victory rewards and mission availability")
    state.advance_days(2)
    check(state.day == 12 and state.mission_available, "A new mission becomes available on day four multiples")
    state.report_mission(false)
    check(not state.mission_available and state.mission_losses == 1 and state.credits == 895000, "Defeat cost and mission availability")

    var restored = STATE.new()
    restored.save_path = path
    restored.load_game()
    check(restored.day == state.day and restored.credits == state.credits, "Saved economy must round-trip")
    check(restored.mission_wins == 1 and restored.mission_losses == 1 and not restored.mission_available, "Saved mission results must round-trip")
    check(restored.facilities["lab"] == 2 and restored.completed_research.has("biology"), "Saved facilities and research must round-trip")

    # A minimal version-1 save predating optional fields must retain defaults.
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        check(false, "Could not write isolated legacy save")
    else:
        file.store_string(JSON.stringify({"version": 1, "day": 20, "credits": 123}))
        file.close()
        var legacy = STATE.new()
        legacy.save_path = path
        legacy.load_game()
        check(legacy.day == 20 and legacy.credits == 123 and legacy.facilities["lab"] == 1, "Version-1 saves with missing optional fields must load")
        legacy.free()

    state.free()
    restored.free()
    if FileAccess.file_exists(path):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
    if failures == 0:
        print("GAME_STATE_TEST_PASS")
    quit(0 if failures == 0 else 1)
