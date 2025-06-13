extends Node
class_name DialogueSequencesLoader #way to localize dialogue sequences

@export var dialogue_sequence_folder : String = "res://resources/dialogue sequences/"
var dialogue_sequences : Dictionary = {}

func prepare_dialogue_sequences(language_key : String) -> void:
	dialogue_sequences = {}