extends Node

@export var base_fov : float = 105.0 #TODO: MOVE TO SOME OTHER PLACE LATER (like player settings or something)

@export var camera_node : Camera3D
@export var camera_rig_node : Node3D
@export var speedlines_material : ShaderMaterial
@export var tilt_speed : float = 25.0
@export var speed_tilt_affection : float = 0.2
@export var max_tilt_angle : float = 0.05

@export var fov_change_speed : float = 20.0
@export var speed_fov_affection : float = 0.1
@export var max_fov_change : float = 10.0

@export var vertical_velocity_power_factor = 0.3
@export var minimum_power_to_show_speedlines = 10.0
@export var power_to_alpha = 0.06

@export var minimum_speedlines_speed = 0.05
@export var max_speedlines_speed = 0.2
@export var power_to_speedlines_speed = 0.002

var saved_z_angle : float = 0.0
var saved_fov_addition : float = 0.0
var speedlines_scroll_position : float = 0.0

func update_movement_effects(movement_vector : Vector3, delta : float) -> void:
	var normalized_movement_vector = movement_vector.normalized()

	var look_vector : Vector3 = camera_rig_node.global_transform.basis.z

	var camera_right_vector : Vector3 = camera_rig_node.global_transform.basis.x
	var camera_up_vector : Vector3 = camera_rig_node.global_transform.basis.y

	#Old code (works bad!)
	"""
	var flat_camera_vector : Vector3 = Vector3(look_vector.x, 0.0, look_vector.z).normalized()
	if(camera_up_vector.y < 0.0):
		flat_camera_vector = -flat_camera_vector

	var flat_movement_vector : Vector3 = Vector3(movement_vector.x, 0.0, movement_vector.z).normalized()
	var flat_movement_vector_unnormalized : Vector3 = Vector3(movement_vector.x, 0.0, movement_vector.z)

	var movement_cross_product : Vector3 = movement_vector.cross(Vector3.UP)

	var movement_x_angle_to : float = -Vector3.UP.signed_angle_to(movement_vector, movement_cross_product) - (PI / 2.0)
	var look_x_angle_to : float = flat_camera_vector.signed_angle_to(look_vector, camera_right_vector)
	var y_angle_to : float = flat_movement_vector.signed_angle_to(flat_camera_vector, Vector3.UP)

	var x_angle_to = movement_x_angle_to + look_x_angle_to

	DebugDraw2D.set_text("MV X A:", movement_x_angle_to)
	DebugDraw2D.set_text("L X A:", look_x_angle_to)
	DebugDraw2D.set_text("X A T:", x_angle_to)

	var camera_tilt_factor : float = (flat_camera_vector.signed_angle_to(-flat_movement_vector, Vector3.UP) / (PI)) * 2.0
	if abs(camera_tilt_factor) > 1.0:
		camera_tilt_factor = (sign(camera_tilt_factor) * 2.0) - camera_tilt_factor
	DebugDraw2D.set_text("CAM TILT FACTOR:", camera_tilt_factor)
	

	var z_angle_to : float = StaticUtility.sample_sigmoid_zero_one(camera_tilt_factor * flat_movement_vector_unnormalized.length() * speed_tilt_affection) * max_tilt_angle
	
	if(flat_movement_vector_unnormalized.length() == 0.0):
		z_angle_to = 0.0

	saved_z_angle = StaticUtility.lerp_dampen(saved_z_angle, z_angle_to, tilt_speed, delta)

	camera_node.rotation = Vector3(0.0, 0.0, saved_z_angle)

	var angle_to_vector : Vector3 = Vector3(x_angle_to, y_angle_to, -saved_z_angle)
	"""

	normalized_movement_vector = -normalized_movement_vector

	var side_movement_factor : float = normalized_movement_vector.dot(camera_right_vector)
	var forward_movement_factor : float = normalized_movement_vector.dot(look_vector)

	var movement_vertical_projection : Vector3 = Plane(camera_right_vector).project(normalized_movement_vector).normalized()
	var x_angle_to : float = movement_vertical_projection.signed_angle_to(look_vector, camera_right_vector)
	var movement_horizontal_projection : Vector3 = Plane(camera_up_vector).project(normalized_movement_vector.rotated(camera_right_vector, x_angle_to)).normalized()
	var y_angle_to : float = movement_horizontal_projection.signed_angle_to(look_vector, camera_up_vector)

	y_angle_to = -y_angle_to
	if(abs(side_movement_factor) >= 1.0):
		x_angle_to = 0.0

	DebugDraw2D.set_text("X angle:", x_angle_to)
	DebugDraw2D.set_text("Y angle:", y_angle_to)
	DebugDraw2D.set_text("Side factor:", side_movement_factor)

	var z_angle_to : float = StaticUtility.sample_sigmoid_zero_one(movement_vector.length() * side_movement_factor * speed_tilt_affection) * max_tilt_angle
	var fov_change : float = StaticUtility.sample_sigmoid_zero_one(movement_vector.length() * forward_movement_factor * speed_fov_affection) * max_fov_change

	if(movement_vector.length() == 0.0):
		z_angle_to = 0.0
		fov_change = 0.0
		speedlines_scroll_position = 0.0

	saved_z_angle = StaticUtility.lerp_dampen(saved_z_angle, z_angle_to, tilt_speed, delta)
	saved_fov_addition = StaticUtility.lerp_dampen(saved_fov_addition, fov_change, fov_change_speed, delta)

	camera_node.rotation = Vector3(0.0, 0.0, saved_z_angle)
	camera_node.fov = base_fov + saved_fov_addition

	var angle_to_vector : Vector3 = Vector3(x_angle_to, y_angle_to, -saved_z_angle)
	# All above is to get direction, below is to get power of the speedlines shader

	var power : float = Vector3(movement_vector.x, movement_vector.y * vertical_velocity_power_factor, movement_vector.z).length()

	var speedlines_alpha : float = (power - minimum_power_to_show_speedlines) * power_to_alpha

	var speedlines_speed : float = (power * power_to_speedlines_speed) + minimum_speedlines_speed

	DebugDraw2D.set_text("Power:", power)
	DebugDraw2D.set_text("Speedlines speed:", speedlines_speed)

	speedlines_scroll_position += clamp(speedlines_speed, 0.0, max_speedlines_speed) * delta

	speedlines_material.set_shader_parameter("sphere_rotation_vector", angle_to_vector)
	speedlines_material.set_shader_parameter("finalizing_alpha", clamp(speedlines_alpha, 0.0, 1.0))
	speedlines_material.set_shader_parameter("scroll_position", speedlines_scroll_position)