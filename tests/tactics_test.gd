extends SceneTree
## Run: godot --headless --path . --script res://tests/tactics_test.gd
const RULES = preload("res://scripts/tactics_rules.gd")

func _initialize() -> void:
    assert(RULES.tile_distance(Vector2i(0, 0), Vector2i(3, 4)) == 7)
    assert(RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {}))
    assert(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {Vector2i(2, 0): true}))
    assert(RULES.adjacent_cover(Vector2i(2, 2), {Vector2i(2, 3): true}))
    assert(not RULES.adjacent_cover(Vector2i(2, 2), {}))
    assert(RULES.chance_to_hit(2, false, 80) == 80)
    assert(RULES.chance_to_hit(12, true, 80) < RULES.chance_to_hit(2, false, 80))
    print("TACTICS_TEST_PASS")
    quit(0)
