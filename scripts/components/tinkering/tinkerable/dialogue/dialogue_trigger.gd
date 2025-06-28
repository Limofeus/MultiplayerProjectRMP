extends Node
class_name DialogueTrigger

@export var sequence_name : String = ""
@export var dialogue_priority : int = 0

signal start_dialogue(sequence_name : String, priority : int)

func fire_dialogue_trigger() -> void:
	start_dialogue.emit(sequence_name, dialogue_priority)