class_name WallAbility
extends Node

@export var wall_slide_speed: float = 78.0
@export var wall_slide_accel: float = 520.0
@export var wall_jump_push: float = 340.0
@export var wall_jump_vertical: float = -450.0
@export var climb_speed: float = 170.0
@export var climb_accel: float = 900.0
@export var wall_stick_speed: float = 35.0
@export var wall_stick_accel: float = 480.0
@export var wall_coyote_time: float = 0.14
@export var wall_jump_buffer_time: float = 0.12

var _player: Player
var _wall_coyote_timer: float = 0.0
var _last_wall_normal_x: float = 0.0
var _is_climbing: bool = false
var _is_wall_sliding: bool = false
var _wall_jump_buffer: float = 0.0


func setup(player: Player) -> void:
	_player = player


func reset_state() -> void:
	_wall_coyote_timer = 0.0
	_last_wall_normal_x = 0.0
	_is_climbing = false
	_is_wall_sliding = false
	_wall_jump_buffer = 0.0


func cancel_attachment() -> void:
	_is_climbing = false
	_is_wall_sliding = false
	_wall_coyote_timer = 0.0


func get_wall_normal_x() -> float:
	if _player.is_on_wall():
		return _player.get_wall_normal().x
	if _wall_coyote_timer > 0.0 and not is_zero_approx(_last_wall_normal_x):
		return _last_wall_normal_x
	return 0.0


func is_on_wall_for_ability() -> bool:
	return _player.is_on_wall() or _wall_coyote_timer > 0.0


func is_climbing() -> bool:
	return _is_climbing


func is_wall_sliding() -> bool:
	return _is_wall_sliding


func is_attached_to_wall() -> bool:
	return _is_climbing or _is_wall_sliding


func filter_horizontal_input(input_direction: float) -> float:
	if not is_attached_to_wall() or not is_on_wall_for_ability():
		return input_direction

	var wall_normal_x := get_wall_normal_x()
	if is_zero_approx(wall_normal_x):
		return input_direction

	if signf(input_direction) == signf(wall_normal_x):
		return 0.0
	return input_direction


func process_timers(delta: float) -> void:
	if _player.is_on_wall():
		_wall_coyote_timer = wall_coyote_time
		_last_wall_normal_x = _player.get_wall_normal().x
	else:
		_wall_coyote_timer = maxf(_wall_coyote_timer - delta, 0.0)

	_wall_jump_buffer = maxf(_wall_jump_buffer - delta, 0.0)

	if is_on_wall_for_ability() and Input.is_action_just_pressed("jump"):
		_wall_jump_buffer = wall_jump_buffer_time


func process_pre_move(delta: float) -> void:
	_is_wall_sliding = false
	if _player.unlocks == null or not _player.unlocks.wall_slide:
		return
	if not is_on_wall_for_ability() or _player.is_on_floor():
		return
	if _player.is_dashing() or _is_climbing:
		return

	var wall_normal_x := get_wall_normal_x()
	if is_zero_approx(wall_normal_x):
		return

	if _player.velocity.y > -40.0:
		_is_wall_sliding = true
		_player.velocity.y = move_toward(
			_player.velocity.y,
			wall_slide_speed,
			wall_slide_accel * delta
		)


func process_climb(delta: float) -> void:
	_is_climbing = false
	if _player.unlocks == null or not _player.unlocks.wall_climb:
		return
	if not is_on_wall_for_ability() or _player.is_on_floor():
		return
	if _player.is_dashing():
		return

	if Input.is_action_pressed("move_up"):
		_is_climbing = true
		_player.velocity.y = move_toward(
			_player.velocity.y,
			-climb_speed,
			climb_accel * delta
		)


func apply_wall_stick(delta: float) -> void:
	if not is_attached_to_wall() or not is_on_wall_for_ability() or _player.is_on_floor():
		return

	var wall_normal_x := get_wall_normal_x()
	if is_zero_approx(wall_normal_x):
		return

	var into_wall := -signf(wall_normal_x)
	_player.velocity.x = move_toward(
		_player.velocity.x,
		into_wall * wall_stick_speed,
		wall_stick_accel * delta
	)


func should_consume_jump_for_climb() -> bool:
	return false


func try_wall_jump() -> bool:
	if _player.unlocks == null or not _player.unlocks.wall_jump:
		return false
	if not is_on_wall_for_ability() or _player.is_on_floor():
		return false

	var wall_normal_x := get_wall_normal_x()
	if is_zero_approx(wall_normal_x):
		return false

	var horizontal_input := Input.get_axis("move_left", "move_right")
	var horizontal_push: float
	if not is_zero_approx(horizontal_input):
		horizontal_push = horizontal_input * wall_jump_push
	else:
		horizontal_push = wall_normal_x * wall_jump_push

	_player.velocity = Vector2(horizontal_push, wall_jump_vertical)
	_wall_coyote_timer = 0.0
	_is_climbing = false
	_is_wall_sliding = false
	_wall_jump_buffer = 0.0
	_player.reset_air_jumps()
	return true
