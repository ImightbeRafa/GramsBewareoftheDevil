class_name ShiftTriggerZone
extends Area2D

@export var trigger_once: bool = true
@export var source_name: StringName = &"trigger"

var _triggered: bool = false
var _controller: ShiftingMapController


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	call_deferred("_bind_controller")


func _bind_controller() -> void:
	_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return
	if trigger_once and _triggered:
		return
	if _controller == null:
		_controller = get_tree().get_first_node_in_group("shifting_map_controller") as ShiftingMapController
	if _controller == null:
		return
	if not _controller.request_shift(source_name):
		return
	_triggered = true
