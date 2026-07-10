class_name ShiftingBlock
extends AnimatableBody2D

const WORLD_LAYER: int = 1

@export var width_tiles: float = 3.0
@export var height_tiles: float = 1.0
@export var block_tint: Color = Color(0.72, 0.68, 0.82, 1.0)

var _poses: Array[Vector2] = []
var _collision: CollisionShape2D
var _visual_root: Node2D
var _touchable: bool = true
var _active_tween: Tween
var _configured: bool = false


func _ready() -> void:
	add_to_group("shifting_block")
	for child in get_children():
		if child is CollisionShape2D:
			child.queue_free()
	_collision = null
	if _configured:
		_apply_visual()
	set_touchable(true)


func configure(
	poses: Array[Vector2],
	width: float,
	tint: Color = Color.WHITE,
	height: float = 1.0
) -> void:
	_poses = poses
	width_tiles = width
	height_tiles = height
	block_tint = tint
	_configured = true
	if is_node_ready():
		_apply_visual()
		if _poses.size() > 0:
			global_position = _poses[0]


func get_pose_count() -> int:
	return _poses.size()


func get_pose_position(layout_index: int) -> Vector2:
	if _poses.is_empty():
		return global_position
	var index := clampi(layout_index, 0, _poses.size() - 1)
	return _poses[index]


func snap_to_pose(layout_index: int) -> void:
	global_position = get_pose_position(layout_index)


func tween_to_pose(layout_index: int, duration: float) -> Tween:
	if _poses.is_empty():
		return null
	var index := clampi(layout_index, 0, _poses.size() - 1)
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(
		self,
		"global_position",
		_poses[index],
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	return _active_tween


func set_touchable(enabled: bool) -> void:
	_touchable = enabled
	collision_layer = WORLD_LAYER if enabled else 0
	if _collision != null:
		_collision.disabled = not enabled
	if _visual_root != null:
		_visual_root.visible = enabled
	modulate = block_tint
	for child in get_children():
		if child is CollisionObject2D:
			child.collision_layer = WORLD_LAYER if enabled else 0
			if child is Area2D:
				child.monitoring = enabled


func is_touchable() -> bool:
	return _touchable


func _apply_visual() -> void:
	if _visual_root != null:
		_visual_root.queue_free()
		_visual_root = null
	_build_visual()


func _build_visual() -> void:
	_visual_root = Node2D.new()
	add_child(_visual_root)

	var tile_size := float(KenneyPlatformTiles.TILE_SIZE)
	var width_px := width_tiles * tile_size
	var height_px := height_tiles * tile_size

	var platform := PlatformVisual.build_platform_node(
		width_tiles,
		height_tiles,
		block_tint.lightened(0.04)
	)
	_visual_root.add_child(platform)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(width_px, height_px)
	if _collision == null:
		_collision = CollisionShape2D.new()
		add_child(_collision)
	_collision.position = Vector2(0.0, -height_px * 0.5)
	_collision.shape = shape
