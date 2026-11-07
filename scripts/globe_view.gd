extends Control
## Intentionally stylized rotating radar/sphere, built from primitives.
var phase: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    set_process(true)

func _process(delta: float) -> void:
    phase = fmod(phase + delta, TAU)
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    var r: float = minf(size.x, size.y) * 0.4
    if r <= 0.0:
        return
    draw_circle(center, r + 7.0, Color("0e4550"))
    draw_circle(center, r, Color("09252d"))
    for lat_index in range(-3, 4):
        var t: float = float(lat_index) / 4.0
        var y: float = center.y + r * t
        var half_width: float = sqrt(1.0 - t * t) * r
        draw_line(Vector2(center.x - half_width, y), Vector2(center.x + half_width, y), Color("1b6670"), 1.0, true)
    for line_index in range(6):
        var points := PackedVector2Array()
        var meridian_scale: float = sin(float(line_index) / 5.0 * PI + phase * 0.15)
        for i in range(37):
            var a: float = -PI * 0.5 + float(i) / 36.0 * PI
            points.append(center + Vector2(meridian_scale * cos(a) * r, sin(a) * r))
        draw_polyline(points, Color("1e6971"), 1.0, true)
    # Fictional landmass silhouettes deliberately avoid copyrighted map artwork.
    var continent := PackedVector2Array([
        center + Vector2(-0.56*r, -0.49*r), center + Vector2(-0.31*r, -0.72*r),
        center + Vector2(-0.12*r, -0.42*r), center + Vector2(-0.22*r, -0.12*r),
        center + Vector2(0.01*r, 0.07*r), center + Vector2(-0.19*r, 0.47*r),
        center + Vector2(-0.43*r, 0.22*r), center + Vector2(-0.36*r, -0.03*r),
        center + Vector2(-0.68*r, -0.14*r)
    ])
    draw_colored_polygon(continent, Color("1a4641"))
    var east := PackedVector2Array([
        center + Vector2(0.03*r, -0.66*r), center + Vector2(0.50*r, -0.54*r),
        center + Vector2(0.73*r, -0.15*r), center + Vector2(0.41*r, 0.17*r),
        center + Vector2(0.55*r, 0.43*r), center + Vector2(0.17*r, 0.67*r),
        center + Vector2(0.13*r, 0.21*r), center + Vector2(-0.05*r, -0.14*r)
    ])
    draw_colored_polygon(east, Color("1a4641"))
    if GameState.mission_available:
        var target := center + Vector2(r * 0.45, -r * 0.21)
        draw_circle(target, 7.0 + sin(phase * 3.0) * 2.0, Color("ff8067"))
        draw_arc(target, 21.0 + sin(phase * 2.0) * 5.0, 0, TAU, 36, Color("ff806799"), 2.0, true)
    draw_arc(center, r, 0.0, TAU, 120, Color("32acaa"), 2.0, true)
