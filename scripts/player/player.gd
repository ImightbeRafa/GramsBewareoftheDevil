class_name Player
extends CharacterBody2D

@export var speed: float = 330.0
@export var acceleration: float = 1500.0
@export var friction: float = 1600.0
@export var air_acceleration_multiplier: float = 0.7
@export var jump_velocity: float = -555.0
@export var gravity_override: float = 1100.0
@export var fall_gravity_multiplier: float = 1.65
@export var jump_cut_multiplier: float = 0.42
@export var coyote_time: float = 0.13
@export var jump_buffer_time: float = 0.13
@export var max_air_jumps: int = 1
@export var max_fall_speed: float = 850.0
@export var death_restart_delay: float = 0.55
@export var unlocks: AbilityUnlocks

var facing_direction: float = 1.0
var cane_mode: int = 0
var checkpoint_id: int = -1

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _air_jumps_remaining: int = 0
var _spawn_position: Vector2 = Vector2.ZERO
var _checkpoint_position: Vector2 = Vector2.ZERO
var _frozen: bool = false
var _dying: bool = false
var _was_on_floor: bool = false
var _pre_move_velocity_y: float = 0.0
var _pogo_iframe_active: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _camera: GameCamera = $Camera2D
@onready var _wall_ability: WallAbility = $WallAbility
@onready var _dash_ability: DashAbility = $DashAbility
@onready var _glide_ability: GlideAbility = $GlideAbility
@onready var _momentum_ability: MomentumAbility = $MomentumAbility
@onready var _cane_controller: CaneController = $CaneController
@onready var _cane_pogo: CanePogo = $CanePogo
@onready var _cane_hook: CaneHook = $CaneHook
@onready var _cane_smash: CaneSmash = $CaneSmash
@onready var _cane_visual: CaneVisual = $CaneVisual
@onready var _cane_tip: Area2D = $CaneTip
@onready var _smash_hitbox: Area2D = $SmashHitbox
@onready var _cane_brace: CaneBraceAbility = $CaneBrace
@onready var _crouch_ability: CrouchAbility = $CrouchAbility
@onready var _body_collision: CollisionShape2D = $CollisionShape2D
@onready var _crouch_visual: CrouchVisual = $CrouchVisual

var _toxic_active: bool = false


func _ready() -> void:
	_wall_ability.setup(self)
	_dash_ability.setup(self)
	_glide_ability.setup(self)
	_momentum_ability.setup(self)
	_cane_visual.setup(self, _cane_smash, _cane_hook, _cane_pogo)
	_cane_pogo.setup(self, _cane_tip, _cane_visual)
	_cane_hook.setup(self, _cane_visual)
	_cane_smash.setup(self, _smash_hitbox, _cane_visual)
	_cane_controller.setup(self, _cane_pogo, _cane_hook, _cane_smash, _cane_visual)
	_cane_brace.setup(self)
	_crouch_ability.setup(self, _body_collision, _sprite, _crouch_visual)

	var spawn_point := get_tree().get_first_node_in_group("spawn_point") as Node2D
	if spawn_point != null:
		global_position = spawn_point.global_position
	_spawn_position = global_position
	_checkpoint_position = global_position


func freeze() -> void:
	_frozen = true
	velocity = Vector2.ZERO
	_sprite.play("idle")


func unfreeze() -> void:
	_frozen = false


func die() -> void:
	if _dying or _frozen:
		return
	_crouch_ability.reset_state()
	_dying = true
	velocity = Vector2.ZERO
	_sprite.play("death")
	_sprite.modulate = Color(1.0, 0.45, 0.45)
	await get_tree().create_timer(death_restart_delay).timeout
	if checkpoint_id >= 0:
		respawn()
		return
	var controller: Node = get_tree().get_first_node_in_group("level_controller")
	if controller != null and controller.has_method("restart_level"):
		controller.restart_level()
	else:
		get_tree().reload_current_scene()


func respawn() -> void:
	global_position = _checkpoint_position if checkpoint_id >= 0 else _spawn_position
	velocity = Vector2.ZERO
	_reset_ability_state()
	_dying = false
	_sprite.modulate = Color.WHITE
	_sprite.play("idle")


func set_checkpoint(position: Vector2, id: int) -> void:
	if id <= checkpoint_id:
		return
	checkpoint_id = id
	_checkpoint_position = position


func reset_air_jumps() -> void:
	if unlocks != null and unlocks.double_jump:
		_air_jumps_remaining = max_air_jumps


func is_dashing() -> bool:
	return _dash_ability.is_dashing()


func is_gliding() -> bool:
	return _glide_ability.is_gliding()


func is_pogo_iframe_active() -> bool:
	return _pogo_iframe_active


func set_pogo_iframe(active: bool) -> void:
	_pogo_iframe_active = active


func is_hooking() -> bool:
	return _cane_hook.is_hooking()


func is_bracing() -> bool:
	return _cane_brace.is_bracing()


func is_crouching() -> bool:
	return _crouch_ability.is_crouching()


func is_sliding() -> bool:
	return _crouch_ability.is_sliding()


func is_climbing() -> bool:
	return _wall_ability.is_climbing()


func apply_toxic(active: bool) -> void:
	_toxic_active = active
	if active:
		_sprite.modulate = Color(0.75, 1.0, 0.75, 1.0)
	elif not _dying:
		_sprite.modulate = Color.WHITE


func is_touching_wall() -> bool:
	return _wall_ability.is_on_wall_for_ability()


func configure_level_camera(left: float, top: float, right: float, bottom: float) -> void:
	_camera.set_level_bounds(left, top, right, bottom)


func clear_jump_buffer() -> void:
	_jump_buffer_timer = 0.0


func _physics_process(delta: float) -> void:
	if _dying:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if _frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_timers(delta)
	_wall_ability.process_timers(delta)
	_crouch_ability.process(delta)
	_dash_ability.process(delta)
	_cane_controller.process(delta)

	if is_hooking():
		_update_facing()
		_update_animation()
		move_and_slide()
		return

	if not is_dashing() and not is_hooking():
		_wall_ability.process_pre_move(delta)
		_wall_ability.process_climb(delta)
		var on_wall := _wall_ability.is_attached_to_wall()
		_glide_ability.process(delta)
		if not _glide_ability.is_gliding() and not on_wall:
			_apply_gravity(delta)
		_apply_horizontal_movement(delta)
		_wall_ability.apply_wall_stick(delta)
		_handle_jump()

	_limit_fall_speed()
	_update_facing()
	_update_animation()
	_pre_move_velocity_y = velocity.y
	move_and_slide()
	_update_landing_dip()


func _reset_ability_state() -> void:
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_air_jumps_remaining = 0
	_wall_ability.reset_state()
	_dash_ability.reset_state()
	_glide_ability.reset_state()
	_momentum_ability.reset_state()
	_cane_controller.reset_state()
	_cane_brace.reset_state()
	_crouch_ability.reset_state()
	cane_mode = 0
	_pogo_iframe_active = false
	_toxic_active = false


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
		reset_air_jumps()
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0
		return

	var gravity_scale := 1.0
	if velocity.y > 0.0:
		gravity_scale = fall_gravity_multiplier

	velocity.y += gravity_override * gravity_scale * delta


func _apply_horizontal_movement(delta: float) -> void:
	if is_sliding():
		return

	var input_direction := Input.get_axis("move_left", "move_right")
	input_direction = _wall_ability.filter_horizontal_input(input_direction)
	var move_speed: float = _crouch_ability.get_move_speed() if is_crouching() else speed
	var target_speed: float = input_direction * move_speed
	var accel := acceleration if is_on_floor() else acceleration * air_acceleration_multiplier
	var friction_mult := _momentum_ability.get_friction_multiplier() * _cane_brace.get_friction_multiplier()

	if not is_zero_approx(input_direction):
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		var decel := friction * friction_mult if is_on_floor() else friction * air_acceleration_multiplier * friction_mult
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

	_momentum_ability.process(delta)
	_cane_brace.process(delta)


func _handle_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		if Input.is_action_just_released("jump") and velocity.y < 0.0:
			velocity.y *= jump_cut_multiplier
		return

	if is_sliding():
		_crouch_ability.cancel_slide()
	if is_crouching():
		_crouch_ability.try_stand()
		if is_crouching():
			return

	if _cane_brace.consume_careful_hop():
		velocity.y = _cane_brace.get_careful_hop_velocity()
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
		return

	if _wall_ability.try_wall_jump():
		_jump_buffer_timer = 0.0
		return

	if _wall_ability.should_consume_jump_for_climb():
		_jump_buffer_timer = 0.0
		return

	var grounded_jump := is_on_floor() or _coyote_timer > 0.0
	if grounded_jump:
		velocity.y = jump_velocity
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
	elif unlocks != null and unlocks.double_jump and _air_jumps_remaining > 0:
		velocity.y = jump_velocity
		_air_jumps_remaining -= 1
		_jump_buffer_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier


func _limit_fall_speed() -> void:
	if is_gliding():
		return
	velocity.y = minf(velocity.y, max_fall_speed)


func _update_facing() -> void:
	if not is_zero_approx(velocity.x):
		facing_direction = signf(velocity.x)
	_sprite.flip_h = facing_direction < 0.0


func _update_animation() -> void:
	if is_crouching() or is_sliding():
		return
	if _wall_ability.is_climbing():
		_sprite.play("jump")
		return
	if _wall_ability.is_wall_sliding():
		_sprite.play("fall")
		return
	if is_gliding():
		_sprite.play("fall")
		return
	if not is_on_floor():
		if velocity.y < 0.0:
			_sprite.play("jump")
		else:
			_sprite.play("fall")
	elif absf(velocity.x) > 12.0:
		_sprite.play("run")
	else:
		_sprite.play("idle")


func _update_landing_dip() -> void:
	var on_floor := is_on_floor()
	if on_floor and not _was_on_floor and _pre_move_velocity_y > 180.0:
		_camera.trigger_landing_dip(_pre_move_velocity_y)
	_was_on_floor = on_floor
