class_name FreezeAnchor
extends Area2D

@export var hold_duration: float = 0.2

var _player_inside: bool = false
var _hold_timer: float = 0.0
var _frozen_by_anchor: bool = false
var _controller: ShiftingMapController


func _ready() -> void:
	add_to_group("freeze_anchor")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	call_deferred("_bind_controller")


func _bind_controller() -> void:
	_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController


func _process(delta: float) -> void:
	if _controller == null:
		_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController
		if _controller == null:
			return

	if not _player_inside:
		if _frozen_by_anchor:
			_controller.request_unfreeze()
			_frozen_by_anchor = false
		_hold_timer = 0.0
		return

	if not Input.is_action_pressed("interact"):
		if _frozen_by_anchor:
			_controller.request_unfreeze()
			_frozen_by_anchor = false
		_hold_timer = 0.0
		return

	_hold_timer += delta
	if _hold_timer >= hold_duration and not _frozen_by_anchor:
		if _controller.request_freeze():
			_frozen_by_anchor = true


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_inside = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_inside = false
