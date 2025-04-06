extends Control
class_name MenuButtonHoverRect

@export var hover_size : float = 61.0
@export var lerp_power : float = 25.0

var cur_pos_target : float = 0.0
var cur_size_target : float = 0.0

var deselected : bool = true

func _process(_delta):
	position.y = lerp(position.y, cur_pos_target, lerp_power * _delta)
	size.y = lerp(size.y, cur_size_target, lerp_power * _delta)

func set_pos_target(target):
	print("set_pos_target")
	if deselected:
		position.y = target
		deselected = false
	cur_pos_target = target
	cur_size_target = hover_size

func deselect():
	print("deselect")
	deselected = true
	cur_size_target = 0.0