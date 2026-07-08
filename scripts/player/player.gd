class_name Player
extends CharacterBody2D

@export var speed: float = 260.0
@export var acceleration: float = 2000.0
@export var friction: float = 1800.0
@export var air_acceleration_multiplier: float = 0.7
@export var jump_velocity: float = -420.0
@export var gravity_override: float = 1100.0
@export var fall_gravity_multiplier: float = 1.5
@export var jump_cut_multiplier: float = 0.45
@export var coyote_time: float = 0.11
@export var jump_buffer_time: float = 0.11
@export var max_air_jumps: int = 2
@export var max_fall_speed: float = 700.0
@export var death_restart_delay: float = 0.55

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _air_jumps_remaining: int = 0
var _facing_direction: float = 1.0
var _spawn_position: Vector2 = Vector2.ZERO
var _frozen: bool = false
var _dying: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	var spawn_point := get_tree().get_first_node_in_group("spawn_point") as Node2D
	if spawn_point != null:
		global_position = spawn_point.global_position
	_spawn_position = global_position


func freeze() -> void:
	_frozen = true
	velocity = Vector2.ZERO
	_sprite.play("idle")


func die() -> void:
	if _dying or _frozen:
		return
	_dying = true
	velocity = Vector2.ZERO
	_sprite.play("death")
	_sprite.modulate = Color(1.0, 0.45, 0.45)
	await get_tree().create_timer(death_restart_delay).timeout
	var controller: Node = get_tree().get_first_node_in_group("level_controller")
	if controller != null and controller.has_method("restart_level"):
		controller.restart_level()
	else:
		get_tree().reload_current_scene()


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
	_apply_gravity(delta)
	_apply_horizontal_movement(delta)
	_handle_jump()
	_limit_fall_speed()
	_update_facing()
	_update_animation()
	move_and_slide()


func respawn() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_air_jumps_remaining = 0
	_dying = false
	_sprite.modulate = Color.WHITE


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
		_air_jumps_remaining = max_air_jumps
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
	var input_direction := Input.get_axis("move_left", "move_right")
	var target_speed := input_direction * speed
	var accel := acceleration if is_on_floor() else acceleration * air_acceleration_multiplier

	if not is_zero_approx(input_direction):
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		var decel := friction if is_on_floor() else friction * air_acceleration_multiplier
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)


func _handle_jump() -> void:
	if _jump_buffer_timer <= 0.0:
		if Input.is_action_just_released("jump") and velocity.y < 0.0:
			velocity.y *= jump_cut_multiplier
		return

	var grounded_jump := is_on_floor() or _coyote_timer > 0.0
	if grounded_jump:
		velocity.y = jump_velocity
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
	elif _air_jumps_remaining > 0:
		velocity.y = jump_velocity
		_air_jumps_remaining -= 1
		_jump_buffer_timer = 0.0

	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier


func _limit_fall_speed() -> void:
	velocity.y = minf(velocity.y, max_fall_speed)


func _update_facing() -> void:
	if not is_zero_approx(velocity.x):
		_facing_direction = signf(velocity.x)

	_sprite.flip_h = _facing_direction < 0.0


func _update_animation() -> void:
	if not is_on_floor():
		if velocity.y < 0.0:
			_sprite.play("jump")
		else:
			_sprite.play("fall")
	elif absf(velocity.x) > 20.0:
		_sprite.play("run")
	else:
		_sprite.play("idle")
