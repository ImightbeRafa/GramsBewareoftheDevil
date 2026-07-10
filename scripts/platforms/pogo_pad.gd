extends StaticBody2D


func _ready() -> void:
	add_to_group("pogo_surface")
	var color_rect := get_node_or_null("ColorRect") as ColorRect
	if color_rect != null:
		color_rect.queue_free()
	var sprite := PlatformVisual.create_surface_sprite(2.0)
	sprite.modulate = Color(0.6, 1.0, 0.7, 1.0)
	add_child(sprite)
