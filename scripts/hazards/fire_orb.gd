class_name FireOrb
extends Node2D

@export var point_a: Vector2 = Vector2.ZERO
@export var point_b: Vector2 = Vector2(120.0, 0.0)
@export var travel_duration: float = 2.4
@export var wait_at_ends: float = 0.2

var _tween: Tween
var _hazard: HazardZone


func _ready() -> void:
	add_to_group("fire_orb")
	position = point_a
	_hazard = $HazardArea as HazardZone
	call_deferred("_start_movement")


func pause_for_shift(paused: bool) -> void:
	if _tween != null and _tween.is_valid():
		if paused:
			_tween.pause()
		else:
			_tween.play()


func _start_movement() -> void:
	_move_to_b()


func _move_to_b() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "position", point_b, travel_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(wait_at_ends)
	_tween.tween_callback(_move_to_a)


func _move_to_a() -> void:
	_tween = create_tween()
	_tween.tween_property(self, "position", point_a, travel_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_interval(wait_at_ends)
	_tween.tween_callback(_move_to_b)
