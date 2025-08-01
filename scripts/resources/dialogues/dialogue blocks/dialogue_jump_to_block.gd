extends DialogueBlock
class_name DialogueJumpToBlock

@export var jump_index : int = 0

func block_start(_dialogue_parameters : Dictionary = {}) -> void:
	dialogue_sequence.jump_to_block(jump_index)