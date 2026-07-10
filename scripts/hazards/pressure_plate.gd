class_name PressurePlate
extends Area2D

signal activated(plate: PressurePlate)

@export var one_shot: bool = true
@export var requires_player_weight: bool = true

var _triggered: bool = false


func _ready() -> void:
	add_to_group("pressure_plate")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func reset_plate() -> void:
	_triggered = false
	modulate = Color.WHITE


func _on_body_entered(body: Node2D) -> void:
	if requires_player_weight and not (body is Player):
		return
	if one_shot and _triggered:
		return
	_triggered = true
	modulate = Color(0.7, 1.0, 0.7, 1.0)
	activated.emit(self)
