extends Node
class_name DialogueSequencesLoader #way to localize dialogue sequences

@export var dialogue_sequence_folder : String = "res://resources/dialogue sequences/"
var dialogue_sequences : Dictionary = {}

func _ready():
	prepare_dialogue_sequences("en")
	DialogueSequencesLoaderInstance.log_dialogue_sequences()

func prepare_dialogue_sequences(language_key : String) -> void:
	dialogue_sequences = {}
	var dialogue_resource_paths := StaticUtility.get_all_file_paths(dialogue_sequence_folder)
	for dialogue_resource_path in dialogue_resource_paths:
		parse_dialogue_sequence(dialogue_resource_path, language_key)

func parse_dialogue_sequence(dialogue_resource_path : String, language_key : String) -> void:
	var dialogue_resource : DialogueSequence = load(dialogue_resource_path)
	if dialogue_resource.sequence_lang_key == language_key:
		dialogue_sequences[dialogue_resource.sequence_name] = dialogue_resource

func log_dialogue_sequences() -> void:
	print("PREPARING DIALOGUE SEQUENCES...")
	for sequence_name in dialogue_sequences.keys():
		print("NAME: ", sequence_name, ", PATH: ", dialogue_sequences[sequence_name].resource_path)

func get_dialogue_sequence(sequence_name : String) -> DialogueSequence:
	return dialogue_sequences[sequence_name]
