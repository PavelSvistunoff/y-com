extends RefCounted
## Pure game rules used by battle_view and headless tests.

static func tile_distance(a: Vector2i, b: Vector2i) -> int:
    return absi(a.x - b.x) + absi(a.y - b.y)

static func line_of_sight(a: Vector2i, b: Vector2i, walls: Dictionary) -> bool:
    var x: int = a.x
    var y: int = a.y
    var dx: int = absi(b.x - a.x)
    var dy: int = absi(b.y - a.y)
    var sx: int = 1 if x < b.x else -1
    var sy: int = 1 if y < b.y else -1
    var error: int = dx - dy
    while Vector2i(x, y) != b:
        var e2: int = error * 2
        if e2 > -dy:
            error -= dy
            x += sx
        if e2 < dx:
            error += dx
            y += sy
        var p := Vector2i(x, y)
        if p != b and walls.has(p):
            return false
    return true

static func adjacent_cover(p: Vector2i, walls: Dictionary) -> bool:
    for d in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
        if walls.has(p + d):
            return true
    return false

static func chance_to_hit(distance: int, target_in_cover: bool, base_accuracy: int) -> int:
    var cover_penalty := 18 if target_in_cover else 0
    return clampi(base_accuracy - maxi(0, distance - 2) * 5 - cover_penalty, 15, 95)
