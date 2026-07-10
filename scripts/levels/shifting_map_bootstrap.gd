extends Node2D

const ALL_UNLOCKED: AbilityUnlocks = preload("res://resources/abilities/all_unlocked.tres")

@onready var _safe_tiles: TileMapLayer = $SafeTiles
@onready var _shifting_root: Node2D = $ShiftingRoot
@onready var _objects: Node2D = $Objects
@onready var _spawn_point: Marker2D = $SpawnPoint
@onready var _player: Player = $Player
@onready var _kill_plane: Area2D = $KillPlane
@onready var _lava_visual: ColorRect = $LavaVisual
@onready var _controller: ShiftingMapController = $ShiftingMapController


func _ready() -> void:
	if _player != null:
		_player.freeze()
	call_deferred("_bootstrap_level")


func _bootstrap_level() -> void:
	if not is_inside_tree():
		return
	if _safe_tiles == null or _player == null or _objects == null or _controller == null:
		push_error("Shifting map bootstrap missing required nodes.")
		return

	await get_tree().process_frame

	var map_data: Dictionary = await ShiftingMapBuilder.build_async(
		_safe_tiles,
		_shifting_root,
		_objects,
		_controller
	)
	if map_data.is_empty():
		push_error("ShiftingMapBuilder failed — map_data is empty.")
		_player.unfreeze()
		return

	var spawn: Vector2 = map_data["spawn"]
	_spawn_point.global_position = spawn
	_player.global_position = spawn

	var bounds: Rect2 = map_data["camera_bounds"]
	_player.configure_level_camera(bounds.position.x, bounds.position.y, bounds.end.x, bounds.end.y)
	_apply_full_kit_tuning(_player)

	var lava_y: float = map_data.get("lava_y", bounds.end.y)
	if _kill_plane != null:
		_kill_plane.position = Vector2(bounds.size.x * 0.5, lava_y + 80.0)
	if _lava_visual != null:
		_lava_visual.position = Vector2(-32.0, lava_y)
		_lava_visual.size = Vector2(bounds.size.x + 64.0, 120.0)

	await get_tree().process_frame
	_player.global_position = spawn
	_player.unfreeze()

	print("Shifting map loaded — spawn=%s layout=%d (full kit)" % [spawn, _controller.current_layout])


func _apply_full_kit_tuning(player: Player) -> void:
	player.unlocks = ALL_UNLOCKED
	player.max_air_jumps = 1
