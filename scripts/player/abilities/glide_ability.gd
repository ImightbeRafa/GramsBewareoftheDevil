class_name GlideAbility
extends Node

@export var glide_fall_speed: float = 75.0
@export var glide_horizontal_boost: float = 50.0
@export var glide_gravity: float = 180.0
@export var glide_fall_threshold: float = 8.0

var _player: Player
var _gliding: bool = false


func setup(player: Player) -> void:
	_player = player


func reset_state() -> void:
	_gliding = false


func is_gliding() -> bool:
	return _gliding


func process(delta: float) -> void:
	_gliding = false
	if _player.unlocks == null or not _player.unlocks.glide:
		return
	if _player.is_on_floor() or _player.is_dashing() or _player.is_hooking():
		return
	if _player.is_ladder_climbing():
		return
	if _player.is_near_ladder() and _player.wants_ladder_climb():
		return
	if _player.is_touching_wall():
		return
	if not Input.is_action_pressed("jump"):
		return
	if _player.velocity.y < glide_fall_threshold:
		return

	_gliding = true
	_player.velocity.y = move_toward(_player.velocity.y, glide_fall_speed, glide_gravity * delta)
	if _player.velocity.y < glide_fall_speed * 0.25:
		_player.velocity.y += glide_gravity * delta

	var input := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(input):
		_player.velocity.x += input * glide_horizontal_boost * delta
