extends Control
## Touch/mouse board: procedural visuals with no external art dependency.
var battle: Control = null
var tile_size: float = 40.0
var board_origin: Vector2 = Vector2.ZERO

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    clip_contents = true

func _draw() -> void:
    if battle == null:
        return
    tile_size = minf((size.x - 14.0) / float(battle.grid_width), (size.y - 14.0) / float(battle.grid_height))
    board_origin = (size - Vector2(battle.grid_width, battle.grid_height) * tile_size) * 0.5
    for y in range(battle.grid_height):
        for x in range(battle.grid_width):
            var tile := Vector2i(x, y)
            var r := Rect2(board_origin + Vector2(x, y) * tile_size, Vector2.ONE * tile_size)
            var seen: bool = battle.is_visible_tile(tile)
            var explored: bool = battle.explored.has(tile)
            var color := Color("1b3a41") if (x + y) % 2 == 0 else Color("1a353b")
            if battle.walls.has(tile):
                color = Color("63727a")
            if not seen:
                color = Color("122930") if explored else Color("07171c")
            draw_rect(r.grow(-1.0), color, true)
            if battle.selected_tile() == tile:
                draw_rect(r.grow(-2.0), Color("3be4d8"), false, 3.0)
    for unit in battle.soldiers:
        if int(unit["hp"]) <= 0:
            continue
        _draw_unit(unit, Color("4ec9d4"), true)
    for unit in battle.aliens:
        if int(unit["hp"]) <= 0 or not battle.is_visible_tile(unit["pos"]):
            continue
        _draw_unit(unit, Color("fa826c"), false)

func _draw_unit(unit: Dictionary, color: Color, is_soldier: bool) -> void:
    var p: Vector2 = board_origin + (Vector2(unit["pos"]) + Vector2(0.5, 0.5)) * tile_size
    draw_circle(p, tile_size * 0.34, Color("05171b"))
    draw_circle(p, tile_size * 0.27, color)
    if is_soldier:
        draw_line(p + Vector2(-7, 0), p + Vector2(7, 0), Color("e2ffff"), 1.3)
    else:
        draw_circle(p, tile_size * 0.12, Color("3b1620"))
    var hp: String = str(unit["hp"])
    draw_string(ThemeDB.fallback_font, p + Vector2(-4.0, -tile_size * 0.31), hp, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("ffffff"))

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        _handle_tap(event.position)
        accept_event()
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_tap(event.position)
        accept_event()

func _handle_tap(pos: Vector2) -> void:
    var logical: Vector2 = (pos - board_origin) / tile_size
    var cell := Vector2i(floori(logical.x), floori(logical.y))
    if cell.x >= 0 and cell.y >= 0 and cell.x < battle.grid_width and cell.y < battle.grid_height:
        battle.handle_board_tap(cell)
