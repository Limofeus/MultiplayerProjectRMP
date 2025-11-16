extends DialogueBlock

@export var store_preset : Store = null

#TODO: get more time for this... hope soon I'll get time ror this
func block_start(_dialogue_parameters : Dictionary = {}, _sync_pass : bool = true) -> void:
	if !_sync_pass:
		return
	var store_model : Store = store_preset.duplicate()