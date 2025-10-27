extends Node
class_name DialogueWindowElement

@export var dialogue_window_visual : DialogueWindowVisual = null

@export var bound_metadata_entry : String = ""

var cached_bound_entry_value : Variant = null

func _ready():
	if dialogue_window_visual != null:
		dialogue_window_visual.dialogue_metadata_updated.connect(dialogue_metadata_updated)
	else:
		print("No dialogue window visual set for ", self.name)

func dialogue_metadata_updated(metadata : Dictionary) -> void:
	if metadata.has(bound_metadata_entry):
		bound_entry_updated(metadata[bound_metadata_entry])

func bound_entry_updated(new_value : Variant) -> void:
	if cached_bound_entry_value != new_value:
		cached_bound_entry_value = new_value
		bound_entry_changed(new_value)

func bound_entry_changed(_new_value : Variant) -> void:
	pass
