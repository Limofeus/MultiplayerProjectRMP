extends Node
class_name StatBinder

@export var stat_bearer : StatBearer
@export var binding_target : Node

@export var binding_dictionary : Dictionary[String, String] = {}

func _ready() -> void:
	bind_stat_updates()

func bind_stat_updates() -> void:
	for stat_name in binding_dictionary.keys():
		bind_stat(stat_name, binding_dictionary[stat_name])

func bind_stat(stat_name : String, binding_name : String) -> void:
	stat_bearer.get_stat_field(stat_name).stat_changed.connect(update_bound_stat.bind(stat_name, binding_name))

func update_bound_stat(stat_name : String, binding_name : String) -> void:
	binding_target.set(binding_name, stat_bearer.get_stat_value(stat_name))