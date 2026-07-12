class_name CrouchAbility
extends Node

const STAND_SIZE := Vector2(30.0, 42.0)
const STAND_OFFSET := Vector2(0.0, -21.0)
const CROUCH_SIZE := Vector2(30.0, 22.0)
const CROUCH_OFFSET := Vector2(0.0, -11.0)

@export var crouch_speed: float = 140.0
@export var slide_speed: float = 480.0
@export var slide_duration: float = 0.40
@export var slide_friction: float = 2400.0
@export var slide_cooldown: float = 0.35

var _player: Player
var _collision: CollisionShape2D
var _shape: RectangleShape2D
var _stand_probe: RectangleShape2D
var _sprite: AnimatedSprite2D
var _crouch_visual: CrouchVisual
var _crouching: bool = false
var _sliding: bool = false
var _slide_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _sprite_stand_y: float = -36.0
var _sprite_stand_scale: Vector2 = Vector2(1.5, 1.5)


func setup(
	player: Player,
	collision: CollisionShape2D,
	sprite: AnimatedSprite2D,
	crouch_visual: CrouchVisual = null
) -> void:
	_player = player
	_collision = collision
	_shape = collision.shape as RectangleShape2D
	_sprite = sprite
	_crouch_visual = crouch_visual
	_stand_probe = RectangleShape2D.new()
	_stand_probe.size = STAND_SIZE
	_apply_standing_collision()
	_sync_visual()


func cancel_slide() -> void:
	if not _sliding:
		return
	_sliding = false
	_slide_timer = 0.0
	_sync_visual()


func try_stand() -> void:
	_try_stand()


func reset_state() -> void:
	_sliding = false
	_slide_timer = 0.0
	_cooldown_timer = 0.0
	_crouching = false
	_apply_standing_collision()
	_sync_visual()


func is_crouching() -> bool:
	return _crouching or _sliding


func is_sliding() -> bool:
	return _sliding


func get_move_speed() -> float:
	if _sliding:
		return slide_speed
	if _crouching:
		return crouch_speed
	return _player.speed


func blocks_cane_use() -> bool:
	return _crouching or _sliding


func process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer = maxf(_cooldown_timer - delta, 0.0)

	if _sliding:
		_process_slide(delta)
		_sync_visual()
		return

	if not _can_use_crouch():
		if _crouching:
			_try_stand()
		_sync_visual()
		return

	if Input.is_action_pressed("move_down"):
		_enter_crouch()
	elif _crouching:
		_try_stand()

	if _crouching and Input.is_action_just_pressed("dash") and _cooldown_timer <= 0.0:
		_start_slide()

	_sync_visual()


func _can_use_crouch() -> bool:
	if not _player.is_on_floor():
		return false
	if _player.is_dashing() or _player.is_hooking():
		return false
	if _player.is_bracing():
		return false
	if _player.is_climbing():
		return false
	if _player.is_near_ladder() and _player.wants_ladder_climb():
		return false
	return true


func _enter_crouch() -> void:
	_crouching = true
	_apply_crouch_collision()


func _try_stand() -> void:
	if not _can_stand():
		return
	_crouching = false
	_apply_standing_collision()


func _start_slide() -> void:
	_sliding = true
	_slide_timer = slide_duration
	_crouching = true
	_apply_crouch_collision()
	var direction := Input.get_axis("move_left", "move_right")
	if is_zero_approx(direction):
		direction = _player.facing_direction
	_player.velocity.x = direction * slide_speed


func _process_slide(delta: float) -> void:
	_slide_timer -= delta
	_apply_crouch_collision()

	var direction := signf(_player.velocity.x)
	if is_zero_approx(direction):
		direction = _player.facing_direction

	if _slide_timer > 0.0:
		_player.velocity.x = direction * slide_speed
	else:
		_sliding = false
		_cooldown_timer = slide_cooldown
		_player.velocity.x = move_toward(_player.velocity.x, 0.0, slide_friction * delta)
		if not Input.is_action_pressed("move_down"):
			_try_stand()


func _can_stand() -> bool:
	var space := _player.get_world_2d().direct_space_state
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = _stand_probe
	params.transform = _player.global_transform.translated(STAND_OFFSET)
	params.collision_mask = _player.collision_mask
	params.exclude = [_player.get_rid()]
	return space.intersect_shape(params, 1).is_empty()


func _apply_standing_collision() -> void:
	if _shape == null or _collision == null:
		return
	_shape.size = STAND_SIZE
	_collision.position = STAND_OFFSET


func _apply_crouch_collision() -> void:
	if _shape == null or _collision == null:
		return
	_shape.size = CROUCH_SIZE
	_collision.position = CROUCH_OFFSET


func _sync_visual() -> void:
	if _sprite == null:
		return

	var active := _crouching or _sliding
	if _crouch_visual != null:
		_crouch_visual.set_state(active, _sliding, _player.facing_direction)

	if active:
		_sprite.visible = false
		return

	_sprite.visible = true
	_sprite.position.y = _sprite_stand_y
	_sprite.scale = _sprite_stand_scale
