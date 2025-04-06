extends EntityComponent

@export var head_node : Node3D
@export var look_node : Node3D
@export var mouse_sensitivity : float = 0.001

var horizontal_rotation = 0.0
var vertical_rotation = 0.0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		horizontal_rotation += -event.relative.x * mouse_sensitivity
		vertical_rotation += -event.relative.y * mouse_sensitivity
		var rotation_quaternion_horizontal = Quaternion(0.0, sin(horizontal_rotation), 0.0, cos(horizontal_rotation))
		var rotation_quaternion_vertical = Quaternion(sin(vertical_rotation), 0.0, 0.0, cos(vertical_rotation))
		head_node.quaternion = rotation_quaternion_horizontal
		look_node.quaternion = rotation_quaternion_vertical