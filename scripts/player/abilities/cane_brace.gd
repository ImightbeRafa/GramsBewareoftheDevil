class_name CaneBraceAbility
extends Node

@export var brace_friction_multiplier: float = 3.5
@export var min_brace_time: float = 0.35
@export var release_nudge_speed: float = 95.0
@export var careful_hop_multiplier: float = 0.55

var _player: Player
var _bracing: bool = false
var _brace_timer: float = 0.0
var _just_released: bool = false


func setup(player: Player) -> void:
	_player = player


func reset_state() -> void:
	_bracing = false
	_brace_timer = 0.0
	_just_released = false


func is_bracing() -> bool:
	return _bracing


func get_friction_multiplier() -> float:
	if _bracing:
		return brace_friction_multiplier
	return 1.0


func should_use_careful_hop() -> bool:
	return _bracing and _player.is_on_floor()


func get_careful_hop_velocity() -> float:
	return _player.jump_velocity * careful_hop_multiplier


func process(delta: float) -> void:
	if _player == null or _player.unlocks == null or not _player.unlocks.cane_brace:
		_bracing = false
		return

	if Input.is_action_pressed("brace") and _player.is_on_floor() and not _player.is_dashing():
		_bracing = true
		_brace_timer += delta
		_player.velocity.x = move_toward(_player.velocity.x, 0.0, 1800.0 * delta)
		return

	if _bracing and Input.is_action_just_released("brace"):
		if _brace_timer >= min_brace_time:
			_player.velocity.x = _player.facing_direction * release_nudge_speed
			_just_released = true
		_bracing = false
		_brace_timer = 0.0
		return

	_bracing = false
	_brace_timer = 0.0


func consume_careful_hop() -> bool:
	if not should_use_careful_hop():
		return false
	_bracing = false
	_brace_timer = 0.0
	return true
