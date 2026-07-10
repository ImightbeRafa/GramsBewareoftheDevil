class_name CaneHook
extends Node

enum HookState { IDLE, PULLING, SWINGING }

@export var hook_range: float = 200.0
@export var pull_duration: float = 0.14
@export var max_pull_speed: float = 1050.0
@export var swing_duration: float = 0.4
@export var swing_speed: float = 300.0
@export var swing_move_speed: float = 320.0
@export var swing_jump_boost: float = -400.0
@export var swing_release_horizontal: float = 280.0
@export var aim_cone: float = 1.0

var _player: Player
var _visual: CaneVisual
var _state: HookState = HookState.IDLE
var _hook_point: Vector2 = Vector2.ZERO
var _hook_node: Node2D
var _pull_timer: float = 0.0
var _swing_timer: float = 0.0
var _swing_angle: float = 0.0
var _swing_direction: float = 1.0


func setup(player: Player, visual: CaneVisual = null) -> void:
	_player = player
	_visual = visual


func reset_state() -> void:
	_state = HookState.IDLE
	_pull_timer = 0.0
	_swing_timer = 0.0
	_hook_node = null


func is_hooking() -> bool:
	return _state != HookState.IDLE


func get_hook_anchor() -> Vector2:
	if _state == HookState.IDLE:
		return Vector2.ZERO
	return _hook_point


func get_aim_direction() -> Vector2:
	var mouse_pos := _player.get_global_mouse_position()
	var direction := mouse_pos - _player.global_position
	if direction.length_squared() < 16.0:
		return Vector2(_player.facing_direction, -0.6).normalized()
	return direction.normalized()


func find_best_hook_point(aim: Vector2, max_range: float = -1.0) -> Node2D:
	if max_range < 0.0:
		max_range = hook_range
	var best_point: Node2D = null
	var best_score := -INF
	for node in _player.get_tree().get_nodes_in_group("hook_point"):
		if not (node is Node2D):
			continue
		if not _is_hook_point_available(node as Node2D):
			continue
		var to_point: Vector2 = node.global_position - _player.global_position
		var distance := to_point.length()
		if distance > max_range or distance < 8.0:
			continue
		var point_dir := to_point.normalized()
		var angle_diff: float = absf(aim.angle_to(point_dir))
		if angle_diff > aim_cone:
			continue
		var score := cos(angle_diff) * 2.0 - distance / max_range
		if score > best_score:
			best_score = score
			best_point = node as Node2D
	return best_point


func try_fire_hook() -> bool:
	if _player.unlocks == null or not _player.unlocks.cane_hook:
		return false
	if _player.cane_mode != 1:
		return false
	if _state != HookState.IDLE:
		return false
	if not CaneInput.is_use_just_pressed():
		return false

	var aim := get_aim_direction()
	var best_point := find_best_hook_point(aim)
	if best_point == null:
		if _visual != null:
			_visual.flash_miss()
		return false

	var wall: WallAbility = _player.get_node("WallAbility") as WallAbility
	if wall != null:
		wall.cancel_attachment()

	_hook_node = best_point
	_hook_point = best_point.global_position
	_state = HookState.PULLING
	_pull_timer = pull_duration
	if _visual != null:
		_visual.flash_action(1)
	return true


func process(delta: float) -> void:
	if _hook_node != null and not _is_hook_point_available(_hook_node):
		reset_state()
		return

	match _state:
		HookState.IDLE:
			pass
		HookState.PULLING:
			_process_pull(delta)
		HookState.SWINGING:
			_process_swing(delta)


func process_input() -> void:
	if _state == HookState.IDLE:
		try_fire_hook()


func _process_pull(delta: float) -> void:
	_pull_timer -= delta
	if _hook_node != null and is_instance_valid(_hook_node):
		_hook_point = _hook_node.global_position
	var to_target := _hook_point - _player.global_position
	var distance := to_target.length()
	if distance > 6.0:
		var pull_speed := minf(distance / maxf(_pull_timer, 0.04), max_pull_speed)
		_player.velocity = to_target.normalized() * pull_speed
	else:
		_player.velocity = Vector2.ZERO

	if _pull_timer <= 0.0:
		_state = HookState.SWINGING
		_swing_timer = swing_duration
		var to_player := _player.global_position - _hook_point
		_swing_angle = to_player.angle()
		_swing_direction = signf(_player.facing_direction) if not is_zero_approx(_player.facing_direction) else 1.0


func _process_swing(delta: float) -> void:
	_swing_timer -= delta
	if _hook_node != null and is_instance_valid(_hook_node):
		_hook_point = _hook_node.global_position

	_swing_angle += (swing_speed / hook_range) * delta * _swing_direction

	var radius := clampf(_player.global_position.distance_to(_hook_point), 32.0, hook_range)
	var arc_target := _hook_point + Vector2(cos(_swing_angle), sin(_swing_angle)) * radius
	var to_arc := arc_target - _player.global_position

	if to_arc.length() > 3.0:
		_player.velocity = to_arc.normalized() * swing_move_speed
	else:
		var tangent := Vector2(-sin(_swing_angle), cos(_swing_angle)) * _swing_direction
		_player.velocity = tangent * swing_move_speed

	if Input.is_action_just_pressed("jump") or CaneInput.is_use_just_pressed():
		var release_dir := _player.velocity.normalized()
		if release_dir.length_squared() < 0.01:
			release_dir = Vector2(_player.facing_direction, -0.65).normalized()
		_player.velocity = Vector2(
			release_dir.x * swing_release_horizontal,
			swing_jump_boost
		)
		_player.reset_air_jumps()
		reset_state()
		return

	if _swing_timer <= 0.0:
		reset_state()


func _is_hook_point_available(node: Node2D) -> bool:
	var parent := node.get_parent()
	if parent is ShiftingBlock:
		return (parent as ShiftingBlock).is_touchable()
	return true
