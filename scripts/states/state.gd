extends Node
class_name State

@export var next_states : Array[State]

func _on_enter() -> void:
    pass

func _on_exit() -> void:
    pass

func _on_update(_delta : float) -> void:
    pass

func _on_physics_update(_delta : float) -> void:
    pass

func check_conditions() -> bool:
    return true

func state_locked() -> bool:
    return false