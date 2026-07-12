class_name LadderZone
extends Area2D

var _height_tiles: int = 8

@export var height_tiles: int = 8:
	get:
		return _height_tiles
	set(value):
		_height_tiles = maxi(value, 2)
		if is_node_ready():
			_rebuild_collision()

@export var width_px: float = 38.0
@export var snap_offset: Vector2 = Vector2.ZERO
@export var top_mount_slack: float = 24.0

@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _visual: LadderVisual = $Visual


func _ready() -> void:
	add_to_group("ladder")
	z_index = 3
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_rebuild_collision()


func get_height_px() -> float:
	return float(_height_tiles * KenneyPlatformTiles.TILE_SIZE)


func get_snap_x() -> float:
	return global_position.x + snap_offset.x


func get_top_y() -> float:
	return global_position.y - get_height_px()


func get_bottom_y() -> float:
	return global_position.y


func get_climb_center_bounds() -> Vector2:
	var top_limit := get_top_y() + 14.0
	var bottom_limit := get_bottom_y() - 8.0
	return Vector2(top_limit, bottom_limit)


func get_grip_half_width() -> float:
	return (width_px + 14.0) * 0.5


func allows_mount_down(player_y: float, on_floor: bool) -> bool:
	if not on_floor:
		return true
	return player_y <= get_top_y() + top_mount_slack


func _rebuild_collision() -> void:
	if _collision == null:
		return
	var height_px := get_height_px()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width_px + 14.0, height_px)
	_collision.shape = shape
	_collision.position = Vector2(0.0, -height_px * 0.5)
	if _visual != null:
		_visual.rebuild(width_px, height_px)


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	var ability: LadderAbility = (body as Player).get_node_or_null("LadderAbility") as LadderAbility
	if ability != null:
		ability.register_zone(self)


func _on_body_exited(body: Node2D) -> void:
	if not (body is Player):
		return
	var ability: LadderAbility = (body as Player).get_node_or_null("LadderAbility") as LadderAbility
	if ability != null:
		ability.unregister_zone(self)
