@icon("res://editor/custom script icons/dialogue/message-circle-plus.svg")
extends Node
class_name DialogueTrigger

@export var sequence_name : String = ""
@export var dialogue_priority : int = 0

signal start_dialogue(sequence_name : String, priority : int)

func fire_dialogue_trigger() -> void:
	print("Firing dialogue: ", sequence_name)
	print("A1 DT SIZE: ", start_dialogue.get_connections().size())
	start_dialogue.emit(sequence_name, dialogue_priority)