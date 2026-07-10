class_name ToxicZone
extends HazardZone


func _ready() -> void:
	damage_mode = DamageMode.DOT
	damage_per_second = 40.0
	lethal_after_seconds = 2.2
	super._ready()
	add_to_group("toxic_zone")
