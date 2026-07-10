class_name SpikeTrap
extends Node2D

@export var rise_distance: float = 36.0
@export var rise_duration: float = 0.25
@export var stay_up_duration: float = 2.5

var _hazard: SpikeHazard
var _rest_y: float = 0.0
var _active: bool = false
var _tween: Tween


func _ready() -> void:
	_hazard = $SpikeHazard as SpikeHazard
	_rest_y = _hazard.position.y
	_hazard.set_deferred("monitoring", false)
	_hazard.visible = false


func trigger() -> void:
	if _active:
		return
	_active = true
	_hazard.visible = true
	_hazard.position.y = _rest_y + rise_distance
	_hazard.set_deferred("monitoring", true)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_hazard, "position:y", _rest_y, rise_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(stay_up_duration)
	_tween.tween_property(_hazard, "position:y", _rest_y + rise_distance, rise_duration * 0.8)
	_tween.tween_callback(_on_trap_finished)


func _on_trap_finished() -> void:
	_hazard.set_deferred("monitoring", false)
	_hazard.visible = false
	_active = false
