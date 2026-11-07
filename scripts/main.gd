extends Control
## UI shell for a small, offline, playable vertical slice.
const GLOBE_SCRIPT = preload("res://scripts/globe_view.gd")
const BATTLE_SCRIPT = preload("res://scripts/battle_view.gd")
var current_screen: String = "geoscape"
var content: MarginContainer
var status: Label
var event_log: Label
var navigation: Dictionary = {}
var lang_button: Button
var last_message: String = ""

func _ready() -> void:
    _make_theme()
    _make_shell()
    GameState.changed.connect(_update_status)
    show_screen("geoscape")

func _make_theme() -> void:
    var t := Theme.new()
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color("14343e")
    normal.border_color = Color("36707c")
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(5)
    normal.content_margin_left = 16
    normal.content_margin_right = 16
    normal.content_margin_top = 9
    normal.content_margin_bottom = 9
    var hover := normal.duplicate() as StyleBoxFlat
    hover.bg_color = Color("1d5260")
    var disabled := normal.duplicate() as StyleBoxFlat
    disabled.bg_color = Color("263137")
    t.set_stylebox("normal", "Button", normal)
    t.set_stylebox("hover", "Button", hover)
    t.set_stylebox("pressed", "Button", hover)
    t.set_stylebox("disabled", "Button", disabled)
    for style in ["normal", "hover", "pressed", "focus"]:
        t.set_color("font_color", "Button", Color("d9eef0"))
    t.set_color("font_disabled_color", "Button", Color("718389"))
    t.set_color("font_color", "Label", Color("dcebef"))
    theme = t

func _make_shell() -> void:
    var background := ColorRect.new()
    background.color = Color("08181d")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(background)
    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 8)
    add_child(root)
    var header := HBoxContainer.new()
    header.custom_minimum_size.y = 60
    header.add_theme_constant_override("separation", 12)
    root.add_child(header)
    var brand := _label("  AEGIS  /  ALIEN EARTH DEFENSE", 23)
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(brand)
    status = _label("", 16)
    header.add_child(status)
    header.add_child(_label("   "))

    var bar := HBoxContainer.new()
    bar.add_theme_constant_override("separation", 9)
    root.add_child(bar)
    for id in ["geoscape", "base", "research"]:
        var caption: String = {"geoscape": "geo", "base": "base", "research": "research"}[id]
        var button := _button(Texts.t(caption), func(): show_screen(id))
        bar.add_child(button)
        navigation[id] = button
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    bar.add_child(spacer)
    lang_button = _button(Texts.t("language"), _toggle_language)
    bar.add_child(lang_button)
    var body := PanelContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var panel_style := StyleBoxFlat.new()
    panel_style.bg_color = Color("0b2027")
    panel_style.border_color = Color("24434b")
    panel_style.set_border_width_all(1)
    body.add_theme_stylebox_override("panel", panel_style)
    root.add_child(body)
    content = MarginContainer.new()
    content.add_theme_constant_override("margin_left", 20)
    content.add_theme_constant_override("margin_right", 20)
    content.add_theme_constant_override("margin_top", 15)
    content.add_theme_constant_override("margin_bottom", 15)
    body.add_child(content)
    event_log = _label("", 15)
    event_log.custom_minimum_size.y = 25
    root.add_child(event_log)

func _label(value: String, font_size: int = 18) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_font_size_override("font_size", font_size)
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return label

func _button(value: String, action: Callable) -> Button:
    var b := Button.new()
    b.text = value
    b.custom_minimum_size = Vector2(100, 45)
    b.add_theme_font_size_override("font_size", 17)
    b.pressed.connect(action)
    return b

func _heading(parent: VBoxContainer, title: String, description: String) -> void:
    parent.add_child(_label(title, 30))
    var subtitle := _label(description, 17)
    subtitle.add_theme_color_override("font_color", Color("82aab5"))
    parent.add_child(subtitle)
    parent.add_child(HSeparator.new())

func show_screen(id: String) -> void:
    if current_screen == "battle" and id != "battle":
        return  # Active battles are resolved or retreated, never discarded silently.
    for child in content.get_children():
        content.remove_child(child)
        child.queue_free()
    current_screen = id
    for nav_id in navigation.keys():
        (navigation[nav_id] as Button).disabled = (id == "battle")
    lang_button.disabled = (id == "battle")
    match id:
        "geoscape": _geoscape_screen()
        "base": _base_screen()
        "research": _research_screen()
        "battle": _battle_screen()
    _update_status()

func _update_status() -> void:
    if status != null:
        status.text = "%s %d     %s: %s     %s: %d" % [Texts.t("day"), GameState.day, Texts.t("credits"), _money(GameState.credits), Texts.t("specimens"), GameState.materials]
    if event_log != null:
        event_log.text = "  ▣  " + (last_message if last_message != "" else Texts.t("welcome"))

func _money(value: int) -> String:
    return str(value)

func _geoscape_screen() -> void:
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 13)
    content.add_child(layout)
    _heading(layout, Texts.t("geoscape_title"), Texts.t("geo_brief"))
    var h := HBoxContainer.new()
    h.size_flags_vertical = Control.SIZE_EXPAND_FILL
    h.add_theme_constant_override("separation", 25)
    layout.add_child(h)
    var globe = GLOBE_SCRIPT.new()
    globe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    globe.size_flags_vertical = Control.SIZE_EXPAND_FILL
    h.add_child(globe)
    var actions := VBoxContainer.new()
    actions.custom_minimum_size.x = 330
    actions.add_theme_constant_override("separation", 15)
    h.add_child(actions)
    var alert := _label(Texts.t("alert_yes") if GameState.mission_available else Texts.t("alert_no"), 20)
    alert.add_theme_color_override("font_color", Color("fa977d") if GameState.mission_available else Color("7cb9a8"))
    actions.add_child(alert)
    var deploy := _button(Texts.t("deploy"), _deploy)
    deploy.disabled = not GameState.mission_available
    deploy.custom_minimum_size.y = 66
    actions.add_child(deploy)
    actions.add_child(HSeparator.new())
    actions.add_child(_button(Texts.t("one_day"), func(): _advance(1)))
    actions.add_child(_button(Texts.t("seven_days"), func(): _advance(7)))
    actions.add_spacer(false)
    actions.add_child(_label(Texts.t("mission_status") % [GameState.mission_wins, GameState.mission_losses], 16))

func _advance(days: int) -> void:
    GameState.advance_days(days)
    show_screen("geoscape")

func _deploy() -> void:
    if not GameState.mission_available:
        _event(Texts.t("no_mission"))
        return
    _event(Texts.t("mission_started"))
    show_screen("battle")

func _base_screen() -> void:
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 18)
    content.add_child(col)
    _heading(col, Texts.t("base_title"), Texts.t("base_brief"))
    for key in ["lab", "workshop", "hangar", "quarters"]:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 16)
        col.add_child(row)
        var facility := _label("%s   × %d" % [Texts.t(key), int(GameState.facilities[key])], 22)
        facility.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(facility)
        var build_btn := _button(Texts.t("build"), func(): _build(key))
        build_btn.disabled = GameState.credits < GameState.FACILITY_COST
        row.add_child(build_btn)

func _build(key: String) -> void:
    GameState.build_facility(key)
    show_screen("base")

func _research_screen() -> void:
    var col := VBoxContainer.new()
    col.add_theme_constant_override("separation", 17)
    content.add_child(col)
    _heading(col, Texts.t("research_title"), Texts.t("research_brief"))
    var current: String = Texts.t("no_research")
    if GameState.active_research != "":
        current = Texts.t("in_progress") % [Texts.t(GameState.active_research), GameState.research_progress]
    col.add_child(_label(current, 21))
    col.add_child(HSeparator.new())
    for key in ["materials", "biology", "signals"]:
        var row := HBoxContainer.new()
        col.add_child(row)
        var item := _label(Texts.t(key), 22)
        item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(item)
        if GameState.completed_research.has(key):
            row.add_child(_label(Texts.t("done"), 17))
        else:
            var start_button := _button(Texts.t("begin"), func(): _research(key))
            start_button.disabled = GameState.active_research != ""
            row.add_child(start_button)

func _research(key: String) -> void:
    GameState.begin_research(key)
    show_screen("research")

func _battle_screen() -> void:
    var battle = BATTLE_SCRIPT.new()
    battle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    battle.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(battle)
    battle.finished.connect(_battle_finished)

func _battle_finished(victory: bool) -> void:
    GameState.report_mission(victory)
    _event(Texts.t("victory") if victory else Texts.t("defeat"))
    # Explicitly end combat before changing screens.
    current_screen = "geoscape"
    show_screen("geoscape")

func _event(value: String) -> void:
    last_message = value
    _update_status()

func _toggle_language() -> void:
    if current_screen == "battle":
        return
    Texts.toggle()
    for id in navigation.keys():
        (navigation[id] as Button).text = Texts.t({"geoscape":"geo","base":"base","research":"research"}[id])
    lang_button.text = Texts.t("language")
    show_screen(current_screen)
