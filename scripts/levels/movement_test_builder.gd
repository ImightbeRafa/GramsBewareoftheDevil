class_name MovementTestBuilder
extends RefCounted

## Main layout (32x15) + hook shaft on the right (20x27). Scaled 2x for playable corridors.

const TILE: int = KenneyPlatformTiles.TILE_SIZE
const SCALE: int = 2
const GOAL_SCENE: PackedScene = preload("res://scenes/levels/goal.tscn")
const SPIKE_SCENE: PackedScene = preload("res://scenes/hazards/spike_hazard.tscn")
const FIRE_ORB_SCENE: PackedScene = preload("res://scenes/hazards/fire_orb.tscn")
const HOOK_POINT_SCENE: PackedScene = preload("res://scenes/platforms/hook_point.tscn")

## '#' = solid, '.' = empty. Top-left opening is the entry shaft.
const LAYOUT: PackedStringArray = [
	"#...############################",
	"#...##.....#####################",
	"#...#....#....##...#############",
	"#..##..#####.......#############",
	"#...#....#######...##..........#",
	"#...#..#########...##.#..###...#",
	"##..##.###............#........#",
	"#...#..###............#........#",
	"#...#..##..........##......#...#",
	"#...#..##..........##.....###..#",
	"#..##..##..................#...#",
	"#..........##########..........#",
	"#...............######.##.######",
	"################################",
	"################################",
]

## Tall hook-test shaft (20x27), attached to the right of LAYOUT.
const HOOK_LAYOUT: PackedStringArray = [
	"####################",
	"#..................#",
	"#..................#",
	"#..............#####",
	"#...............####",
	"#...............####",
	"#...............####",
	"#................###",
	"#..................#",
	"###................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#............#######",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"#..................#",
	"##.................#",
	"####################",
]

## Red-dot hook anchors in HOOK_LAYOUT cell coords (col, row).
const HOOK_POINTS: Array[Vector2] = [
	Vector2(13, 3),
	Vector2(9, 3),
	Vector2(6, 5),
	Vector2(14, 6),
	Vector2(3, 7),
	Vector2(16, 10),
	Vector2(4, 10),
	Vector2(8, 11),
	Vector2(11, 11),
	Vector2(16, 14),
	Vector2(12, 14),
	Vector2(9, 16),
	Vector2(3, 17),
	Vector2(6, 19),
	Vector2(17, 19),
	Vector2(15, 22),
	Vector2(8, 22),
	Vector2(4, 22),
	Vector2(18, 23),
]

const HOOK_ORIGIN_COL: int = 32
const HOOK_ORIGIN_ROW: int = 0
## Walkway rows punched through the shared wall into the hook shaft.
const CONNECT_ROWS: Array[int] = [10, 11, 12]

var _tiles: TileMapLayer
var _objects: Node2D
var _solid: Dictionary = {}


static func build(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	var builder := MovementTestBuilder.new()
	return builder._build(tiles, objects)


static func build_async(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	var builder := MovementTestBuilder.new()
	return await builder._build_async(tiles, objects)


func _build_async(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	_tiles = tiles
	_objects = objects
	_tiles.tile_set = KenneyPlatformTiles.build_tileset()
	await _yield_frame()
	_paint_layout()
	await _yield_frame()
	_spawn_hazards()
	_spawn_movers()
	_spawn_hook_points()
	_spawn_goal()
	return _map_meta()


func _build(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	_tiles = tiles
	_objects = objects
	_tiles.tile_set = KenneyPlatformTiles.build_tileset()
	_paint_layout()
	_spawn_hazards()
	_spawn_movers()
	_spawn_hook_points()
	_spawn_goal()
	return _map_meta()


func _yield_frame() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame


func _map_w() -> int:
	return (HOOK_ORIGIN_COL + HOOK_LAYOUT[0].length()) * SCALE


func _map_h() -> int:
	return maxi(LAYOUT.size(), HOOK_ORIGIN_ROW + HOOK_LAYOUT.size()) * SCALE


func _map_meta() -> Dictionary:
	var w_px := float(_map_w() * TILE)
	var h_px := float(_map_h() * TILE)
	# Blue-dot start: stand on the left-wall protrusion (layout col 1, row 6).
	var spawn := _surface(1.5, 6.0)
	# Inside hook shaft, on the left ledge — quick jump for hook testing.
	var hook_teleport := _surface(float(HOOK_ORIGIN_COL) + 1.5, float(HOOK_ORIGIN_ROW) + 9.0)
	return {
		"spawn": spawn,
		"hook_teleport": hook_teleport,
		"camera_bounds": Rect2(-TILE * 2, -TILE * 2, w_px + TILE * 4, h_px + TILE * 4),
	}


func _tx(col: float) -> float:
	return col * float(TILE) * float(SCALE) + float(TILE) * 0.5 * float(SCALE)


func _ty(row: float) -> float:
	return row * float(TILE) * float(SCALE)


func _surface(layout_col: float, layout_row: float) -> Vector2:
	## World position on the top face of a layout cell.
	return Vector2(_tx(layout_col), _ty(layout_row))


func _center(layout_col: float, layout_row: float) -> Vector2:
	## World position at the center of a layout cell (for floating hook points).
	return Vector2(_tx(layout_col), _ty(layout_row) + float(TILE) * float(SCALE) * 0.5)


func _paint_layout() -> void:
	_solid.clear()
	_stamp_region(LAYOUT, 0, 0)
	_stamp_region(HOOK_LAYOUT, HOOK_ORIGIN_COL, HOOK_ORIGIN_ROW)
	_open_hook_connection()

	for cell: Vector2i in _solid.keys():
		var atlas := _atlas_for_cell(cell)
		_tiles.set_cell(cell, 0, atlas)


func _stamp_region(region: PackedStringArray, origin_col: int, origin_row: int) -> void:
	for row in range(region.size()):
		var line: String = region[row]
		for col in range(line.length()):
			if line[col] != "#":
				continue
			var lc := origin_col + col
			var lr := origin_row + row
			for sy in range(SCALE):
				for sx in range(SCALE):
					_solid[Vector2i(lc * SCALE + sx, lr * SCALE + sy)] = true


func _open_hook_connection() -> void:
	## Doorway from the main room into the hook shaft.
	for row in CONNECT_ROWS:
		_clear_layout_cell(LAYOUT[0].length() - 1, row)
		_clear_layout_cell(HOOK_ORIGIN_COL, HOOK_ORIGIN_ROW + row)


func _clear_layout_cell(layout_col: int, layout_row: int) -> void:
	for sy in range(SCALE):
		for sx in range(SCALE):
			_solid.erase(Vector2i(layout_col * SCALE + sx, layout_row * SCALE + sy))


func _atlas_for_cell(cell: Vector2i) -> Vector2i:
	var above_empty := not _solid.has(Vector2i(cell.x, cell.y - 1))
	var left_solid := _solid.has(Vector2i(cell.x - 1, cell.y))
	var right_solid := _solid.has(Vector2i(cell.x + 1, cell.y))
	if above_empty:
		if not left_solid:
			return KenneyPlatformTiles.ATLAS_TOP_LEFT
		if not right_solid:
			return KenneyPlatformTiles.ATLAS_TOP_RIGHT
		return KenneyPlatformTiles.ATLAS_TOP_MID
	if not left_solid:
		return KenneyPlatformTiles.ATLAS_MID_LEFT
	if not right_solid:
		return KenneyPlatformTiles.ATLAS_MID_RIGHT
	return KenneyPlatformTiles.ATLAS_MID


func _spawn_hazards() -> void:
	# Long mid platform spikes — shifted 1 layout block left to flush with the ledge.
	_paint_spike_strip(10.0, 20.0, 11.0)
	# Pit spikes — also one block left.
	_spawn_spike(_surface(21.5, 13.0))
	_spawn_spike(_surface(24.5, 13.0))


func _paint_spike_strip(start_col: float, end_col: float, row: float) -> void:
	var col := start_col
	while col < end_col:
		_spawn_spike(_surface(col + 0.5, row))
		col += 1.0


func _spawn_spike(pos: Vector2) -> void:
	var spike: SpikeHazard = SPIKE_SCENE.instantiate()
	spike.position = pos
	_objects.add_child(spike)


func _spawn_movers() -> void:
	# Black-dot patrols: sit on the floor and travel left ↔ right between the dots.
	_spawn_fire_orb(_floor(6.5, 5.0), _floor(9.5, 5.0), 5.0)
	_spawn_fire_orb(_floor(2.5, 13.0), _floor(16.5, 13.0), 5.0)


func _floor(layout_col: float, layout_row: float) -> Vector2:
	## Orb center so the bottom rests on the tile top (orb radius ≈ 12px).
	return _surface(layout_col, layout_row) + Vector2(0.0, -12.0)


func _spawn_fire_orb(start: Vector2, end: Vector2, duration: float) -> void:
	var orb: FireOrb = FIRE_ORB_SCENE.instantiate()
	orb.point_a = start
	orb.point_b = end
	orb.travel_duration = duration
	orb.wait_at_ends = 0.25
	orb.position = start
	_objects.add_child(orb)


func _spawn_hook_points() -> void:
	for point in HOOK_POINTS:
		var col := float(HOOK_ORIGIN_COL) + point.x
		var row := float(HOOK_ORIGIN_ROW) + point.y
		_spawn_hook_point(_center(col, row))


func _spawn_hook_point(pos: Vector2) -> void:
	var hook: Node2D = HOOK_POINT_SCENE.instantiate()
	hook.position = pos
	_objects.add_child(hook)


func _spawn_goal() -> void:
	# Yellow mark: upper right pocket near the hanging vertical pillar / bar.
	var goal: Node2D = GOAL_SCENE.instantiate()
	goal.position = _surface(26.0, 5.0)
	_objects.add_child(goal)
