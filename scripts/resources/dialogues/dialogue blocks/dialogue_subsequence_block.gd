extends DialogueBlock
class_name DialogueSubsequenceBlock

@export var subsequence : DialogueSequence

var has_subsequence_ended : bool = false

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	has_subsequence_ended = false
	subsequence.jump_start_at_block()
	subsequence.on_sequence_ended.connect(subsequence_ended)

func lock_next_block(_dialogue_parameters : Dictionary = {}) -> bool:
	subsequence.next_block()
	return !has_subsequence_ended

func connect_subsequence() -> void:
	if !subsequence.on_sequence_ended.is_connected(subsequence_ended):
		subsequence.on_sequence_ended.connect(subsequence_ended)

func subsequence_ended() -> void:
	has_subsequence_ended = true