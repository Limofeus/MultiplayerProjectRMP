@tool # Make it run in editor (might need to close and reopen scene to work)
extends WorldEnvironment # We're modifying the sky material that is on a WorldEnvironment, so extend from there.

@export var sun_node : Node3D
@export var moon_1_node : Node3D
@export var moon_2_node : Node3D

func _process(delta: float) -> void:
	var sun_dir = sun_node.get_global_transform().basis.z
	var moon_1_dir = moon_1_node.get_global_transform().basis.z
	var moon_2_dir = moon_2_node.get_global_transform().basis.z
	environment.sky.sky_material.set_shader_parameter('sun_dir', sun_dir)
	environment.sky.sky_material.set_shader_parameter('moon_1_dir', moon_1_dir)
	environment.sky.sky_material.set_shader_parameter('moon_2_dir', moon_2_dir)