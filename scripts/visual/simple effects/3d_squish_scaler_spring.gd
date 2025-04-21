extends Node3D
class_name SquishScalerSpring

@export var spring_power : float = 0.1
@export var spring_freq : float = 30.0
@export var spring_damping : float = 0.5

var spring_target_value : float = 0.0
var spring_params : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)

func _process(delta):
	update_spring(delta)

func bump_spring_velocity(delta : float):
	spring_params.vel += delta

func update_spring(delta : float):
	SpringUtility.UpdateSpring(spring_params, spring_target_value, delta, spring_freq, spring_damping)
	var scale_change_val = spring_params.pos * spring_power
	scale = Vector3.ONE + (Vector3.UP * scale_change_val) - ((Vector3.RIGHT + Vector3.BACK) * scale_change_val)