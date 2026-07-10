class_name HookRopeVisual
extends Node2D

const ROPE_DARK := Color(0.42, 0.28, 0.12, 0.95)
const ROPE_MID := Color(0.72, 0.55, 0.22, 0.92)
const ROPE_LIGHT := Color(0.95, 0.82, 0.35, 0.88)
const AIM_DOT := Color(0.95, 0.85, 0.4, 0.55)
const HOOK_METAL := Color(0.55, 0.58, 0.62, 1.0)
const HOOK_TIP := Color(0.92, 0.78, 0.22, 1.0)

@export var segment_count: int = 11
@export var shoot_duration: float = 0.14

var _outer_line: Line2D
var _inner_line: Line2D
var _shoot_timer: float = 0.0
var _wobble_phase: float = 0.0
var _visible_rope: bool = false
var _visible_aim: bool = false
var _player_origin := Vector2(0.0, -12.0)
var _anchor_local := Vector2.ZERO
var _aim_end := Vector2.ZERO
var _aim_target_local := Vector2.ZERO
var _has_aim_target: bool = false
var _tension: float = 0.85
var _swing_speed: float = 0.0


func _ready() -> void:
	z_index = 5
	_outer_line = _make_line(3.2, ROPE_DARK)
	_inner_line = _make_line(1.4, ROPE_MID)
	add_child(_outer_line)
	add_child(_inner_line)


func _make_line(width: float, color: Color) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.antialiased = true
	line.visible = false
	return line


func trigger_shoot() -> void:
	_shoot_timer = shoot_duration


func hide_all() -> void:
	_visible_rope = false
	_visible_aim = false
	_outer_line.visible = false
	_inner_line.visible = false
	queue_redraw()


func update_attached(
	anchor_local: Vector2,
	player_velocity: Vector2,
	delta: float,
	next_target_local: Vector2 = Vector2.ZERO,
	has_next_target: bool = false
) -> void:
	_visible_rope = true
	_visible_aim = false
	_anchor_local = anchor_local
	_swing_speed = player_velocity.length()
	_tension = clampf(_swing_speed / 700.0, 0.35, 1.0)
	_wobble_phase += delta * (6.0 + _swing_speed * 0.012)
	if _shoot_timer > 0.0:
		_shoot_timer = maxf(_shoot_timer - delta, 0.0)

	_has_aim_target = has_next_target
	_aim_target_local = next_target_local if has_next_target else Vector2.ZERO

	var points := _build_rope_points(_player_origin, anchor_local, _tension, _wobble_phase)
	_outer_line.points = points
	_inner_line.points = points
	_outer_line.visible = true
	_inner_line.visible = true
	queue_redraw()


func update_aim(aim_end: Vector2, target_local: Vector2, has_target: bool) -> void:
	_visible_aim = true
	_visible_rope = false
	_aim_end = aim_end
	_aim_target_local = target_local
	_has_aim_target = has_target
	_outer_line.visible = false
	_inner_line.visible = false
	queue_redraw()


func _build_rope_points(start: Vector2, end: Vector2, tension: float, wobble_phase: float) -> PackedVector2Array:
	var span := end - start
	var length := span.length()
	if length < 1.0:
		return PackedVector2Array([start, end])

	var dir := span / length
	var perp := Vector2(-dir.y, dir.x)
	var sag := length * lerpf(0.18, 0.04, tension)
	var shoot_t := 1.0
	if _shoot_timer > 0.0:
		shoot_t = 1.0 - (_shoot_timer / shoot_duration)

	var points: PackedVector2Array = PackedVector2Array()
	for i in range(segment_count + 1):
		var t := float(i) / float(segment_count)
		if t > shoot_t:
			continue
		var base := start.lerp(end, t)
		var sag_curve := sin(t * PI) * sag
		var wobble := sin(wobble_phase + t * 7.5) * wobble_strength(t) * (1.1 - tension)
		base += Vector2(0.0, sag_curve) + perp * wobble
		points.append(base)

	if points.is_empty():
		points.append(start)
	if shoot_t < 1.0:
		points.append(start.lerp(end, shoot_t))
	else:
		points.append(end)
	return points


func wobble_strength(t: float) -> float:
	return sin(t * PI) * 3.5


func _draw() -> void:
	if _visible_aim:
		_draw_aim_preview()
	if _visible_rope:
		_draw_hook_head(_anchor_local)
		if _has_aim_target:
			_draw_target_marker(_aim_target_local, 9.0, 0.45)


func _draw_aim_preview() -> void:
	var end := _aim_end
	var span := end - _player_origin
	var length := span.length()
	if length < 1.0:
		return

	var dir := span / length
	var dot_spacing := 14.0
	var dot_count := int(length / dot_spacing)
	var perp := Vector2(-dir.y, dir.x)

	for i in range(dot_count + 1):
		var t := float(i) / float(max(dot_count, 1))
		if t > 1.0:
			break
		var pos := _player_origin.lerp(end, t)
		var sag := sin(t * PI) * length * 0.06
		pos += Vector2(0.0, sag)
		var alpha := lerpf(0.25, 0.65, t)
		var radius := lerpf(1.2, 2.4, t)
		draw_circle(pos, radius, Color(AIM_DOT.r, AIM_DOT.g, AIM_DOT.b, alpha))

	# Soft arc guide
	var arc_points: PackedVector2Array = PackedVector2Array()
	for i in range(16):
		var t := float(i) / 15.0
		var pos := _player_origin.lerp(end, t)
		pos += Vector2(0.0, sin(t * PI) * length * 0.06)
		arc_points.append(pos)
	if arc_points.size() >= 2:
		draw_polyline(arc_points, Color(AIM_DOT.r, AIM_DOT.g, AIM_DOT.b, 0.18), 1.0, true)

	if _has_aim_target:
		_draw_target_marker(_aim_target_local, 11.0, 0.85)


func _draw_hook_head(anchor: Vector2) -> void:
	var to_player := _player_origin - anchor
	if to_player.length_squared() < 1.0:
		return
	var dir := to_player.normalized()
	var perp := Vector2(-dir.y, dir.x)

	# Grapple ring at anchor
	draw_arc(anchor, 5.0, 0.0, TAU, 16, HOOK_TIP, 1.6, true)
	draw_circle(anchor, 2.2, HOOK_METAL)

	# Small claw prongs
	var tip := anchor + dir * 7.0
	draw_line(anchor + perp * 4.0, tip, HOOK_METAL, 2.0, true)
	draw_line(anchor - perp * 4.0, tip, HOOK_METAL, 2.0, true)
	draw_circle(tip, 2.0, HOOK_TIP)


func _draw_target_marker(center: Vector2, radius: float, alpha: float) -> void:
	var pulse := 0.85 + sin(_wobble_phase * 2.4) * 0.15
	var ring_color := Color(HOOK_TIP.r, HOOK_TIP.g, HOOK_TIP.b, alpha)
	draw_arc(center, radius * pulse, 0.0, TAU, 20, ring_color, 1.5, true)
	draw_line(center + Vector2(-radius * 0.55, 0.0), center + Vector2(radius * 0.55, 0.0), ring_color, 1.2, true)
	draw_line(center + Vector2(0.0, -radius * 0.55), center + Vector2(0.0, radius * 0.55), ring_color, 1.2, true)
