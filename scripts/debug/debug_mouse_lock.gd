extends Node

@export var mouse_blocker : Control
var mouse_locked : bool = false

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_lock()
		
func toggle_lock() -> void:
	mouse_locked = !mouse_locked
	if mouse_locked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		mouse_blocker.visible = false
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		mouse_blocker.visible = true
