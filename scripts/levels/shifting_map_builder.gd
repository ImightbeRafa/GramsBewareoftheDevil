class_name ShiftingMapBuilder
extends RefCounted

const TILE: int = KenneyPlatformTiles.TILE_SIZE
const MAP_W: int = 280
const MAP_H: int = 140
const LAVA_ROW: int = 136

const SHIFTING_BLOCK_SCENE: PackedScene = preload("res://scenes/platforms/shifting_block.tscn")
const MOVING_PLATFORM_SCENE: PackedScene = preload("res://scenes/platforms/moving_platform.tscn")
const CRUMBLING_PLATFORM_SCENE: PackedScene = preload("res://scenes/platforms/crumbling_platform.tscn")
const HOOK_POINT_SCENE: PackedScene = preload("res://scenes/platforms/hook_point.tscn")
const POGO_PAD_SCENE: PackedScene = preload("res://scenes/platforms/pogo_pad.tscn")
const CHECKPOINT_SCENE: PackedScene = preload("res://scenes/platforms/checkpoint.tscn")
const CRUMBLE_BLOCK_SCENE: PackedScene = preload("res://scenes/platforms/crumble_block.tscn")
const GOAL_SCENE: PackedScene = preload("res://scenes/levels/goal.tscn")
const FREEZE_ANCHOR_SCENE: PackedScene = preload("res://scenes/platforms/freeze_anchor.tscn")
const SHIFT_TRIGGER_SCENE: PackedScene = preload("res://scenes/levels/shift_trigger_zone.tscn")
const SPIKE_SCENE: PackedScene = preload("res://scenes/hazards/spike_hazard.tscn")
const TOXIC_SCENE: PackedScene = preload("res://scenes/hazards/toxic_zone.tscn")
const FIRE_ORB_SCENE: PackedScene = preload("res://scenes/hazards/fire_orb.tscn")
const PRESSURE_PLATE_SCENE: PackedScene = preload("res://scenes/hazards/pressure_plate.tscn")
const SPIKE_TRAP_SCENE: PackedScene = preload("res://scenes/hazards/spike_trap.tscn")

var _safe_tiles: TileMapLayer
var _shifting_root: Node2D
var _objects: Node2D
var _controller: ShiftingMapController


static func build_async(
	safe_tiles: TileMapLayer,
	shifting_root: Node2D,
	objects: Node2D,
	controller: ShiftingMapController
) -> Dictionary:
	var builder: ShiftingMapBuilder = ShiftingMapBuilder.new()
	return await builder._build_async(safe_tiles, shifting_root, objects, controller)


func _build_async(
	safe_tiles: TileMapLayer,
	shifting_root: Node2D,
	objects: Node2D,
	controller: ShiftingMapController
) -> Dictionary:
	_safe_tiles = safe_tiles
	_shifting_root = shifting_root
	_objects = objects
	_controller = controller
	_safe_tiles.tile_set = KenneyPlatformTiles.build_tileset()
	await _yield_frame()

	_paint_bounds()
	_paint_safe_islands()
	await _yield_frame()

	var blocks: Array[ShiftingBlock] = _spawn_shifting_sections()
	_controller.register_blocks(blocks)
	await _yield_frame()

	_spawn_bay_hazards()
	_spawn_parkour_props()
	_spawn_traps()
	_spawn_checkpoints()
	_spawn_freeze_anchors()
	_spawn_shift_triggers()
	_spawn_goal()
	await _yield_frame()

	return {
		"spawn": _surface(14.0, 128.0) + Vector2(0.0, -18.0),
		"camera_bounds": Rect2(-48, -96, _tx(280.0) + 96.0, _ty(140.0) + 160.0),
		"lava_y": _ty(136.0),
	}


func _yield_frame() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame


func _tx(col: float) -> float:
	return col * float(TILE) + float(TILE) * 0.5


func _ty(row: float) -> float:
	return row * float(TILE)


func _surface(col: float, row: float) -> Vector2:
	return Vector2(_tx(col), _ty(row))


func _poses4(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> Array[Vector2]:
	return [
		_surface(a.x, a.y),
		_surface(b.x, b.y),
		_surface(c.x, c.y),
		_surface(d.x, d.y),
	]


func _paint_bounds() -> void:
	for x in range(MAP_W):
		_paint_column(x, MAP_H - 2, MAP_H - 1)
	for y in range(MAP_H):
		_paint_column(0, y, y)
		_paint_column(MAP_W - 1, y, y)


func _paint_column(tile_x: int, fill_row: int, top_row: int) -> void:
	var start: int = tile_x
	var end: int = tile_x + 1
	_safe_tiles.set_cell(
		Vector2i(tile_x, top_row),
		0,
		KenneyPlatformTiles.top_atlas_for_column(tile_x, start, end)
	)
	for depth in range(1, KenneyPlatformTiles.FILL_DEPTH):
		_safe_tiles.set_cell(
			Vector2i(tile_x, top_row + depth),
			0,
			KenneyPlatformTiles.fill_atlas_for_column(tile_x, start, end)
		)


func _paint_ground(start_x: int, end_x: int, surface_row: int, depth: int = 3) -> void:
	for x in range(start_x, end_x):
		for d in range(depth):
			_paint_column(x, surface_row + d, surface_row + d)


func _paint_wall(start_x: int, end_x: int, start_row: int, end_row: int) -> void:
	for x in range(start_x, end_x):
		for y in range(start_row, end_row):
			_paint_column(x, y, y)


func _paint_safe_islands() -> void:
	_paint_ground(8, 28, 128)
	_paint_ground(42, 56, 112)
	_paint_wall(42, 44, 100, 112)
	_paint_ground(78, 94, 96)
	_paint_ground(118, 134, 78)
	_paint_wall(118, 120, 64, 78)
	_paint_wall(132, 134, 64, 78)
	_paint_ground(158, 176, 58)
	_paint_wall(158, 160, 44, 58)
	_paint_ground(200, 218, 40)
	_paint_ground(248, 272, 22)
	_paint_wall(248, 250, 14, 22)
	_paint_wall(100, 102, 78, 112)
	_paint_wall(126, 128, 78, 112)


func _spawn_shifting_sections() -> Array[ShiftingBlock]:
	var blocks: Array[ShiftingBlock] = []

	blocks.append(_spawn_block(
		14.0, 1.0, Color(0.62, 0.72, 0.92, 1.0),
		_poses4(Vector2(34, 126), Vector2(24, 126), Vector2(38, 122), Vector2(34, 108))
	))
	blocks.append(_spawn_block(
		4.0, 3.0, Color(0.55, 0.65, 0.88, 1.0),
		_poses4(Vector2(30, 124), Vector2(36, 118), Vector2(32, 120), Vector2(30, 120))
	))
	blocks.append(_spawn_block(
		6.0, 1.0, Color(0.58, 0.68, 0.90, 1.0),
		_poses4(Vector2(40, 120), Vector2(40, 114), Vector2(44, 118), Vector2(40, 112))
	))

	blocks.append(_spawn_block(
		8.0, 2.0, Color(0.55, 0.78, 0.78, 1.0),
		_poses4(Vector2(64, 110), Vector2(64, 132), Vector2(60, 108), Vector2(68, 112))
	))
	blocks.append(_spawn_block(
		10.0, 1.0, Color(0.50, 0.74, 0.76, 1.0),
		_poses4(Vector2(56, 100), Vector2(68, 88), Vector2(62, 96), Vector2(70, 92))
	))
	blocks.append(_spawn_block(
		2.0, 6.0, Color(0.48, 0.70, 0.74, 1.0),
		_poses4(Vector2(58, 104), Vector2(72, 100), Vector2(64, 102), Vector2(58, 98))
	))

	blocks.append(_spawn_block(
		3.0, 2.0, Color(0.64, 0.74, 0.86, 1.0),
		_poses4(Vector2(104, 106), Vector2(96, 100), Vector2(104, 100), Vector2(96, 90))
	))
	blocks.append(_spawn_block(
		3.0, 2.0, Color(0.64, 0.74, 0.86, 1.0),
		_poses4(Vector2(122, 100), Vector2(122, 106), Vector2(122, 100), Vector2(130, 90))
	))
	blocks.append(_spawn_block(
		12.0, 1.0, Color(0.62, 0.72, 0.84, 1.0),
		_poses4(Vector2(90, 108), Vector2(130, 108), Vector2(110, 94), Vector2(110, 86)),
		[Vector2(-60, -12), Vector2(0, -12), Vector2(60, -12)]
	))
	blocks.append(_spawn_block(
		5.0, 4.0, Color(0.58, 0.68, 0.82, 1.0),
		_poses4(Vector2(110, 108), Vector2(104, 108), Vector2(140, 108), Vector2(140, 108))
	))

	blocks.append(_spawn_block(
		16.0, 1.0, Color(0.74, 0.66, 0.84, 1.0),
		_poses4(Vector2(148, 54), Vector2(148, 42), Vector2(148, 70), Vector2(148, 50)),
		[Vector2(-72, -12), Vector2(0, -12), Vector2(72, -12)]
	))
	blocks.append(_spawn_block(
		6.0, 3.0, Color(0.70, 0.62, 0.80, 1.0),
		_poses4(Vector2(140, 58), Vector2(140, 50), Vector2(144, 56), Vector2(136, 54))
	))
	blocks.append(_spawn_block(
		8.0, 1.0, Color(0.72, 0.64, 0.82, 1.0),
		_poses4(Vector2(168, 56), Vector2(168, 70), Vector2(164, 54), Vector2(168, 52))
	))

	blocks.append(_spawn_block(
		7.0, 2.0, Color(0.86, 0.64, 0.52, 1.0),
		_poses4(Vector2(188, 48), Vector2(188, 36), Vector2(184, 46), Vector2(188, 48))
	))
	blocks.append(_spawn_block(
		9.0, 1.0, Color(0.84, 0.60, 0.50, 1.0),
		_poses4(Vector2(210, 48), Vector2(210, 40), Vector2(206, 42), Vector2(230, 40))
	))
	blocks.append(_spawn_block(
		4.0, 1.0, Color(0.82, 0.56, 0.46, 1.0),
		_poses4(Vector2(196, 52), Vector2(196, 44), Vector2(200, 44), Vector2(196, 56))
	))

	blocks.append(_spawn_block(
		11.0, 1.0, Color(0.72, 0.82, 0.92, 1.0),
		_poses4(Vector2(232, 30), Vector2(232, 38), Vector2(232, 34), Vector2(232, 20))
	))
	blocks.append(_spawn_block(
		5.0, 1.0, Color(0.68, 0.78, 0.90, 1.0),
		_poses4(Vector2(240, 36), Vector2(240, 36), Vector2(236, 28), Vector2(240, 36))
	))
	blocks.append(_spawn_block(
		3.0, 8.0, Color(0.64, 0.74, 0.88, 1.0),
		_poses4(Vector2(224, 40), Vector2(224, 30), Vector2(220, 40), Vector2(228, 40)),
		[Vector2(0, -96), Vector2(0, -48)]
	))
	blocks.append(_spawn_block(
		6.0, 1.0, Color(0.66, 0.76, 0.90, 1.0),
		_poses4(Vector2(244, 36), Vector2(244, 36), Vector2(244, 36), Vector2(240, 34))
	))

	return blocks


func _spawn_block(
	width: float,
	height: float,
	tint: Color,
	poses4: Array[Vector2],
	hooks: Array[Vector2] = []
) -> ShiftingBlock:
	var block: ShiftingBlock = SHIFTING_BLOCK_SCENE.instantiate()
	block.configure(poses4, width, tint, height)
	_shifting_root.add_child(block)
	for hook_offset in hooks:
		var hook: Node2D = HOOK_POINT_SCENE.instantiate()
		hook.position = hook_offset
		block.add_child(hook)
	return block


func _spawn_bay_hazards() -> void:
	_paint_spike_strip(30, 40, LAVA_ROW - 1)
	_paint_spike_strip(60, 72, LAVA_ROW - 1)
	_paint_spike_strip(108, 118, LAVA_ROW - 1)
	_paint_spike_strip(204, 212, LAVA_ROW - 1)
	_spawn_toxic_pit(_surface(66.0, 134.0))
	_spawn_fire_orb(_surface(106.0, 90.0), _surface(122.0, 90.0), 2.0)
	_spawn_fire_orb(_surface(148.0, 48.0), _surface(162.0, 48.0), 2.5)


func _paint_spike_strip(start_col: int, end_col: int, row: int) -> void:
	for col in range(start_col, end_col):
		_spawn_spike(_surface(float(col), float(row)))


func _spawn_toxic_pit(pos: Vector2) -> void:
	var toxic: ToxicZone = TOXIC_SCENE.instantiate()
	toxic.position = pos
	_objects.add_child(toxic)


func _spawn_parkour_props() -> void:
	_spawn_pogo_pad(_surface(22.0, 128.0))

	# Stable ladder tower landings (spawn bay)
	_paint_ground(16, 25, 112)
	_paint_ground(16, 25, 96)
	_spawn_ladder(_surface(20.0, 128.0), 10)
	_spawn_ladder(_surface(20.0, 112.0), 14)
	_spawn_ladder(_surface(20.0, 96.0), 12)

	_spawn_ladder(_surface(34.0, 112.0), 10)
	_spawn_moving_platform(_surface(36.0, 112.0), _surface(40.0, 112.0), 1.7)

	_spawn_hook_point(_surface(50.0, 108.0))
	_spawn_hook_point(_surface(54.0, 104.0))
	_spawn_crumbling_platform(_surface(72.0, 104.0))
	_spawn_crumbling_platform(_surface(76.0, 100.0))
	_spawn_moving_platform(_surface(82.0, 102.0), _surface(88.0, 102.0), 2.0)

	_spawn_hook_point(_surface(104.0, 90.0))
	_spawn_moving_platform(_surface(108.0, 94.0), _surface(118.0, 94.0), 2.4)
	_spawn_crumbling_platform(_surface(126.0, 92.0))

	_spawn_hook_point(_surface(138.0, 56.0))
	_spawn_hook_point(_surface(148.0, 44.0))
	_spawn_hook_point(_surface(162.0, 52.0))
	_spawn_moving_platform(_surface(154.0, 58.0), _surface(168.0, 58.0), 2.6)
	_spawn_crumbling_platform(_surface(170.0, 54.0))

	_spawn_crumbling_platform(_surface(194.0, 44.0))
	_spawn_crumbling_platform(_surface(202.0, 42.0))
	_spawn_moving_platform(_surface(206.0, 40.0), _surface(214.0, 40.0), 2.1)

	for col in range(256, 261):
		_spawn_crumble_block(_surface(float(col), 22.0) + Vector2(0.0, -9.0))


func _spawn_traps() -> void:
	var plate: PressurePlate = PRESSURE_PLATE_SCENE.instantiate()
	plate.position = _surface(52.0, 112.0)
	_objects.add_child(plate)

	var trap: SpikeTrap = SPIKE_TRAP_SCENE.instantiate()
	trap.position = _surface(62.0, float(LAVA_ROW - 1))
	_objects.add_child(trap)
	plate.activated.connect(func(_p: PressurePlate) -> void: trap.trigger())


func _spawn_spike(pos: Vector2) -> void:
	var spike: SpikeHazard = SPIKE_SCENE.instantiate()
	spike.position = pos
	_objects.add_child(spike)


func _spawn_fire_orb(start: Vector2, end: Vector2, duration: float) -> void:
	var orb: FireOrb = FIRE_ORB_SCENE.instantiate()
	orb.point_a = start
	orb.point_b = end
	orb.travel_duration = duration
	orb.position = start
	_objects.add_child(orb)


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


func _spawn_ladder(pos: Vector2, height_tiles: int) -> void:
	LadderFactory.spawn(_objects, pos, height_tiles)


func _spawn_pogo_pad(pos: Vector2) -> void:
	var pad: Node2D = POGO_PAD_SCENE.instantiate()
	pad.position = pos
	_objects.add_child(pad)


func _spawn_crumble_block(pos: Vector2) -> void:
	var block: Node2D = CRUMBLE_BLOCK_SCENE.instantiate()
	block.position = pos
	_objects.add_child(block)


func _spawn_checkpoints() -> void:
	_spawn_checkpoint(_surface(14.0, 128.0), 0)
	_spawn_checkpoint(_surface(48.0, 112.0), 1)
	_spawn_checkpoint(_surface(86.0, 96.0), 2)
	_spawn_checkpoint(_surface(126.0, 78.0), 3)
	_spawn_checkpoint(_surface(167.0, 58.0), 4)
	_spawn_checkpoint(_surface(209.0, 40.0), 5)


func _spawn_checkpoint(pos: Vector2, id: int) -> void:
	var cp: Area2D = CHECKPOINT_SCENE.instantiate()
	cp.position = pos
	cp.checkpoint_id = id
	_objects.add_child(cp)


func _spawn_freeze_anchors() -> void:
	_spawn_freeze_anchor(_surface(18.0, 128.0))
	_spawn_freeze_anchor(_surface(86.0, 96.0))
	_spawn_freeze_anchor(_surface(167.0, 58.0))
	_spawn_freeze_anchor(_surface(209.0, 40.0))


func _spawn_freeze_anchor(pos: Vector2) -> void:
	var anchor: Area2D = FREEZE_ANCHOR_SCENE.instantiate()
	anchor.position = pos + Vector2(0.0, -36.0)
	_objects.add_child(anchor)


func _spawn_shift_triggers() -> void:
	_spawn_shift_trigger(_surface(26.0, 128.0), &"leave_spawn")
	_spawn_shift_trigger(_surface(54.0, 112.0), &"leave_cp1")
	_spawn_shift_trigger(_surface(92.0, 96.0), &"leave_cp2")
	_spawn_shift_trigger(_surface(132.0, 78.0), &"leave_cp3")
	_spawn_shift_trigger(_surface(174.0, 58.0), &"leave_cp4")
	_spawn_shift_trigger(_surface(216.0, 40.0), &"leave_cp5")


func _spawn_shift_trigger(pos: Vector2, source: StringName) -> void:
	var trigger: ShiftTriggerZone = SHIFT_TRIGGER_SCENE.instantiate()
	trigger.position = pos + Vector2(0.0, -18.0)
	trigger.source_name = source
	_objects.add_child(trigger)


func _spawn_goal() -> void:
	var goal: Node2D = GOAL_SCENE.instantiate()
	goal.position = _surface(260.0, 22.0) + Vector2(0.0, -18.0)
	_objects.add_child(goal)
