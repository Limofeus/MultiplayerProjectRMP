extends DialogueBlock
class_name DialogueFocusBranchingBlock

@export var focused_jump_index : int = 0
@export var unfocused_jump_index : int = 0

func block_start(_dialogue_parameters : Dictionary = {}) -> void:
	print("Params: ", _dialogue_parameters)
	if _dialogue_parameters["has_focused_tinkerer"]:
		dialogue_sequence.jump_to_block(focused_jump_index)
	else:
		dialogue_sequence.jump_to_block(unfocused_jump_index)

func sync_parameter_keys() -> Array:
	print("Sync params requested")
	return ["has_focused_tinkerer"]
