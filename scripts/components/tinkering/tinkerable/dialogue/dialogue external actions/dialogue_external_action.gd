extends Node
class_name DialogueExternalAction

@export var dialogue_updater : TinkerableDialogueUpdater

func _ready():
	dialogue_updater.external_action.connect(process_dialogue_action)

func process_dialogue_action(action_name : String, sync_arguments : Array[Variant]) -> void:
	pass