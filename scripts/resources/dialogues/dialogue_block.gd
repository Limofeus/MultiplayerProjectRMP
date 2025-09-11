extends Resource
class_name DialogueBlock

enum ParameterSyncType {
	DISABLED,
	WHEN_CURRENT_BLOCK,
	ALWAYS
}

@export var sync_dialogue_block : bool = true

var dialogue_sequence : DialogueSequence

func init_block(_dialogue_parameters : Dictionary = {}) -> void:
	pass

func block_action(action_name : String, _dialogue_parameters : Dictionary = {}) -> void: #Like selecting a dialogue option
	pass

func lock_next_block(_dialogue_parameters : Dictionary = {}) -> bool:
	return false

func dialogue_parameters_changed(_dialogue_parameters : Dictionary = {}, _current_block : bool = false) -> void:
	pass

func requires_sync() -> bool:
	return sync_dialogue_block

func requires_action_sync() -> bool:
	return false

func requires_parameter_sync() -> ParameterSyncType:
	return ParameterSyncType.DISABLED

func sync_parameter_keys() -> Array:
	return []

func block_start(_dialogue_parameters : Dictionary = {}) -> void:
	pass

func block_end(_dialogue_parameters : Dictionary = {}) -> void:
	pass