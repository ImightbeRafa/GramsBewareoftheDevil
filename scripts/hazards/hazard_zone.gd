extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var controller: Node = get_tree().get_first_node_in_group("level_controller")
		if controller != null and controller.has_method("is_playing") and not controller.is_playing():
			return
		if body.has_method("die"):
			body.die()
		elif controller != null and controller.has_method("on_player_died"):
			controller.on_player_died()
		else:
			get_tree().reload_current_scene()
