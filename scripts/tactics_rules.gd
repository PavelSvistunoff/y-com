extends RefCounted
## Pure game rules used by battle_view and headless tests.

## Returns each reachable tile's predecessor, including the starting tile.
## Only tiles in allowed may be entered; blocked tiles are never entered.
static func reachable_paths(start: Vector2i, width: int, height: int, blocked: Dictionary, allowed: Dictionary, max_steps: int) -> Dictionary:
    if start.x < 0 or start.y < 0 or start.x >= width or start.y >= height or max_steps < 0:
        return {}
    var previous: Dictionary = {start: start}
    var distances: Dictionary = {start: 0}
    var queue: Array[Vector2i] = [start]
    var cursor := 0
    while cursor < queue.size():
        var current: Vector2i = queue[cursor]
        cursor += 1
        if int(distances[current]) >= max_steps:
            continue
        for delta in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
            var next: Vector2i = current + delta
            if next.x < 0 or next.y < 0 or next.x >= width or next.y >= height:
                continue
            if blocked.has(next) or not allowed.has(next) or previous.has(next):
                continue
            previous[next] = current
            distances[next] = int(distances[current]) + 1
            queue.append(next)
    return previous

static func route_to(start: Vector2i, goal: Vector2i, previous: Dictionary) -> Array[Vector2i]:
    var path: Array[Vector2i] = []
    if not previous.has(start) or not previous.has(goal):
        return path
    var at := goal
    while at != start:
        path.append(at)
        at = previous[at]
    path.append(start)
    path.reverse()
    return path

static func tile_distance(a: Vector2i, b: Vector2i) -> int:
    return absi(a.x - b.x) + absi(a.y - b.y)

static func line_of_sight(a: Vector2i, b: Vector2i, walls: Dictionary) -> bool:
    var x: int = a.x
    var y: int = a.y
    var dx: int = absi(b.x - a.x)
    var dy: int = absi(b.y - a.y)
    var sx: int = 1 if x < b.x else -1
    var sy: int = 1 if y < b.y else -1
    var ix := 0
    var iy := 0
    while ix < dx or iy < dy:
        var x_crossing := (1 + 2 * ix) * dy
        var y_crossing := (1 + 2 * iy) * dx
        if x_crossing == y_crossing:
            # A line passing exactly through a corner touches both side cells.
            # Treat either wall as blocking, consistently in both directions.
            if walls.has(Vector2i(x + sx, y)) or walls.has(Vector2i(x, y + sy)):
                return false
            x += sx
            y += sy
            ix += 1
            iy += 1
        elif x_crossing < y_crossing:
            x += sx
            ix += 1
        else:
            y += sy
            iy += 1
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
