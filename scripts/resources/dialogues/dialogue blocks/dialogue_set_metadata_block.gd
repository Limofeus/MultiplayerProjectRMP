extends DialogueBlock
class_name DialogueSetMetadataBlock

@export var parameters_set_dictionary : Dictionary = {}

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	dialogue_sequence.set_dialogue_metadata(parameters_set_dictionary)
	if _sync_pass:
		dialogue_sequence.next_block(_dialogue_parameters)