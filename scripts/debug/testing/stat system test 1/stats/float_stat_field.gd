extends StatField
class_name FloatStatField

@export var default_value : float = 1.0

func get_stat_value(_referred_stat_name : String = "") -> float:
	#Apply modifier stack somewhere around here
	return default_value