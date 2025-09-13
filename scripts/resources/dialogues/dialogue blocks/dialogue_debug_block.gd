extends DialogueBlock
class_name DialogueDebugBlock

func init_block(_dialogue_parameters : Dictionary = {}) -> void:
	debug_print_parameters("init_block", _dialogue_parameters)

func block_action(action_name : String, _dialogue_parameters : Dictionary = {}) -> void: #Like selecting a dialogue option
	debug_print_parameters("block_action", _dialogue_parameters)

func lock_next_block(_dialogue_parameters : Dictionary = {}) -> bool:
	return false

func dialogue_parameters_changed(_dialogue_parameters : Dictionary = {}, _current_block : bool = false) -> void:
	debug_print_parameters("parameters_changed", _dialogue_parameters)

func requires_sync() -> bool:
	return sync_dialogue_block

func sync_parameter_keys() -> Array:
	return []

func block_start(_dialogue_parameters : Dictionary = {}) -> void:
	print("------ DIALOGUE DEBUG BLOCK START ------")
	debug_print_parameters("block_start", _dialogue_parameters)

func block_end(_dialogue_parameters : Dictionary = {}) -> void:
	debug_print_parameters("block_end", _dialogue_parameters)
	print("------ DIALOGUE DEBUG BLOCK END ------")

func debug_print_parameters(debug_name : String, dialogue_parameters : Dictionary = {}) -> void:
	print(debug_name)
	print("  >", dialogue_parameters)
	print("---")
