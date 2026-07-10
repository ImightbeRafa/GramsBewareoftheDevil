extends Node2D

const ALL_UNLOCKED: AbilityUnlocks = preload("res://resources/abilities/all_unlocked.tres")

@onready var _world_tiles: TileMapLayer = $WorldTiles
@onready var _objects: Node2D = $Objects
@onready var _spawn_point: Marker2D = $SpawnPoint
@onready var _player: Player = $Player
@onready var _kill_plane: Area2D = $KillPlane
@onready var _hint_label: Label = %HintLabel

var _hook_teleport: Vector2 = Vector2.ZERO
var _spawn: Vector2 = Vector2.ZERO


func _ready() -> void:
	if _player != null:
		_player.freeze()
	set_process_unhandled_input(true)
	call_deferred("_bootstrap_level")


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if _player == null:
		return
	match event.keycode:
		KEY_H:
			_teleport_to_hook()
		KEY_T:
			_teleport_to_spawn()


func _teleport_to_hook() -> void:
	if _hook_teleport == Vector2.ZERO:
		return
	_player.global_position = _hook_teleport
	_player.velocity = Vector2.ZERO
	print("Teleported to hook shaft — %s (T=back to start)" % _hook_teleport)


func _teleport_to_spawn() -> void:
	if _spawn == Vector2.ZERO:
		return
	_player.global_position = _spawn
	_player.velocity = Vector2.ZERO
	print("Teleported to start — %s" % _spawn)


func _bootstrap_level() -> void:
	if not is_inside_tree():
		return
	if _world_tiles == null or _player == null or _objects == null:
		push_error("Movement test bootstrap missing required nodes.")
		return

	await get_tree().process_frame

	var map_data: Dictionary = await MovementTestBuilder.build_async(_world_tiles, _objects)
	if map_data.is_empty():
		push_error("MovementTestBuilder failed — map_data is empty.")
		_player.unfreeze()
		return

	_spawn = map_data["spawn"]
	_hook_teleport = map_data.get("hook_teleport", Vector2.ZERO)
	_spawn_point.global_position = _spawn
	_player.global_position = _spawn

	var bounds: Rect2 = map_data["camera_bounds"]
	_player.configure_level_camera(bounds.position.x, bounds.position.y, bounds.end.x, bounds.end.y)
	_player.unlocks = ALL_UNLOCKED
	_player.max_air_jumps = 1
	_player.speed = 300.0
	_player.acceleration = 1350.0
	_player.friction = 1500.0
	_player.air_acceleration_multiplier = 0.7

	if _kill_plane != null:
		_kill_plane.position = Vector2(bounds.size.x * 0.5, bounds.end.y + 60.0)
		var shape := _kill_plane.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape != null and shape.shape is RectangleShape2D:
			(shape.shape as RectangleShape2D).size = Vector2(bounds.size.x + 200.0, 120.0)

	_add_teleport_button()

	await get_tree().process_frame
	_player.global_position = _spawn
	_player.unfreeze()

	print("Movement test loaded — spawn=%s · H=hook shaft · T=start" % _spawn)


func _add_teleport_button() -> void:
	var ui := get_node_or_null("UI") as CanvasLayer
	if ui == null:
		return
	if ui.get_node_or_null("HookTeleportButton") != null:
		return

	var button := Button.new()
	button.name = "HookTeleportButton"
	button.text = "Go to Hook Shaft (H)"
	button.position = Vector2(24, 52)
	button.custom_minimum_size = Vector2(200, 32)
	button.pressed.connect(_teleport_to_hook)
	ui.add_child(button)

	if _hint_label != null:
		_hint_label.text = (
			"Movement Test — H=hook shaft · T=start · Q=cane/hook · M=this · P/L/O switch"
		)
