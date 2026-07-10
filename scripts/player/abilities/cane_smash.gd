class_name CaneSmash
extends Node

@export var charge_time: float = 0.35
@export var hitbox_duration: float = 0.15
@export var smash_knockback: float = 350.0
@export var smash_range: float = 28.0

var _player: Player
var _hitbox: Area2D
var _visual: CaneVisual
var _charging: bool = false
var _charge_timer: float = 0.0
var _hitbox_timer: float = 0.0
var _charged: bool = false


func setup(player: Player, hitbox: Area2D, visual: CaneVisual = null) -> void:
	_player = player
	_hitbox = hitbox
	_visual = visual
	_hitbox.body_entered.connect(_on_body_entered)
	_hitbox.area_entered.connect(_on_area_entered)


func reset_state() -> void:
	_charging = false
	_charge_timer = 0.0
	_hitbox_timer = 0.0
	_charged = false
	_hitbox.monitoring = false


func is_charging() -> bool:
	return _charging


func get_aim_direction() -> Vector2:
	var mouse_pos := _player.get_global_mouse_position()
	var direction := mouse_pos - _player.global_position
	if direction.length_squared() < 16.0:
		return Vector2(_player.facing_direction, 0.0).normalized()
	return direction.normalized()


func process(delta: float) -> void:
	_hitbox.monitoring = _hitbox_timer > 0.0
	if _hitbox_timer > 0.0:
		_hitbox_timer = maxf(_hitbox_timer - delta, 0.0)

	if _player.unlocks == null or not _player.unlocks.cane_smash:
		return
	if _player.cane_mode != 2:
		return
	if _hitbox_timer > 0.0:
		return

	if CaneInput.is_use_just_pressed():
		_charging = true
		_charge_timer = 0.0
		_charged = false

	if _charging:
		if CaneInput.is_use_pressed():
			_charge_timer += delta
			if _charge_timer >= charge_time:
				_charged = true
		else:
			_fire_smash()
			_charging = false


func _fire_smash() -> void:
	var direction := get_aim_direction()
	_hitbox.position = direction * smash_range + Vector2(0.0, -6.0)
	_hitbox.monitoring = true
	_hitbox_timer = hitbox_duration
	if _visual != null:
		_visual.flash_action(2)
	if _charged:
		_player.velocity += direction * smash_knockback * 0.35


func _on_body_entered(body: Node2D) -> void:
	if body == _player:
		return
	if body.is_in_group("crumble_block"):
		if body.has_method("on_smash_hit"):
			body.on_smash_hit()
	elif body.is_in_group("pogo_target"):
		if body.has_method("on_smash_hit"):
			body.on_smash_hit()


func _on_area_entered(area: Area2D) -> void:
	var body := area.get_parent()
	if body != null and body.is_in_group("crumble_block"):
		if body.has_method("on_smash_hit"):
			body.on_smash_hit()
