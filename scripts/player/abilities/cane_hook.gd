class_name CaneHook
extends Node

enum HookState { IDLE, ATTACHED }

@export var hook_range: float = 400.0
@export var aim_cone: float = 1.25
@export var min_rope_length: float = 72.0
@export var yank_duration: float = 0.1
@export var yank_accel: float = 3600.0
@export var reel_speed: float = 160.0
@export var swing_gravity_scale: float = 1.1
@export var tangent_accel: float = 550.0
@export var max_swing_speed: float = 1050.0
@export var release_min_speed: float = 120.0
@export var attach_air_jump_refresh: bool = true
@export var detach_on_floor: bool = true
@export var same_hook_cooldown: float = 0.05

var _player: Player
var _visual: CaneVisual
var _state: HookState = HookState.IDLE
var _hook_point: Vector2 = Vector2.ZERO
var _hook_node: Node2D
var _rope_length: float = 0.0
var _yank_timer: float = 0.0
var _same_hook_cooldown_timer: float = 0.0
var _last_hook_node: Node2D


func setup(player: Player, visual: CaneVisual = null) -> void:
	_player = player
	_visual = visual


func reset_state() -> void:
	_state = HookState.IDLE
	_pull_reset_timers()
	_hook_node = null
	_hook_point = Vector2.ZERO
	_rope_length = 0.0


func _pull_reset_timers() -> void:
	_yank_timer = 0.0


func is_hooking() -> bool:
	return _state == HookState.ATTACHED


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
		if node == _last_hook_node and _same_hook_cooldown_timer > 0.0:
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


func process_idle_input() -> void:
	if _player.unlocks == null or not _player.unlocks.cane_hook:
		return
	if _state != HookState.IDLE:
		return
	if not CaneInput.is_use_just_pressed():
		return
	try_fire_hook()


func process_attached_input() -> void:
	if _state != HookState.ATTACHED:
		return

	if CaneInput.is_use_just_released():
		release()
		return

	if Input.is_action_just_pressed("jump"):
		release_with_jump()
		return

	if CaneInput.is_use_just_pressed() and _try_retarget():
		return


func try_fire_hook() -> bool:
	if _player.unlocks == null or not _player.unlocks.cane_hook:
		return false
	if _state != HookState.IDLE:
		return false

	var aim := get_aim_direction()
	var best_point := find_best_hook_point(aim)
	if best_point == null:
		if _visual != null:
			_visual.flash_miss()
		return false

	_attach_to(best_point)
	if _visual != null:
		_visual.flash_action(1)
	return true


func release() -> void:
	if _state != HookState.ATTACHED:
		return
	_ensure_release_momentum()
	_last_hook_node = _hook_node
	_same_hook_cooldown_timer = same_hook_cooldown
	reset_state()


func release_for_dash() -> void:
	if _state != HookState.ATTACHED:
		return
	_last_hook_node = _hook_node
	_same_hook_cooldown_timer = same_hook_cooldown
	reset_state()


func release_with_jump() -> void:
	if _state != HookState.ATTACHED:
		return

	var preserved := _player.velocity
	_last_hook_node = _hook_node
	_same_hook_cooldown_timer = same_hook_cooldown
	reset_state()
	_player.velocity = preserved
	_player.velocity.y = minf(_player.velocity.y, _player.jump_velocity)
	_player.clear_jump_buffer()


func process(delta: float) -> void:
	if _same_hook_cooldown_timer > 0.0:
		_same_hook_cooldown_timer = maxf(_same_hook_cooldown_timer - delta, 0.0)

	if _state != HookState.ATTACHED:
		return

	if _hook_node != null and not _is_hook_point_available(_hook_node):
		release()
		return

	if detach_on_floor and _player.is_on_floor():
		release()
		return

	if _hook_node != null and is_instance_valid(_hook_node):
		_hook_point = _hook_node.global_position

	_apply_rope_physics(delta)


func _attach_to(node: Node2D) -> void:
	var wall: WallAbility = _player.get_node("WallAbility") as WallAbility
	if wall != null:
		wall.cancel_attachment()

	_hook_node = node
	_hook_point = node.global_position
	var distance := _player.global_position.distance_to(_hook_point)
	_rope_length = clampf(distance, min_rope_length, hook_range)
	_yank_timer = yank_duration
	_state = HookState.ATTACHED

	if attach_air_jump_refresh:
		_player.reset_air_jumps()


func _try_retarget() -> bool:
	var aim := get_aim_direction()
	var best_point := find_best_hook_point(aim)
	if best_point == null or best_point == _hook_node:
		return false

	var preserved := _player.velocity
	_attach_to(best_point)
	_player.velocity = preserved
	if _visual != null:
		_visual.flash_action(1)
	return true


func _apply_rope_physics(delta: float) -> void:
	var offset := _player.global_position - _hook_point
	var dist := offset.length()
	if dist < 0.001:
		return

	var radial := offset / dist
	var tangent := Vector2(-radial.y, radial.x)

	var gravity := _player.gravity_override * swing_gravity_scale
	if _player.velocity.y > 0.0:
		gravity *= _player.fall_gravity_multiplier
	_player.velocity.y += gravity * delta

	var input_x := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(input_x):
		_player.velocity += tangent * input_x * tangent_accel * delta

	if _yank_timer > 0.0:
		_yank_timer = maxf(_yank_timer - delta, 0.0)
		_player.velocity += (-radial) * yank_accel * delta

	if _yank_timer <= 0.0 and reel_speed > 0.0:
		_rope_length = move_toward(_rope_length, min_rope_length, reel_speed * delta)

	var speed := _player.velocity.length()
	if speed > max_swing_speed:
		_player.velocity = _player.velocity * (max_swing_speed / speed)

	offset = _player.global_position - _hook_point
	dist = offset.length()
	if dist > _rope_length:
		radial = offset / dist
		var radial_vel := _player.velocity.dot(radial)
		if radial_vel > 0.0:
			_player.velocity -= radial * radial_vel
		_player.global_position = _hook_point + radial * _rope_length


func _ensure_release_momentum() -> void:
	if _player.velocity.length() >= release_min_speed:
		return

	var direction := _player.velocity
	if direction.length_squared() < 1.0:
		var offset := _player.global_position - _hook_point
		if offset.length_squared() > 1.0:
			direction = Vector2(-offset.y, offset.x)
		else:
			direction = Vector2(_player.facing_direction, -0.45)
	direction = direction.normalized()
	_player.velocity = direction * release_min_speed


func _is_hook_point_available(node: Node2D) -> bool:
	var parent := node.get_parent()
	if parent is ShiftingBlock:
		return (parent as ShiftingBlock).is_touchable()
	return true
