class_name GameCamera
extends Camera2D

## Global player camera — mouse edge look-ahead, movement peek, landing dip.

@export_group("Zoom")
@export var base_zoom: float = 1.15

@export_group("Mouse Look-Ahead")
@export var dead_zone_ratio: float = 0.38
@export var max_look_offset: Vector2 = Vector2(140.0, 72.0)
@export var resistance_power: float = 2.4
@export var look_smooth_speed: float = 7.0
@export var require_window_focus: bool = true

@export_group("Movement Look-Ahead")
@export var movement_look_strength: Vector2 = Vector2(28.0, 24.0)
@export var fall_look_strength: float = 28.0
@export var rise_look_strength: float = 10.0
@export var movement_look_turn_speed: float = 5.0

@export_group("Landing Dip")
@export var landing_dip_strength: float = 4.0
@export var landing_dip_recovery: float = 16.0

var _current_offset: Vector2 = Vector2.ZERO
var _landing_dip: float = 0.0
var _smoothed_horizontal_look: float = 0.0
var _player: Player


func _ready() -> void:
	zoom = Vector2(base_zoom, base_zoom)
	position_smoothing_enabled = true
	position_smoothing_speed = 10.0
	limit_smoothed = true
	_player = get_parent() as Player


func _process(delta: float) -> void:
	var mouse_offset := _calculate_mouse_look_offset()
	var movement_offset := _calculate_movement_look_offset(delta)
	var target_offset := mouse_offset + movement_offset

	_landing_dip = move_toward(_landing_dip, 0.0, landing_dip_recovery * delta)
	_current_offset = _current_offset.lerp(target_offset, look_smooth_speed * delta)
	offset = _current_offset + Vector2(0.0, _landing_dip)


func trigger_landing_dip(fall_speed: float) -> void:
	var intensity := clampf(fall_speed / 500.0, 0.35, 1.0)
	_landing_dip = landing_dip_strength * intensity


func set_level_bounds(left: float, top: float, right: float, bottom: float) -> void:
	limit_left = int(left)
	limit_top = int(top)
	limit_right = int(right)
	limit_bottom = int(bottom)


func clear_level_bounds() -> void:
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000


func _has_window_focus() -> bool:
	var viewport := get_viewport()
	if viewport == null:
		return true
	var window := viewport.get_window()
	if window == null:
		return true
	return window.has_focus()


func _calculate_mouse_look_offset() -> Vector2:
	if require_window_focus and not _has_window_focus():
		return Vector2.ZERO

	var viewport := get_viewport()
	if viewport == null:
		return Vector2.ZERO

	var viewport_size := viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return Vector2.ZERO

	var mouse_pos := viewport.get_mouse_position()
	var center := viewport_size * 0.5
	var half_size := viewport_size * 0.5

	var normalized := Vector2(
		(mouse_pos.x - center.x) / half_size.x,
		(mouse_pos.y - center.y) / half_size.y
	)
	normalized.x = clampf(normalized.x, -1.0, 1.0)
	normalized.y = clampf(normalized.y, -1.0, 1.0)

	return Vector2(
		_apply_edge_resistance(normalized.x) * max_look_offset.x,
		_apply_edge_resistance(normalized.y) * max_look_offset.y
	)


func _apply_edge_resistance(axis: float) -> float:
	var magnitude := absf(axis)
	if magnitude <= dead_zone_ratio:
		return 0.0
	var t := (magnitude - dead_zone_ratio) / (1.0 - dead_zone_ratio)
	t = pow(t, resistance_power)
	return signf(axis) * t


func _calculate_movement_look_offset(delta: float) -> Vector2:
	if _player == null:
		return Vector2.ZERO

	var target_horizontal := 0.0
	var input_x := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(input_x):
		target_horizontal = input_x
	elif absf(_player.velocity.x) > 40.0:
		target_horizontal = signf(_player.velocity.x)

	_smoothed_horizontal_look = lerpf(
		_smoothed_horizontal_look,
		target_horizontal,
		movement_look_turn_speed * delta
	)

	var vertical := 0.0
	if _player.velocity.y > 60.0:
		vertical = clampf(_player.velocity.y / 400.0, 0.2, 1.0) * fall_look_strength / maxf(movement_look_strength.y, 1.0)
	elif _player.velocity.y < -60.0:
		vertical = -rise_look_strength / maxf(movement_look_strength.y, 1.0)

	return Vector2(
		_smoothed_horizontal_look * movement_look_strength.x,
		vertical * movement_look_strength.y
	)
