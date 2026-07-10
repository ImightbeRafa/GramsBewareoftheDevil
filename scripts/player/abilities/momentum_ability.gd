class_name MomentumAbility
extends Node

@export var momentum_threshold: float = 200.0
@export var friction_reduction: float = 0.45
@export var second_wind_multiplier: float = 1.35
@export var second_wind_duration: float = 0.4
@export var coast_delay: float = 0.15

var _player: Player
var _peak_speed: float = 0.0
var _no_input_timer: float = 0.0
var _second_wind_timer: float = 0.0
var _second_wind_active: bool = false


func setup(player: Player) -> void:
	_player = player


func reset_state() -> void:
	_peak_speed = 0.0
	_no_input_timer = 0.0
	_second_wind_timer = 0.0
	_second_wind_active = false


func is_second_wind_active() -> bool:
	return _second_wind_active


func get_friction_multiplier() -> float:
	if _player.unlocks == null or not _player.unlocks.momentum:
		return 1.0
	if _second_wind_active:
		return friction_reduction * 0.5
	if _peak_speed >= momentum_threshold and _no_input_timer < coast_delay:
		return friction_reduction
	return 1.0


func process(delta: float) -> void:
	if _player.unlocks == null or not _player.unlocks.momentum:
		return

	_peak_speed = maxf(_peak_speed, absf(_player.velocity.x))

	var input := Input.get_axis("move_left", "move_right")
	if is_zero_approx(input):
		_no_input_timer += delta
	else:
		_no_input_timer = 0.0

	if _second_wind_active:
		_second_wind_timer -= delta
		if _second_wind_timer <= 0.0:
			_second_wind_active = false
		return

	if Input.is_action_just_pressed("second_wind"):
		if _player.is_on_floor() and _peak_speed >= momentum_threshold:
			_second_wind_active = true
			_second_wind_timer = second_wind_duration
			var direction := signf(_player.velocity.x) if not is_zero_approx(_player.velocity.x) else _player.facing_direction
			_player.velocity.x = direction * _player.speed * second_wind_multiplier
