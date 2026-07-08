class_name ChunkGenerator
extends Node

const CHUNK_TILES: int = 36
const CHUNK_WIDTH: float = float(KenneyPlatformTiles.TILE_SIZE * CHUNK_TILES)
const MAX_GAP_TILES: int = 11

const PATROL_ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/patrol_enemy.tscn")
const GOAL_SCENE: PackedScene = preload("res://scenes/levels/goal.tscn")

@export var max_chunks: int = 10
@export var lookahead_distance: float = 1280.0
@export var cull_behind_distance: float = 960.0
@export var random_seed: int = 0
@export var use_random_seed: bool = true

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _chunk_root: Node2D
var _world_tiles: TileMapLayer
var _player: Player
var _next_chunk_index: int = 0
var _chunks_spawned: int = 0
var _generation_finished: bool = false
var _active_chunks: Array[Node2D] = []


func _ready() -> void:
	if use_random_seed:
		_rng.randomize()
	else:
		_rng.seed = random_seed

	var level_root := get_parent()
	_chunk_root = level_root.get_node_or_null("ChunkRoot") as Node2D
	_world_tiles = level_root.get_node_or_null("WorldTiles") as TileMapLayer
	if _chunk_root == null or _world_tiles == null:
		push_error("ChunkGenerator requires ChunkRoot and WorldTiles siblings.")
		return

	if _world_tiles.tile_set == null:
		_world_tiles.tile_set = KenneyPlatformTiles.build_tileset()

	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player") as Player
	if _player == null:
		push_error("ChunkGenerator could not find a node in group 'player'.")
		return

	_spawn_start_chunks()


func _process(_delta: float) -> void:
	if _player == null or _chunk_root == null or _world_tiles == null:
		return

	if not _generation_finished:
		var right_edge := (_next_chunk_index * CHUNK_WIDTH) - CHUNK_WIDTH
		if _player.global_position.x + lookahead_distance >= right_edge:
			_spawn_next_chunk()

	_cull_old_chunks()


func _spawn_start_chunks() -> void:
	_spawn_next_chunk(true)
	_spawn_next_chunk(true)


func _spawn_next_chunk(force_flat: bool = false) -> void:
	if _generation_finished:
		return

	var chunk := Node2D.new()
	chunk.name = "Chunk_%d" % _next_chunk_index
	chunk.position.x = _next_chunk_index * CHUNK_WIDTH
	_chunk_root.add_child(chunk)

	var start_tile_x := int(chunk.position.x / KenneyPlatformTiles.TILE_SIZE)
	chunk.set_meta("tile_start_x", start_tile_x)
	chunk.set_meta("tile_end_x", start_tile_x + CHUNK_TILES)
	_active_chunks.append(chunk)

	if _chunks_spawned >= max_chunks - 1:
		_build_finish_chunk(chunk, start_tile_x)
		_generation_finished = true
	elif force_flat or _chunks_spawned < 2:
		_build_flat_chunk(chunk, start_tile_x)
	else:
		_build_random_chunk(chunk, start_tile_x)

	_next_chunk_index += 1
	_chunks_spawned += 1


func _build_random_chunk(chunk: Node2D, start_tile_x: int) -> void:
	match _rng.randi_range(0, 2):
		0:
			_build_flat_chunk(chunk, start_tile_x)
		1:
			_build_gap_chunk(chunk, start_tile_x)
		_:
			_build_platforms_chunk(chunk, start_tile_x)


func _build_flat_chunk(chunk: Node2D, start_tile_x: int) -> void:
	_paint_ground_strip(start_tile_x, start_tile_x + CHUNK_TILES)
	if _rng.randf() > 0.65:
		_spawn_enemy(
			chunk,
			Vector2(_rng.randf_range(180.0, CHUNK_WIDTH - 180.0), KenneyPlatformTiles.surface_y())
		)


func _build_gap_chunk(chunk: Node2D, start_tile_x: int) -> void:
	var gap_tiles := _rng.randi_range(7, MAX_GAP_TILES)
	var side_tiles: int = (CHUNK_TILES - gap_tiles) / 2
	var left_end := start_tile_x + side_tiles
	var right_start := left_end + gap_tiles

	_paint_ground_strip(start_tile_x, left_end)
	_paint_ground_strip(right_start, start_tile_x + CHUNK_TILES)
	_paint_spike_gap(left_end, right_start)

	if _rng.randf() > 0.5:
		var on_left := _rng.randf() > 0.5
		var local_x := side_tiles * KenneyPlatformTiles.TILE_SIZE * 0.5
		if not on_left:
			local_x = CHUNK_WIDTH - side_tiles * KenneyPlatformTiles.TILE_SIZE * 0.5
		var enemy := _spawn_enemy(chunk, Vector2(local_x, KenneyPlatformTiles.surface_y()))
		enemy.patrol_distance = minf(side_tiles * KenneyPlatformTiles.TILE_SIZE * 0.35, 60.0)


func _build_platforms_chunk(chunk: Node2D, start_tile_x: int) -> void:
	var gap_tiles := _rng.randi_range(8, 12)
	var side_tiles: int = (CHUNK_TILES - gap_tiles) / 2
	var left_end := start_tile_x + side_tiles
	var right_start := left_end + gap_tiles
	var bridge_start := left_end
	var bridge_end := right_start

	_paint_ground_strip(start_tile_x, left_end)
	_paint_ground_strip(right_start, start_tile_x + CHUNK_TILES)
	_paint_spike_gap(left_end, right_start)

	var bridge_row := KenneyPlatformTiles.SURFACE_ROW - 8
	var bridge_tile_y := bridge_row
	var bridge_tile_x_start := bridge_start
	var bridge_tile_x_end := bridge_end
	for tile_x in range(bridge_tile_x_start, bridge_tile_x_end):
		_set_ground_tile(tile_x, bridge_tile_y, bridge_tile_x_start, bridge_tile_x_end)

	if _rng.randf() > 0.35:
		var side_width := side_tiles * KenneyPlatformTiles.TILE_SIZE
		var local_x := _rng.randf_range(80.0, side_width - 40.0)
		if _rng.randf() <= 0.5:
			local_x = CHUNK_WIDTH - _rng.randf_range(80.0, side_width - 40.0)
		_spawn_enemy(chunk, Vector2(local_x, KenneyPlatformTiles.surface_y()))


func _build_finish_chunk(chunk: Node2D, start_tile_x: int) -> void:
	_paint_ground_strip(start_tile_x, start_tile_x + CHUNK_TILES)

	var goal := GOAL_SCENE.instantiate() as Node2D
	goal.position = Vector2(CHUNK_WIDTH - 72.0, KenneyPlatformTiles.surface_y())
	chunk.add_child(goal)


func _paint_ground_strip(start_tile_x: int, end_tile_x: int) -> void:
	for tile_x in range(start_tile_x, end_tile_x):
		for depth in KenneyPlatformTiles.FILL_DEPTH + 1:
			var row := KenneyPlatformTiles.SURFACE_ROW + depth
			var atlas := (
				KenneyPlatformTiles.top_atlas_for_column(tile_x, start_tile_x, end_tile_x)
				if depth == 0
				else KenneyPlatformTiles.fill_atlas_for_column(tile_x, start_tile_x, end_tile_x)
			)
			_world_tiles.set_cell(Vector2i(tile_x, row), 0, atlas)


func _set_ground_tile(tile_x: int, tile_y: int, start_tile_x: int, end_tile_x: int) -> void:
	var atlas := KenneyPlatformTiles.top_atlas_for_column(tile_x, start_tile_x, end_tile_x)
	_world_tiles.set_cell(Vector2i(tile_x, tile_y), 0, atlas)


func _paint_spike_gap(start_tile_x: int, end_tile_x: int) -> void:
	for tile_x in range(start_tile_x, end_tile_x):
		_world_tiles.set_cell(
			Vector2i(tile_x, KenneyPlatformTiles.SURFACE_ROW),
			0,
			KenneyPlatformTiles.ATLAS_SPIKE
		)


func _spawn_enemy(chunk: Node2D, local_position: Vector2) -> Node2D:
	var enemy := PATROL_ENEMY_SCENE.instantiate() as Node2D
	enemy.position = local_position
	chunk.add_child(enemy)
	return enemy


func _cull_old_chunks() -> void:
	if _player == null or _world_tiles == null:
		return

	var camera := _player.get_node_or_null("Camera2D") as Camera2D
	var cull_x := _player.global_position.x - cull_behind_distance
	if camera != null:
		cull_x = camera.get_screen_center_position().x - cull_behind_distance

	var i := 0
	var keep_count := mini(3, _active_chunks.size())
	while i < _active_chunks.size() - keep_count:
		var chunk := _active_chunks[i]
		var chunk_right := chunk.position.x + CHUNK_WIDTH
		if chunk_right < cull_x:
			_erase_chunk_tiles(chunk)
			chunk.queue_free()
			_active_chunks.remove_at(i)
		else:
			i += 1


func _erase_chunk_tiles(chunk: Node2D) -> void:
	if not chunk.has_meta("tile_start_x") or not chunk.has_meta("tile_end_x"):
		return

	var start_tile_x: int = chunk.get_meta("tile_start_x")
	var end_tile_x: int = chunk.get_meta("tile_end_x")
	for tile_x in range(start_tile_x, end_tile_x):
		for tile_y in range(KenneyPlatformTiles.SURFACE_ROW - 10, KenneyPlatformTiles.SURFACE_ROW + KenneyPlatformTiles.FILL_DEPTH + 2):
			_world_tiles.erase_cell(Vector2i(tile_x, tile_y))
