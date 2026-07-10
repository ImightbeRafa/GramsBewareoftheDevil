class_name CaneInput
extends RefCounted

## Shared cane input — left click (and J fallback) via the "cane" action.


static func is_use_pressed() -> bool:
	return Input.is_action_pressed("cane")


static func is_use_just_pressed() -> bool:
	return Input.is_action_just_pressed("cane")


static func is_use_just_released() -> bool:
	return Input.is_action_just_released("cane")
