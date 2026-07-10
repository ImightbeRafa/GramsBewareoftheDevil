class_name DashAbility
extends Node

@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.12
@export var dash_cooldown: float = 0.35

var _player: Player
var _dashing: bool = false
var _dash_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _air_dash_available: bool = true
var _dash_direction: Vector2 = Vector2.RIGHT


func setup(player: Player) -> void:
	_player = player


func reset_state() -> void:
	_dashing = false
	_dash_timer = 0.0
	_cooldown_timer = 0.0
	_air_dash_available = true


func is_dashing() -> bool:
	return _dashing


func process(delta: float) -> void:
	if _player.is_on_floor():
		_air_dash_available = true

	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)

	if _dashing:
		_dash_timer -= delta
		_player.velocity = _dash_direction * dash_speed
		if _dash_timer <= 0.0:
			_dashing = false
			_cooldown_timer = dash_cooldown
		return

	if _player.unlocks == null or not _player.unlocks.air_dash:
		return
	if _cooldown_timer > 0.0:
		return
	if not Input.is_action_just_pressed("dash"):
		return

	var can_ground_dash := _player.is_on_floor()
	var can_air_dash := not _player.is_on_floor() and _air_dash_available
	if not can_ground_dash and not can_air_dash:
		return

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length_squared() > 0.01:
		_dash_direction = input.normalized()
	else:
		_dash_direction = Vector2(_player.facing_direction, 0.0)

	_dashing = true
	_dash_timer = dash_duration
	if not _player.is_on_floor():
		_air_dash_available = false
