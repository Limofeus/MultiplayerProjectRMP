extends DialogueTextBlock
class_name DialogueUselessChoiceBlock

@export var useless_choices : Array[String] = []

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	super()
	dialogue_sequence.set_choice_options(useless_choices)

func block_end(_dialogue_parameters : Dictionary = {}) -> void:
	super()
	var empty_str_arr : Array[String] = []
	dialogue_sequence.set_choice_options(empty_str_arr)

func block_action(_action_name : String, _dialogue_parameters : Dictionary = {}) -> void:
	dialogue_sequence.next_block(_dialogue_parameters) #Only for sync pass?..