extends CreatureMovementState

func check_conditions():
	return movement_input_interface.get_dash_input() and creature_attributes.character_body.is_on_floor()
