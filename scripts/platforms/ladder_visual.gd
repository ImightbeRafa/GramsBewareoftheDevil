class_name LadderVisual
extends Node2D

const WOOD_DARK := Color(0.28, 0.18, 0.1, 1.0)
const WOOD_MID := Color(0.45, 0.3, 0.16, 1.0)
const WOOD_LIGHT := Color(0.62, 0.46, 0.24, 1.0)
const METAL_DARK := Color(0.38, 0.4, 0.44, 1.0)
const METAL_LIGHT := Color(0.72, 0.76, 0.82, 1.0)
const RUNG_COLOR := Color(0.58, 0.44, 0.22, 1.0)
const SHADOW := Color(0.08, 0.06, 0.05, 0.45)

var _width: float = 38.0
var _height: float = 144.0


func _ready() -> void:
	z_index = 4
	z_as_relative = false


func rebuild(width_px: float, height_px: float) -> void:
	_width = width_px
	_height = height_px
	queue_redraw()


func _draw() -> void:
	if _height < 8.0:
		return

	var half_w := _width * 0.5
	var top := Vector2(-half_w, -_height)
	var size := Vector2(_width, _height)

	# Drop shadow
	draw_rect(Rect2(top + Vector2(3.0, 3.0), size), SHADOW, true)

	# Backing board
	draw_rect(Rect2(top, size), Color(0.22, 0.15, 0.08, 0.55), true)
	draw_rect(Rect2(top, size), WOOD_DARK, false, 2.5)

	var rail_w := 6.0
	var rail_inset := 3.0
	var left_x := top.x + rail_inset
	var right_x := top.x + _width - rail_inset - rail_w

	# Vertical rails (filled rects for solid look)
	draw_rect(Rect2(Vector2(left_x, top.y), Vector2(rail_w, _height)), WOOD_DARK)
	draw_rect(Rect2(Vector2(left_x + 1.0, top.y), Vector2(2.0, _height)), WOOD_LIGHT)
	draw_rect(Rect2(Vector2(right_x, top.y), Vector2(rail_w, _height)), WOOD_DARK)
	draw_rect(Rect2(Vector2(right_x + 1.0, top.y), Vector2(2.0, _height)), WOOD_LIGHT)

	# Rungs
	var rung_spacing := float(KenneyPlatformTiles.TILE_SIZE)
	var rung_h := 4.0
	var rung_left := left_x + rail_w + 1.0
	var rung_right := right_x - 1.0
	var rung_count := int(_height / rung_spacing)

	for i in range(1, rung_count):
		var y := top.y + float(i) * rung_spacing - rung_h * 0.5
		var rung_rect := Rect2(Vector2(rung_left, y), Vector2(rung_right - rung_left, rung_h))
		draw_rect(rung_rect, RUNG_COLOR)
		draw_rect(rung_rect, WOOD_MID, false, 1.0)
		draw_line(
			Vector2(rung_left, y + 1.0),
			Vector2(rung_right, y + 1.0),
			WOOD_LIGHT,
			1.0,
			true
		)

	# Side brackets every 3 rungs
	for i in range(3, rung_count, 3):
		var y := top.y + float(i) * rung_spacing
		draw_line(Vector2(left_x - 2.0, y), Vector2(left_x + rail_w + 2.0, y), METAL_DARK, 2.0, true)
		draw_line(
			Vector2(right_x - 2.0, y),
			Vector2(right_x + rail_w + 2.0, y),
			METAL_DARK,
			2.0,
			true
		)

	# Top hoop / mount
	var top_y := top.y
	draw_arc(Vector2(0.0, top_y + 2.0), half_w - 2.0, PI, TAU, 16, METAL_LIGHT, 3.0, true)
	draw_line(Vector2(left_x, top_y), Vector2(right_x + rail_w, top_y), METAL_DARK, 4.0, true)

	# Bottom feet
	var foot_y := top.y + _height
	draw_rect(Rect2(Vector2(left_x - 4.0, foot_y - 3.0), Vector2(10.0, 5.0)), METAL_DARK)
	draw_rect(Rect2(Vector2(right_x - 2.0, foot_y - 3.0), Vector2(10.0, 5.0)), METAL_DARK)
