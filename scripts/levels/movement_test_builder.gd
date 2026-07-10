class_name MovementTestBuilder
extends RefCounted

## Digitized from the reference layout image (32x15), scaled 2x for playable corridors.

const TILE: int = KenneyPlatformTiles.TILE_SIZE
const SCALE: int = 2
const GOAL_SCENE: PackedScene = preload("res://scenes/levels/goal.tscn")
const SPIKE_SCENE: PackedScene = preload("res://scenes/hazards/spike_hazard.tscn")
const FIRE_ORB_SCENE: PackedScene = preload("res://scenes/hazards/fire_orb.tscn")

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
	_spawn_goal()
	return _map_meta()


func _build(tiles: TileMapLayer, objects: Node2D) -> Dictionary:
	_tiles = tiles
	_objects = objects
	_tiles.tile_set = KenneyPlatformTiles.build_tileset()
	_paint_layout()
	_spawn_hazards()
	_spawn_movers()
	_spawn_goal()
	return _map_meta()


func _yield_frame() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame


func _map_w() -> int:
	return LAYOUT[0].length() * SCALE


func _map_h() -> int:
	return LAYOUT.size() * SCALE


func _map_meta() -> Dictionary:
	var w_px := float(_map_w() * TILE)
	var h_px := float(_map_h() * TILE)
	# Blue-dot start: stand on the left-wall protrusion (layout col 1, row 6).
	var spawn := _surface(1.5, 6.0)
	return {
		"spawn": spawn,
		"camera_bounds": Rect2(-TILE * 2, -TILE * 2, w_px + TILE * 4, h_px + TILE * 4),
	}


func _tx(col: float) -> float:
	return col * float(TILE) * float(SCALE) + float(TILE) * 0.5 * float(SCALE)


func _ty(row: float) -> float:
	return row * float(TILE) * float(SCALE)


func _surface(layout_col: float, layout_row: float) -> Vector2:
	## World position on the top face of a layout cell.
	return Vector2(_tx(layout_col), _ty(layout_row))


func _paint_layout() -> void:
	_solid.clear()
	for row in range(LAYOUT.size()):
		var line: String = LAYOUT[row]
		for col in range(line.length()):
			if line[col] != "#":
				continue
			for sy in range(SCALE):
				for sx in range(SCALE):
					_solid[Vector2i(col * SCALE + sx, row * SCALE + sy)] = true

	for cell: Vector2i in _solid.keys():
		var atlas := _atlas_for_cell(cell)
		_tiles.set_cell(cell, 0, atlas)


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
	# Upper pair (layout ~col 6.5 ↔ 9.5 on the mid-left ledge floor).
	_spawn_fire_orb(_floor(6.5, 5.0), _floor(9.5, 5.0), 5.0)
	# Lower pair (layout ~col 2.5 ↔ 16.5 on the bottom floor).
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


func _spawn_goal() -> void:
	# Yellow mark: upper right pocket near the hanging vertical pillar / bar.
	var goal: Node2D = GOAL_SCENE.instantiate()
	goal.position = _surface(26.0, 5.0)
	_objects.add_child(goal)
