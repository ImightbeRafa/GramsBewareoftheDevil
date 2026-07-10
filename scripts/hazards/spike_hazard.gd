class_name SpikeHazard
extends HazardZone


func _ready() -> void:
	damage_mode = DamageMode.INSTANT_KILL
	super._ready()
	add_to_group("spike_hazard")
