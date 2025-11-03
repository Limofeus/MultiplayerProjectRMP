@tool
extends Node


@export_tool_button("Generate", "Callable") var generate_actual_resource = generate_dialogue_sound_mapping
@export var quick_dialogue_symbol_sound_mapping : DialogueSymbolSoundsMapping = null
@export var resource_save_path : String = "res://resources/dialogue symbol sound mappings/"
@export var resource_file_name : String = "dialogue_symbol_sound_mapping"

func generate_dialogue_sound_mapping():
	var output_symbol_sound_mapping : DialogueSymbolSoundsMapping = DialogueSymbolSoundsMapping.new()
	for entry in quick_dialogue_symbol_sound_mapping.sound_symbol_dictionary.keys():
		for symbol in entry:
			output_symbol_sound_mapping.sound_symbol_dictionary[symbol] = quick_dialogue_symbol_sound_mapping.sound_symbol_dictionary[entry].duplicate()

	ResourceSaver.save(output_symbol_sound_mapping, resource_save_path + resource_file_name + ".res")