extends DialogueBlock
class_name DialogueJumpToBlock

@export var jump_index : int = 0

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	if _sync_pass:
		dialogue_sequence.jump_to_block(jump_index, _dialogue_parameters)