extends VBoxContainer
## A small, playable tactics encounter. No external assets or network calls.
signal finished(victory: bool)

const RULES = preload("res://scripts/tactics_rules.gd")
const BOARD_SCRIPT = preload("res://scripts/battle_board.gd")
const MOVE_COST := 2
const FIRE_COST := 4
const RELOAD_COST := 4
const MAX_AP := 10
const MAX_AMMO := 4
const SHOT_RANGE := 10
const VIEW_RANGE := 7

var grid_width: int = 16
var grid_height: int = 12
var walls: Dictionary = {}
var explored: Dictionary = {}
var visible_tiles: Dictionary = {}
var reachable: Dictionary = {}
var preview_path: Array[Vector2i] = []
var preview_target: int = -1
var soldiers: Array[Dictionary] = []
var aliens: Array[Dictionary] = []
var selected_index: int = 0
var action_mode: String = "move"
var round_number: int = 1
var ended: bool = false
var board: Control
var selected_label: Label
var mode_label: Label
var turn_label: Label
var log_label: Label
var move_button: Button
var fire_button: Button
var reload_button: Button
var end_button: Button

func _ready() -> void:
    add_theme_constant_override("separation", 9)
    _create_encounter()
    _create_ui()
    _refresh_visibility()
    _refresh_ui()
    _log(Texts.t("tap_units"))

func _create_encounter() -> void:
    # Deliberately use original layouts and abstract art, not X-COM assets.
    for p in [
        Vector2i(4, 2), Vector2i(4, 3), Vector2i(4, 4),
        Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7),
        Vector2i(11, 3), Vector2i(11, 4), Vector2i(11, 5),
        Vector2i(3, 9), Vector2i(4, 9), Vector2i(12, 9)
    ]:
        walls[p] = true
    soldiers = [
        {"name": "ALPHA", "pos": Vector2i(1, 2), "hp": 4, "ap": MAX_AP, "ammo": MAX_AMMO},
        {"name": "BRAVO", "pos": Vector2i(1, 4), "hp": 4, "ap": MAX_AP, "ammo": MAX_AMMO},
        {"name": "CHARLIE", "pos": Vector2i(2, 6), "hp": 4, "ap": MAX_AP, "ammo": MAX_AMMO}
    ]
    aliens = [
        {"name": "DRONE 1", "pos": Vector2i(12, 2), "hp": 3},
        {"name": "DRONE 2", "pos": Vector2i(13, 6), "hp": 3},
        {"name": "DRONE 3", "pos": Vector2i(12, 10), "hp": 3}
    ]

func _create_ui() -> void:
    var heading := Label.new()
    heading.text = Texts.t("battle_title")
    heading.add_theme_font_size_override("font_size", 26)
    add_child(heading)
    var subtitle := Label.new()
    subtitle.text = Texts.t("battle_brief")
    subtitle.add_theme_font_size_override("font_size", 15)
    add_child(subtitle)

    var middle := HBoxContainer.new()
    middle.size_flags_vertical = Control.SIZE_EXPAND_FILL
    middle.add_theme_constant_override("separation", 16)
    add_child(middle)
    board = BOARD_SCRIPT.new()
    board.battle = self
    board.custom_minimum_size = Vector2(500, 370)
    board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    board.size_flags_vertical = Control.SIZE_EXPAND_FILL
    middle.add_child(board)

    var sidebar := VBoxContainer.new()
    sidebar.custom_minimum_size.x = 250
    sidebar.add_theme_constant_override("separation", 9)
    middle.add_child(sidebar)
    turn_label = _label(18)
    selected_label = _label(18)
    mode_label = _label(15)
    sidebar.add_child(turn_label)
    sidebar.add_child(selected_label)
    sidebar.add_child(mode_label)
    sidebar.add_child(HSeparator.new())
    move_button = _button(Texts.t("move"), func(): _set_mode("move"))
    fire_button = _button(Texts.t("fire"), func(): _set_mode("fire"))
    reload_button = _button(Texts.t("reload"), _reload)
    end_button = _button(Texts.t("end_turn"), _end_turn)
    sidebar.add_child(move_button)
    sidebar.add_child(fire_button)
    sidebar.add_child(reload_button)
    sidebar.add_child(end_button)
    sidebar.add_child(HSeparator.new())
    sidebar.add_child(_button(Texts.t("retreat"), func(): _finish(false)))
    sidebar.add_spacer(false)
    var hint := _label(14)
    hint.text = Texts.t("cover")
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    sidebar.add_child(hint)

    log_label = _label(15)
    log_label.custom_minimum_size.y = 32
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    add_child(log_label)

func _label(font_size: int) -> Label:
    var label := Label.new()
    label.add_theme_font_size_override("font_size", font_size)
    return label

func _button(value: String, action: Callable) -> Button:
    var button := Button.new()
    button.text = value
    button.custom_minimum_size.y = 45
    button.add_theme_font_size_override("font_size", 16)
    button.pressed.connect(action)
    return button

func _refresh_ui() -> void:
    if ended:
        return
    turn_label.text = "%s %d" % [Texts.t("turn"), round_number]
    var selected := _selected_soldier()
    if selected.is_empty():
        selected_label.text = Texts.t("selected") + ": —"
        reload_button.disabled = true
    else:
        selected_label.text = "%s: %s\nHP %d   AP %d   %d/%d" % [
            Texts.t("selected"), selected["name"], selected["hp"], selected["ap"], selected["ammo"], MAX_AMMO]
        reload_button.disabled = int(selected["ap"]) < RELOAD_COST or int(selected["ammo"]) >= MAX_AMMO
    _refresh_reachable()
    mode_label.text = "%s: %s" % [Texts.t("mode"), Texts.t(action_mode)]
    move_button.disabled = action_mode == "move"
    fire_button.disabled = action_mode == "fire"
    board.queue_redraw()

func _log(value: String) -> void:
    if log_label != null:
        log_label.text = "▣  " + value

func selected_tile() -> Vector2i:
    var unit := _selected_soldier()
    return unit["pos"] if not unit.is_empty() else Vector2i(-1, -1)

func _selected_soldier() -> Dictionary:
    if selected_index < 0 or selected_index >= soldiers.size():
        return {}
    if int(soldiers[selected_index]["hp"]) <= 0:
        return {}
    return soldiers[selected_index]

func is_visible_tile(p: Vector2i) -> bool:
    return visible_tiles.has(p)

func _refresh_visibility() -> void:
    visible_tiles.clear()
    for soldier in soldiers:
        if int(soldier["hp"]) <= 0:
            continue
        for y in range(grid_height):
            for x in range(grid_width):
                var p := Vector2i(x, y)
                if RULES.tile_distance(soldier["pos"], p) <= VIEW_RANGE and RULES.line_of_sight(soldier["pos"], p, walls):
                    visible_tiles[p] = true
                    explored[p] = true
    if board != null:
        board.queue_redraw()

func handle_board_tap(p: Vector2i) -> void:
    if ended:
        return
    for index in range(soldiers.size()):
        if soldiers[index]["pos"] == p and int(soldiers[index]["hp"]) > 0:
            selected_index = index
            preview_target = -1
            preview_path.clear()
            _refresh_ui()
            return
    var soldier := _selected_soldier()
    if soldier.is_empty():
        return
    for index in range(aliens.size()):
        if aliens[index]["pos"] == p and int(aliens[index]["hp"]) > 0 and is_visible_tile(p):
            if action_mode == "fire":
                preview_path.clear()
                _preview_or_shoot(index)
            else:
                preview_path.clear()
                _log(Texts.t("blocked"))
                _refresh_ui()
            return
    if action_mode == "move":
        _preview_or_move(p)
    else:
        preview_target = -1
        _log(Texts.t("out_of_range"))
        board.queue_redraw()

func _set_mode(value: String) -> void:
    action_mode = value
    preview_target = -1
    preview_path.clear()
    _refresh_ui()

func _occupied(p: Vector2i, skip_alien: int = -1) -> bool:
    for soldier in soldiers:
        if int(soldier["hp"]) > 0 and soldier["pos"] == p:
            return true
    for i in range(aliens.size()):
        if i != skip_alien and int(aliens[i]["hp"]) > 0 and aliens[i]["pos"] == p:
            return true
    return false

func _in_bounds(p: Vector2i) -> bool:
    return p.x >= 0 and p.y >= 0 and p.x < grid_width and p.y < grid_height

func _refresh_reachable() -> void:
    reachable.clear()
    var unit := _selected_soldier()
    if unit.is_empty() or action_mode != "move":
        return
    var blocked := walls.duplicate()
    for group in [soldiers, aliens]:
        for other in group:
            if int(other["hp"]) > 0 and other["pos"] != unit["pos"]:
                blocked[other["pos"]] = true
    # Restrict the entire route to currently visible tiles, so previews do not
    # disclose hidden unit locations or route through unexplored obstacles.
    reachable = RULES.reachable_paths(unit["pos"], grid_width, grid_height, blocked, visible_tiles, int(unit["ap"]) / MOVE_COST)

func _preview_or_move(target: Vector2i) -> void:
    var unit := _selected_soldier()
    if unit.is_empty() or not reachable.has(target) or target == unit["pos"]:
        preview_path.clear()
        _log(Texts.t("blocked"))
        _refresh_ui()
        return
    if not preview_path.is_empty() and preview_path.back() == target:
        _move_to(target)
        return
    preview_path = RULES.route_to(unit["pos"], target, reachable)
    _log(Texts.t("confirm_move") % ((preview_path.size() - 1) * MOVE_COST))
    board.queue_redraw()

func _move_to(target: Vector2i) -> void:
    if not is_visible_tile(target):
        _log(Texts.t("blocked"))
        return
    var unit := _selected_soldier()
    if unit.is_empty():
        return
    _refresh_reachable()
    var path := RULES.route_to(unit["pos"], target, reachable)
    if path.is_empty() or path.size() == 1:
        _log(Texts.t("blocked"))
        return
    var cost := (path.size() - 1) * MOVE_COST
    if cost > int(unit["ap"]):
        _log(Texts.t("not_enough_ap"))
        return
    preview_path.clear()
    unit["pos"] = target
    unit["ap"] = int(unit["ap"]) - cost
    _refresh_visibility()
    _log("%s: %s (-%d AP)" % [unit["name"], Texts.t("move"), cost])
    _refresh_ui()

func _preview_or_shoot(alien_index: int) -> void:
    var unit := _selected_soldier()
    var alien := aliens[alien_index]
    if unit.is_empty():
        return
    if int(unit["ap"]) < FIRE_COST:
        preview_target = -1
        _log(Texts.t("not_enough_ap"))
    elif int(unit["ammo"]) < 1:
        preview_target = -1
        _log(Texts.t("out_of_ammo"))
    elif RULES.tile_distance(unit["pos"], alien["pos"]) > SHOT_RANGE or not RULES.line_of_sight(unit["pos"], alien["pos"], walls):
        preview_target = -1
        _log(Texts.t("out_of_range"))
    elif preview_target == alien_index:
        preview_target = -1
        _shoot(alien_index)
    else:
        preview_target = alien_index
        var chance: int = RULES.chance_to_hit(RULES.tile_distance(unit["pos"], alien["pos"]), RULES.adjacent_cover(alien["pos"], walls), 78)
        _log(Texts.t("confirm_fire") % [chance, FIRE_COST])
    board.queue_redraw()

func _shoot(alien_index: int) -> void:
    var unit := _selected_soldier()
    var alien := aliens[alien_index]
    if unit.is_empty():
        return
    if int(unit["ap"]) < FIRE_COST:
        _log(Texts.t("not_enough_ap"))
        return
    if int(unit["ammo"]) < 1:
        _log(Texts.t("out_of_ammo"))
        return
    var range_to_target: int = RULES.tile_distance(unit["pos"], alien["pos"])
    if range_to_target > SHOT_RANGE or not is_visible_tile(alien["pos"]) or not RULES.line_of_sight(unit["pos"], alien["pos"], walls):
        _log(Texts.t("out_of_range"))
        return
    unit["ap"] = int(unit["ap"]) - FIRE_COST
    unit["ammo"] = int(unit["ammo"]) - 1
    var chance: int = RULES.chance_to_hit(range_to_target, RULES.adjacent_cover(alien["pos"], walls), 78)
    if randi_range(1, 100) <= chance:
        alien["hp"] = maxi(0, int(alien["hp"]) - 2)
        _log("%s → %s: HIT (-2 HP)" % [unit["name"], alien["name"]])
    else:
        _log("%s → %s: MISS" % [unit["name"], alien["name"]])
    _refresh_visibility()
    _refresh_ui()
    if _alive_count(aliens) == 0:
        _finish(true)

func _reload() -> void:
    var unit := _selected_soldier()
    if unit.is_empty() or int(unit["ap"]) < RELOAD_COST or int(unit["ammo"]) == MAX_AMMO:
        return
    preview_path.clear()
    preview_target = -1
    unit["ap"] = int(unit["ap"]) - RELOAD_COST
    unit["ammo"] = MAX_AMMO
    _log("%s: %s" % [unit["name"], Texts.t("reload")])
    _refresh_ui()

func _alive_count(group: Array[Dictionary]) -> int:
    var count := 0
    for unit in group:
        if int(unit["hp"]) > 0:
            count += 1
    return count

func _end_turn() -> void:
    if ended:
        return
    preview_path.clear()
    preview_target = -1
    # Aliens use a simple deterministic pursuit rule with probabilistic combat.
    for alien_index in range(aliens.size()):
        var alien := aliens[alien_index]
        if int(alien["hp"]) <= 0:
            continue
        var target := _closest_soldier(alien["pos"])
        if target.is_empty():
            _finish(false)
            return
        for _step in range(3):
            var pos: Vector2i = alien["pos"]
            if RULES.tile_distance(pos, target["pos"]) <= 5 and RULES.line_of_sight(pos, target["pos"], walls):
                break
            var best := pos
            var best_distance: int = RULES.tile_distance(pos, target["pos"])
            for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
                var candidate: Vector2i = pos + direction
                var distance: int = RULES.tile_distance(candidate, target["pos"])
                if _in_bounds(candidate) and not walls.has(candidate) and not _occupied(candidate, alien_index) and distance < best_distance:
                    best = candidate
                    best_distance = distance
            if best == pos:
                break
            alien["pos"] = best
        target = _closest_soldier(alien["pos"])
        if target.is_empty():
            break
        var distance: int = RULES.tile_distance(alien["pos"], target["pos"])
        if distance <= 7 and RULES.line_of_sight(alien["pos"], target["pos"], walls):
            var chance: int = RULES.chance_to_hit(distance, RULES.adjacent_cover(target["pos"], walls), 55)
            if randi_range(1, 100) <= chance:
                target["hp"] = maxi(0, int(target["hp"]) - 1)
                _log("%s → %s: HIT (-1 HP)" % [alien["name"], target["name"]])
    if _alive_count(soldiers) == 0:
        _finish(false)
        return
    round_number += 1
    for soldier in soldiers:
        if int(soldier["hp"]) > 0:
            soldier["ap"] = MAX_AP
    if _selected_soldier().is_empty():
        for i in range(soldiers.size()):
            if int(soldiers[i]["hp"]) > 0:
                selected_index = i
                break
    _refresh_visibility()
    _refresh_ui()

func _closest_soldier(from: Vector2i) -> Dictionary:
    var closest: Dictionary = {}
    var best_distance := 10000
    for soldier in soldiers:
        if int(soldier["hp"]) <= 0:
            continue
        var distance: int = RULES.tile_distance(from, soldier["pos"])
        if distance < best_distance:
            closest = soldier
            best_distance = distance
    return closest

func _finish(victory: bool) -> void:
    if ended:
        return
    ended = true
    finished.emit(victory)
