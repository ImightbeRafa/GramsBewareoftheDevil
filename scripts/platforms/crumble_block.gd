extends StaticBody2D


func _ready() -> void:
	add_to_group("crumble_block")


func on_smash_hit() -> void:
	queue_free()
