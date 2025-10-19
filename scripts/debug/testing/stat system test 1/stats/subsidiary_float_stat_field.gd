extends FloatStatField
class_name SubsidiaryFloatStatField

@export var parent_stat_name : String = "_default_stat"

func get_stat_value(_referred_stat_name : String = "") -> float:
	#Apply modifier stack somewhere around here
	return (default_value * stat_bearer.get_stat_value(parent_stat_name))