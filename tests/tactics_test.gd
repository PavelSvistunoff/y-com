extends SceneTree
## Run: godot --headless --path . --script res://tests/tactics_test.gd
const RULES = preload("res://scripts/tactics_rules.gd")

func _initialize() -> void:
    assert(RULES.tile_distance(Vector2i(0, 0), Vector2i(3, 4)) == 7)
    assert(RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {}))
    assert(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {Vector2i(2, 0): true}))
    var diagonal_wall := {Vector2i(0, 1): true}
    assert(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(1, 2), diagonal_wall))
    assert(not RULES.line_of_sight(Vector2i(1, 2), Vector2i(0, 0), diagonal_wall))
    assert(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(1, 1), {Vector2i(1, 0): true}))
    assert(RULES.adjacent_cover(Vector2i(2, 2), {Vector2i(2, 3): true}))
    assert(not RULES.adjacent_cover(Vector2i(2, 2), {}))
    assert(RULES.chance_to_hit(2, false, 80) == 80)
    assert(RULES.chance_to_hit(12, true, 80) < RULES.chance_to_hit(2, false, 80))
    var allowed := {}
    for y in range(3):
        for x in range(4):
            allowed[Vector2i(x, y)] = true
    var start := Vector2i(0, 1)
    var end := Vector2i(2, 1)
    var blocked := {Vector2i(1, 1): true}
    var paths: Dictionary = RULES.reachable_paths(start, 4, 3, blocked, allowed, 4)
    var route: Array[Vector2i] = RULES.route_to(start, end, paths)
    assert(route.size() == 5 and route.front() == start and route.back() == end)
    assert(not route.has(Vector2i(1, 1)))
    assert(not paths.has(Vector2i(3, 1)))
    assert(RULES.route_to(start, Vector2i(1, 1), paths).is_empty())
    allowed.erase(Vector2i(0, 0))
    allowed.erase(Vector2i(0, 2))
    paths = RULES.reachable_paths(start, 4, 3, blocked, allowed, 10)
    assert(paths.size() == 1)
    assert(RULES.route_to(start, start, paths) == [start])
    print("TACTICS_TEST_PASS")
    quit(0)
