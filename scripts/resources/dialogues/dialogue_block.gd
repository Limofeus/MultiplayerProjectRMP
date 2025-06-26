extends Resource
class_name DialogueBlock

var dialogue_sequence : DialogueSequence

func init_block(_dialogue_parameters : Dictionary = {}) -> void:
	pass

func block_action(action_name : String, _dialogue_parameters : Dictionary = {}) -> void: #Like selecting a dialogue option
	pass

func lock_next_block(_dialogue_parameters : Dictionary = {}) -> bool:
	return false

func dialogue_parameters_changed(_dialogue_parameters : Dictionary = {}) -> void:
	pass

func block_start(_dialogue_parameters : Dictionary = {}) -> void:
	pass

func block_end(_dialogue_parameters : Dictionary = {}) -> void:
	pass