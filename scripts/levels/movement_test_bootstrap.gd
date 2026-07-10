extends Node2D

const ALL_UNLOCKED: AbilityUnlocks = preload("res://resources/abilities/all_unlocked.tres")

@onready var _world_tiles: TileMapLayer = $WorldTiles
@onready var _objects: Node2D = $Objects
@onready var _spawn_point: Marker2D = $SpawnPoint
@onready var _player: Player = $Player
@onready var _kill_plane: Area2D = $KillPlane


func _ready() -> void:
	if _player != null:
		_player.freeze()
	call_deferred("_bootstrap_level")


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

	var spawn: Vector2 = map_data["spawn"]
	_spawn_point.global_position = spawn
	_player.global_position = spawn

	var bounds: Rect2 = map_data["camera_bounds"]
	_player.configure_level_camera(bounds.position.x, bounds.position.y, bounds.end.x, bounds.end.y)
	_player.unlocks = ALL_UNLOCKED
	_player.max_air_jumps = 1
	_player.speed = 200.0
	_player.acceleration = 900.0
	_player.friction = 1000.0
	_player.air_acceleration_multiplier = 0.7

	if _kill_plane != null:
		_kill_plane.position = Vector2(bounds.size.x * 0.5, bounds.end.y + 60.0)
		var shape := _kill_plane.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape != null and shape.shape is RectangleShape2D:
			(shape.shape as RectangleShape2D).size = Vector2(bounds.size.x + 200.0, 120.0)

	await get_tree().process_frame
	_player.global_position = spawn
	_player.unfreeze()

	print("Movement test loaded — spawn=%s" % spawn)
