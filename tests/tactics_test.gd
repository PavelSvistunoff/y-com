extends SceneTree
## Run: godot --headless --path . --script res://tests/tactics_test.gd
const RULES = preload("res://scripts/tactics_rules.gd")

var failures := 0

func check(condition: bool, description: String) -> void:
    if not condition:
        failures += 1
        push_error(description)

func _initialize() -> void:
    check(RULES.tile_distance(Vector2i(0, 0), Vector2i(3, 4)) == 7, "RULES.tile_distance(Vector2i(0, 0), Vector2i(3, 4)) == 7")
    check(RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {}), "RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {})")
    check(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {Vector2i(2, 0): true}), "not RULES.line_of_sight(Vector2i(0, 0), Vector2i(3, 0), {Vector2i(2, 0): true})")
    var diagonal_wall := {Vector2i(0, 1): true}
    check(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(1, 2), diagonal_wall), "not RULES.line_of_sight(Vector2i(0, 0), Vector2i(1, 2), diagonal_wall)")
    check(not RULES.line_of_sight(Vector2i(1, 2), Vector2i(0, 0), diagonal_wall), "not RULES.line_of_sight(Vector2i(1, 2), Vector2i(0, 0), diagonal_wall)")
    check(not RULES.line_of_sight(Vector2i(0, 0), Vector2i(1, 1), {Vector2i(1, 0): true}), "not RULES.line_of_sight(Vector2i(0, 0), Vector2i(1, 1), {Vector2i(1, 0): true})")
    check(RULES.adjacent_cover(Vector2i(2, 2), {Vector2i(2, 3): true}), "RULES.adjacent_cover(Vector2i(2, 2), {Vector2i(2, 3): true})")
    check(not RULES.adjacent_cover(Vector2i(2, 2), {}), "not RULES.adjacent_cover(Vector2i(2, 2), {})")
    check(RULES.chance_to_hit(2, false, 80) == 80, "RULES.chance_to_hit(2, false, 80) == 80")
    check(RULES.chance_to_hit(12, true, 80) < RULES.chance_to_hit(2, false, 80), "RULES.chance_to_hit(12, true, 80) < RULES.chance_to_hit(2, false, 80)")
    var allowed := {}
    for y in range(3):
        for x in range(4):
            allowed[Vector2i(x, y)] = true
    var start := Vector2i(0, 1)
    var end := Vector2i(2, 1)
    var blocked := {Vector2i(1, 1): true}
    var paths: Dictionary = RULES.reachable_paths(start, 4, 3, blocked, allowed, 4)
    var route: Array[Vector2i] = RULES.route_to(start, end, paths)
    check(route.size() == 5 and route.front() == start and route.back() == end, "route.size() == 5 and route.front() == start and route.back() == end")
    check(not route.has(Vector2i(1, 1)), "not route.has(Vector2i(1, 1))")
    check(not paths.has(Vector2i(3, 1)), "not paths.has(Vector2i(3, 1))")
    check(RULES.route_to(start, Vector2i(1, 1), paths).is_empty(), "RULES.route_to(start, Vector2i(1, 1), paths).is_empty()")
    allowed.erase(Vector2i(0, 0))
    allowed.erase(Vector2i(0, 2))
    paths = RULES.reachable_paths(start, 4, 3, blocked, allowed, 10)
    check(paths.size() == 1, "paths.size() == 1")
    check(RULES.route_to(start, start, paths) == [start], "RULES.route_to(start, start, paths) == [start]")
    if failures == 0:
        print("TACTICS_TEST_PASS")
    quit(0 if failures == 0 else 1)
