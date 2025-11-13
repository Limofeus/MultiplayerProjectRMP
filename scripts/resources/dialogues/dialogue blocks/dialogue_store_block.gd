extends DialogueBlock

@export var store_preset : Store = null

func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	if !_sync_pass:
		return
	var store_model : Store = store_preset.duplicate()