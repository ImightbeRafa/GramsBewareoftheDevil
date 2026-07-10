class_name ParkourMapBuilder
extends RefCounted

const TILE: int = KenneyPlatformTiles.TILE_SIZE
const MAP_W: int = 180
const MAP_H: int = 90

const MOVING_PLATFORM_SCENE: PackedScene = preload("res://scenes/platforms/moving_platform.tscn")
const CRUMBLING_PLATFORM_SCENE: PackedScene = preload("res://scenes/platforms/crumbling_platform.tscn")
const HOOK_POINT_SCENE: PackedScene = preload("res://scenes/platforms/hook_point.tscn")
const POGO_PAD_SCENE: PackedScene = preload("res://scenes/platforms/pogo_pad.tscn")
const CHECKPOINT_SCENE: PackedScene = preload("res://scenes/platforms/checkpoint.tscn")
const CRUMBLE_BLOCK_SCENE: PackedScene = preload("res://scenes/platforms/crumble_block.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/enemies/patrol_enemy.tscn")
const GOAL_SCENE: PackedScene = preload("res://scenes/levels/goal.tscn")

var _tiles: TileMapLayer
var _objects: Node2D


static func build(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	var builder := ParkourMapBuilder.new()
	return builder._build(tiles, objects)


static func build_async(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	var builder := ParkourMapBuilder.new()
	return await builder._build_async(tiles, objects)


func _build_async(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	_tiles = tiles
	_objects = objects
	_tiles.tile_set = KenneyPlatformTiles.build_tileset()
	await _yield_frame()

	_paint_bounds()
	await _yield_frame()
	_build_section_0_warmup()
	await _yield_frame()
	_build_section_1_air_stairs()
	await _yield_frame()
	_build_section_2_dash_gap()
	await _yield_frame()
	_build_section_3_wall_shaft()
	await _yield_frame()
	_build_section_4_climb_chimney()
	await _yield_frame()
	_build_section_5_moving_shelf()
	await _yield_frame()
	_build_section_6_crumble_run()
	await _yield_frame()
	_build_section_7_pogo_alley()
	await _yield_frame()
	_build_section_8_hook_canyon()
	await _yield_frame()
	_build_section_9_glide_descent()
	await _yield_frame()
	_build_section_10_momentum_highway()
	await _yield_frame()
	_build_section_11_smash_gate()
	await _yield_frame()
	_build_sandbox_pocket()
	await _yield_frame()
	_spawn_checkpoints()
	_spawn_goal()

	return {
		"spawn": Vector2(_tx(4), _ty(80)),
		"camera_bounds": Rect2(-32, -64, 3304, 1744),
	}


func _yield_frame() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame


func _build(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	_tiles = tiles
	_objects = objects
	_tiles.tile_set = KenneyPlatformTiles.build_tileset()

	_paint_bounds()
	_build_section_0_warmup()
	_build_section_1_air_stairs()
	_build_section_2_dash_gap()
	_build_section_3_wall_shaft()
	_build_section_4_climb_chimney()
	_build_section_5_moving_shelf()
	_build_section_6_crumble_run()
	_build_section_7_pogo_alley()
	_build_section_8_hook_canyon()
	_build_section_9_glide_descent()
	_build_section_10_momentum_highway()
	_build_section_11_smash_gate()
	_build_sandbox_pocket()
	_spawn_checkpoints()
	_spawn_goal()

	return {
		"spawn": Vector2(_tx(4), _ty(80)),
		"camera_bounds": Rect2(-32, -64, 3304, 1744),
	}


func _tx(col: int) -> float:
	return float(col * TILE + TILE / 2)


func _ty(row: int) -> float:
	return float(row * TILE)


func _paint_bounds() -> void:
	for x in range(MAP_W):
		_paint_column(x, MAP_H - 2, MAP_H - 1)
	for y in range(MAP_H):
		_paint_column(0, y, y)
		_paint_column(MAP_W - 1, y, y)


func _paint_ground(start_x: int, end_x: int, row: int, depth: int = 3) -> void:
	for x in range(start_x, end_x):
		for d in range(depth):
			_paint_column(x, row + d, row + d)


func _paint_column(tile_x: int, fill_row: int, top_row: int) -> void:
	var start := tile_x
	var end := tile_x + 1
	_tiles.set_cell(
		Vector2i(tile_x, top_row),
		0,
		KenneyPlatformTiles.top_atlas_for_column(tile_x, start, end)
	)
	for depth in range(1, KenneyPlatformTiles.FILL_DEPTH):
		_tiles.set_cell(
			Vector2i(tile_x, top_row + depth),
			0,
			KenneyPlatformTiles.fill_atlas_for_column(tile_x, start, end)
		)


func _paint_wall(start_x: int, end_x: int, start_row: int, end_row: int) -> void:
	for x in range(start_x, end_x):
		for y in range(start_row, end_row):
			_paint_column(x, y, y)


func _paint_gap(start_x: int, width: int, row: int) -> void:
	for x in range(start_x, start_x + width):
		for y in range(row, row + 4):
			_tiles.erase_cell(Vector2i(x, y))


func _add_sign(text: String, col: int, row: int) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(_tx(col) - 40.0, _ty(row) - 20.0)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.1, 0.15, 0.25))
	_objects.add_child(label)


func _build_section_0_warmup() -> void:
	_paint_ground(1, 25, 80)
	_paint_gap(14, 7, 80)
	_add_sign("0 · Warmup — coyote & buffer", 2, 76)


func _build_section_1_air_stairs() -> void:
	var rows := [80, 76, 72, 68]
	var cols := [26, 31, 36, 41]
	for i in range(rows.size()):
		_paint_ground(cols[i], cols[i] + 5, rows[i])
	_add_sign("1 · Air Jump Stairs", 27, 64)


func _build_section_2_dash_gap() -> void:
	_paint_ground(42, 48, 68)
	_paint_ground(58, 64, 68)
	_paint_gap(48, 10, 68)
	_add_sign("2 · Dash Gap", 44, 64)


func _build_section_3_wall_shaft() -> void:
	_paint_ground(58, 66, 68)
	_paint_wall(58, 60, 40, 68)
	_paint_wall(64, 66, 40, 68)
	_paint_ground(58, 66, 40)
	_add_sign("3 · Wall Shaft", 59, 38)


func _build_section_4_climb_chimney() -> void:
	_paint_wall(66, 68, 22, 40)
	_paint_wall(70, 72, 22, 40)
	_paint_ground(66, 72, 22)
	_add_sign("4 · Climb Chimney", 67, 20)


func _build_section_5_moving_shelf() -> void:
	_paint_ground(72, 92, 30)
	_spawn_moving_platform(Vector2(_tx(76), _ty(26)), Vector2(_tx(82), _ty(26)), 2.0)
	_spawn_moving_platform(Vector2(_tx(84), _ty(28)), Vector2(_tx(84), _ty(22)), 2.2)
	_spawn_moving_platform(Vector2(_tx(88), _ty(24)), Vector2(_tx(92), _ty(24)), 1.8)
	_add_sign("5 · Moving Shelf", 73, 18)


func _build_section_6_crumble_run() -> void:
	_paint_ground(92, 94, 28)
	for i in range(5):
		var col := 96 + i * 5
		_spawn_crumbling_platform(Vector2(_tx(col), _ty(28)))
	_add_sign("6 · Crumble Run", 93, 24)


func _build_section_7_pogo_alley() -> void:
	_paint_ground(110, 128, 40)
	_paint_ground(110, 128, 28)
	for i in range(3):
		var col := 114 + i * 5
		_spawn_enemy(Vector2(_tx(col), _ty(32) - 18.0))
	_spawn_pogo_pad(Vector2(_tx(120), _ty(36)))
	_add_sign("7 · Pogo Alley", 111, 24)


func _build_section_8_hook_canyon() -> void:
	_paint_ground(128, 132, 40)
	_paint_ground(134, 136, 36)
	_paint_ground(138, 140, 32)
	_paint_ground(142, 144, 28)
	_paint_ground(144, 148, 18)
	_spawn_hook_point(Vector2(_tx(135), _ty(38)))
	_spawn_hook_point(Vector2(_tx(139), _ty(34)))
	_spawn_hook_point(Vector2(_tx(143), _ty(30)))
	_spawn_hook_point(Vector2(_tx(147), _ty(22)))
	_add_sign("8 · Hook Canyon", 129, 36)


func _build_section_9_glide_descent() -> void:
	_paint_ground(148, 152, 18)
	_paint_ground(154, 158, 35)
	for i in range(4):
		_paint_ground(149 + i * 2, 151 + i * 2, 22 + i * 4)
	_add_sign("9 · Glide Descent (Ctrl)", 149, 16)


func _build_section_10_momentum_highway() -> void:
	for x in range(158, 172):
		var row := 35 - int((x - 158) * 1.5)
		_paint_ground(x, x + 1, row)
	_add_sign("10 · Momentum (F = second wind)", 159, 12)


func _build_section_11_smash_gate() -> void:
	_paint_ground(172, 180, 10)
	_spawn_crumble_block(Vector2(_tx(176), _ty(10) - 9.0))
	_spawn_crumble_block(Vector2(_tx(178), _ty(10) - 9.0))
	_add_sign("11 · Smash Gate", 173, 6)


func _build_sandbox_pocket() -> void:
	_paint_ground(8, 20, 70)
	_paint_wall(8, 10, 50, 70)
	_paint_wall(18, 20, 50, 70)
	_add_sign("Lab · wall/dash sandbox", 9, 48)


func _spawn_moving_platform(point_a: Vector2, point_b: Vector2, duration: float) -> void:
	var platform: MovingPlatform = MOVING_PLATFORM_SCENE.instantiate()
	platform.point_a = point_a
	platform.point_b = point_b
	platform.travel_duration = duration
	platform.position = point_a
	_objects.add_child(platform)


func _spawn_crumbling_platform(pos: Vector2) -> void:
	var platform: CrumblingPlatform = CRUMBLING_PLATFORM_SCENE.instantiate()
	platform.position = pos
	_objects.add_child(platform)


func _spawn_hook_point(pos: Vector2) -> void:
	var hook: Node2D = HOOK_POINT_SCENE.instantiate()
	hook.position = pos
	_objects.add_child(hook)


func _spawn_pogo_pad(pos: Vector2) -> void:
	var pad: Node2D = POGO_PAD_SCENE.instantiate()
	pad.position = pos
	_objects.add_child(pad)


func _spawn_enemy(pos: Vector2) -> void:
	var enemy: Node2D = ENEMY_SCENE.instantiate()
	enemy.position = pos
	enemy.patrol_distance = 30.0
	_objects.add_child(enemy)


func _spawn_crumble_block(pos: Vector2) -> void:
	var block: Node2D = CRUMBLE_BLOCK_SCENE.instantiate()
	block.position = pos
	_objects.add_child(block)


func _spawn_checkpoints() -> void:
	_spawn_checkpoint(Vector2(_tx(4), _ty(80)), 0)
	_spawn_checkpoint(Vector2(_tx(72), _ty(30)), 1)
	_spawn_checkpoint(Vector2(_tx(110), _ty(28)), 2)
	_spawn_checkpoint(Vector2(_tx(148), _ty(18)), 3)


func _spawn_checkpoint(pos: Vector2, id: int) -> void:
	var cp: Area2D = CHECKPOINT_SCENE.instantiate()
	cp.position = pos
	cp.checkpoint_id = id
	_objects.add_child(cp)


func _spawn_goal() -> void:
	var goal: Node2D = GOAL_SCENE.instantiate()
	goal.position = Vector2(_tx(179), _ty(10) - 18.0)
	_objects.add_child(goal)
