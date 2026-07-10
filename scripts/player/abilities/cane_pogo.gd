class_name CanePogo
extends Node

@export var pogo_bounce_velocity: float = -460.0
@export var pogo_iframe_time: float = 0.15
@export var pogo_ray_length: float = 102.0
@export var pogo_aim_min_down: float = 0.28
@export var pogo_horizontal_carry: float = 110.0
@export var pogo_tip_offset: float = 33.0

var _player: Player
var _cane_tip: Area2D
var _iframe_timer: float = 0.0
var _visual: CaneVisual


func setup(player: Player, cane_tip: Area2D, visual: CaneVisual = null) -> void:
	_player = player
	_cane_tip = cane_tip
	_visual = visual
	_cane_tip.body_entered.connect(_on_body_entered)
	_cane_tip.area_entered.connect(_on_area_entered)


func reset_state() -> void:
	_iframe_timer = 0.0
	_cane_tip.monitoring = false
	_player.set_pogo_iframe(false)


func process(delta: float) -> void:
	if _iframe_timer > 0.0:
		_iframe_timer = maxf(_iframe_timer - delta, 0.0)
		if _iframe_timer <= 0.0:
			_player.set_pogo_iframe(false)

	_cane_tip.monitoring = false
	if _player.unlocks == null or not _player.unlocks.cane_pogo:
		return
	if _player.cane_mode != 0:
		return
	if _player.is_on_floor() or _player.is_dashing() or _player.is_hooking():
		return

	var use_pressed := CaneInput.is_use_pressed()
	var use_clicked := CaneInput.is_use_just_pressed()
	if not use_pressed and not use_clicked:
		return

	if use_clicked:
		if _try_raycast_pogo():
			return

	if not use_pressed:
		return

	_cane_tip.monitoring = true
	var aim := _get_pogo_aim()
	_cane_tip.position = aim * pogo_tip_offset


func is_pogo_iframe_active() -> bool:
	return _iframe_timer > 0.0


func get_pogo_aim() -> Vector2:
	return _get_pogo_aim()


func is_pogo_aim_valid() -> bool:
	var aim := _get_pogo_aim()
	var raw := _player.get_global_mouse_position() - _player.global_position
	if raw.length_squared() < 16.0:
		return true
	return raw.normalized().y >= pogo_aim_min_down


func _get_pogo_aim() -> Vector2:
	var raw := _player.get_global_mouse_position() - _player.global_position
	if raw.length_squared() < 16.0:
		return Vector2(0.0, 1.0)
	var dir := raw.normalized()
	if dir.y < pogo_aim_min_down:
		dir = Vector2(dir.x, pogo_aim_min_down).normalized()
	return dir


func _try_raycast_pogo() -> bool:
	var space := _player.get_world_2d().direct_space_state
	var aim := _get_pogo_aim()
	var from := _player.global_position + Vector2(0.0, 6.0)
	var to := from + aim * pogo_ray_length
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 29
	query.exclude = [_player.get_rid()]

	var result := space.intersect_ray(query)
	if result.is_empty():
		return false

	var collider: Object = result.get("collider")
	if collider == null:
		return false

	var body := _resolve_body(collider)
	if body == null or body == _player:
		return false
	if not _is_pogo_surface(body):
		return false

	_bounce(aim)
	if body.has_method("on_pogo_hit"):
		body.on_pogo_hit()
	if _visual != null:
		_visual.flash_action(0)
	return true


func _resolve_body(collider: Object) -> Node:
	if collider is Node:
		var node := collider as Node
		if node is StaticBody2D or node is AnimatableBody2D or node is TileMapLayer:
			return node
		if node.get_parent() is StaticBody2D or node.get_parent() is AnimatableBody2D:
			return node.get_parent()
	return null


func _is_pogo_surface(body: Node) -> bool:
	if body.is_in_group("pogo_target") or body.is_in_group("pogo_surface"):
		return true
	if body is ShiftingBlock:
		return (body as ShiftingBlock).is_touchable()
	if body is StaticBody2D or body is AnimatableBody2D or body is TileMapLayer:
		return true
	return false


func _bounce(aim: Vector2) -> void:
	_player.velocity.y = pogo_bounce_velocity
	_player.velocity.x += aim.x * pogo_horizontal_carry
	_iframe_timer = pogo_iframe_time
	_player.set_pogo_iframe(true)


func _on_body_entered(body: Node2D) -> void:
	if not _cane_tip.monitoring or body == _player or _iframe_timer > 0.0:
		return
	if _is_pogo_surface(body):
		_bounce(_get_pogo_aim())
		if body.has_method("on_pogo_hit"):
			body.on_pogo_hit()
		if _visual != null:
			_visual.flash_action(0)


func _on_area_entered(area: Area2D) -> void:
	if not _cane_tip.monitoring or _iframe_timer > 0.0:
		return
	var body := area.get_parent()
	if body != null and _is_pogo_surface(body):
		_bounce(_get_pogo_aim())
		if body.has_method("on_pogo_hit"):
			body.on_pogo_hit()
		if _visual != null:
			_visual.flash_action(0)
