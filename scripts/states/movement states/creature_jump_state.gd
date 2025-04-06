extends CreatureMovementState
class_name CreatureJumpState

@export var jump_power : float = 10.0

func _on_enter()->void:
	creature_attributes.character_body.velocity += Vector3.UP * jump_power

func check_conditions():
	return movement_input_interface.get_jump_input()
