class_name MovingPlatform
extends AnimatableBody2D

@export var point_a: Vector2 = Vector2.ZERO
@export var point_b: Vector2 = Vector2(108.0, 0.0)
@export var travel_duration: float = 2.0
@export var wait_at_ends: float = 0.3

var _tween: Tween
var _at_b: bool = false


func _ready() -> void:
	add_to_group("moving_platform")
	_replace_visual()
	position = point_a
	call_deferred("_start_movement")


func _replace_visual() -> void:
	var color_rect := get_node_or_null("ColorRect") as ColorRect
	if color_rect != null:
		color_rect.queue_free()
	var sprite := PlatformVisual.create_surface_sprite(3.0)
	add_child(sprite)


func pause_for_shift(paused: bool) -> void:
	if _tween != null and _tween.is_valid():
		if paused:
			_tween.pause()
		else:
			_tween.play()


func _start_movement() -> void:
	_move_to_b()


func _move_to_b() -> void:
	_at_b = false
	_tween = create_tween()
	_tween.tween_property(self, "position", point_b, travel_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(wait_at_ends)
	_tween.tween_callback(_move_to_a)


func _move_to_a() -> void:
	_at_b = true
	_tween = create_tween()
	_tween.tween_property(self, "position", point_a, travel_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(wait_at_ends)
	_tween.tween_callback(_move_to_b)
