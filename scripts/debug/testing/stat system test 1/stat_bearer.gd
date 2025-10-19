extends Node
class_name StatBearer

@export var initial_stat_fields : Array[StatField] = []

var stat_dictionary : Dictionary[String, StatField] = {}

func _ready() -> void:
	for stat_field in initial_stat_fields:
		add_stat_field(stat_field)


func add_stat_field(stat_field : StatField) -> void:
	var stat_field_copy = stat_field.duplicate()
	stat_dictionary[stat_field.stat_name] = stat_field_copy
	stat_field_copy.set_stat_bearer(self)

func remove_stat_field(stat_name : String) -> void:
	stat_dictionary.erase(stat_name)


func get_stat_value(stat_name : String) -> Variant:
	if stat_name == "_default_stat": #Idk, just for better debugging I guess
		return 1.0
	return stat_dictionary[stat_name].get_stat_value(stat_name)

func get_stat_field(stat_name : String) -> StatField:
	return stat_dictionary[stat_name]


func add_stat_modifier(stat_name : String, stat_modifier : StatModifier) -> void:
	stat_dictionary[stat_name].add_stat_modifier(stat_modifier)

func remove_stat_modifier(stat_name : String, stat_modifier : StatModifier) -> void: #Needs exact modifier reference, find some other ways to remove modifiers later maybe
	stat_dictionary[stat_name].remove_stat_modifier(stat_modifier)

func clear_stat_modifiers(stat_name : String) -> void:
	stat_dictionary[stat_name].clear_stat_modifiers()