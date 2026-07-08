extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var feedback := get_tree().get_first_node_in_group("goal_feedback") as Label
		if feedback != null:
			feedback.text = "Level Cleared!"
			feedback.visible = true
