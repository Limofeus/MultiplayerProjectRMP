extends Resource
class_name StatField

@export var stat_name : String

var stat_bearer : StatBearer = null

var stat_modifier_stack : Array[StatModifier] = []

func set_stat_bearer(new_stat_bearer : StatBearer) -> void:
	stat_bearer = new_stat_bearer

func get_stat_value(_referred_stat_name : String = "") -> Variant:
	return null

func add_stat_modifier(stat_modifier : StatModifier) -> void:
	stat_modifier_stack.push_back(stat_modifier)

func remove_stat_modifier(stat_modifier : StatModifier) -> void:
	stat_modifier_stack.erase(stat_modifier)

func clear_stat_modifiers() -> void:
	stat_modifier_stack.clear()