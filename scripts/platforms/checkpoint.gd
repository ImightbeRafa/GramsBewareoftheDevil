extends Area2D

signal checkpoint_reached(checkpoint_id: int)

@export var checkpoint_id: int = 0


func _ready() -> void:
	add_to_group("checkpoint")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.set_checkpoint(global_position, checkpoint_id)
		checkpoint_reached.emit(checkpoint_id)
