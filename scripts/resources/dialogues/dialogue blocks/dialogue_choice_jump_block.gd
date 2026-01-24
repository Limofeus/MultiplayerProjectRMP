extends DialogueTextBlock
class_name DialogueChoiceJumpBlock

@export var choice_options : Array[String] = []
@export var jump_indices : Array[int] = []

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	super()
	dialogue_sequence.set_choice_options(choice_options)

func block_end(_dialogue_parameters : Dictionary = {}) -> void:
	super()
	var empty_str_arr : Array[String] = []
	dialogue_sequence.set_choice_options(empty_str_arr)

func block_action(_action_name : String, _dialogue_parameters : Dictionary = {}) -> void:
	if _action_name.begins_with("dialogue_choice_selected_"):
		var jump_index : int = jump_indices[int(_action_name.replace("dialogue_choice_selected_", ""))]
		dialogue_sequence.jump_to_block(jump_index, _dialogue_parameters)