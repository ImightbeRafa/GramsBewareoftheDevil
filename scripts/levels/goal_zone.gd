extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var controller: Node = get_tree().get_first_node_in_group("level_controller")
		if controller != null and controller.has_method("on_goal_reached"):
			controller.on_goal_reached(body as Player)
