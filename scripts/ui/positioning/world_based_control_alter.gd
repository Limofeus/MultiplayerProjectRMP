extends Node
class_name WorldBasedControlAlter
#Moves, scales and changes transparency of UI nodes based on world position

@export_group("Node References")
@export var target_position_node : Node3D = null
@export var control_to_reposition : Control = null
@export var size_ref_container : Container = null #Used to position the control so that the container will always stay on screen

@export_group("Distance Settings")
@export var max_distance : float = 50.0
@export var distance_to_scale_curve : Curve = null
@export var distance_to_transparency_curve : Curve = null

@export_group("Spring Damper Settings")
@export var spring_dampening : float = 1.0
@export var spring_freq : float = 10.0
@export var lerp_factor_activation_speed : float = 3.0

var target_viewport : Viewport = null
var target_camera : Camera3D = null

var x_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
var y_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)

var lerp_factor : float = 0.0

func _ready() -> void:
	process_priority = 1 #NOTICE: To make sure this updates after all player movement (Though maybe better to set it manually for whole object)
	prepare_displays()


func _process(delta):
	var viewport_size = target_viewport.get_visible_rect().size

	var dist_factor = clampf(get_distance_to_target() / max_distance, 0.0, 1.0)
	var distance_to_scale = distance_to_scale_curve.sample(dist_factor)
	var distance_to_transparency = distance_to_transparency_curve.sample(dist_factor)

	var uncapped_position : Vector2 = get_uncapped_target_position(viewport_size)
	var capped_position : Vector2 = cap_position(uncapped_position, size_ref_container.size * distance_to_scale, viewport_size)
	var cap_factor : float = min(calculate_cap_factor(uncapped_position, size_ref_container.size * distance_to_scale, viewport_size), 1.0)

	lerp_factor = max(move_toward(lerp_factor, cap_factor, delta * lerp_factor_activation_speed), cap_factor)

	var unadjusted_position : Vector2 = Vector2.ZERO

	if lerp_factor > 0.0:
		SpringUtility.UpdateSpring(x_spring, capped_position.x, delta, spring_freq, spring_dampening)
		SpringUtility.UpdateSpring(y_spring, capped_position.y, delta, spring_freq, spring_dampening)

		#control_to_reposition.global_position = lerp(capped_position, Vector2(x_spring.pos, y_spring.pos), lerp_factor)
		#Actually alter spring pos
		if lerp_factor < 1.0:
			x_spring.pos = StaticUtility.lerp_dampen(x_spring.pos, capped_position.x, (lerp_factor_activation_speed / (lerp_factor * lerp_factor)), delta)
			y_spring.pos = StaticUtility.lerp_dampen(y_spring.pos, capped_position.y, (lerp_factor_activation_speed / (lerp_factor * lerp_factor)), delta)
			x_spring.vel = StaticUtility.lerp_dampen(x_spring.vel, 0.0, (lerp_factor_activation_speed / lerp_factor), delta)
			y_spring.vel = StaticUtility.lerp_dampen(y_spring.vel, 0.0, (lerp_factor_activation_speed / lerp_factor), delta)
		
		unadjusted_position = Vector2(x_spring.pos, y_spring.pos)
	else:
		x_spring.pos = capped_position.x
		y_spring.pos = capped_position.y
		x_spring.vel = 0.0
		y_spring.vel = 0.0
		unadjusted_position = capped_position
	
	control_to_reposition.global_position = unadjusted_position
	control_to_reposition.scale = Vector2.ONE * distance_to_scale

func prepare_displays() -> void:
	target_viewport = get_viewport()
	target_camera = target_viewport.get_camera_3d()

func get_uncapped_target_position(viewport_size : Vector2) -> Vector2:
	if target_camera.is_position_in_frustum(target_position_node.global_position):
		return get_uncapped_frustum_position()
	else:
		return get_uncapped_non_frustum_position(viewport_size)

func get_uncapped_frustum_position() -> Vector2:
	return target_camera.unproject_position(target_position_node.global_position)

func get_uncapped_non_frustum_position(viewport_size : Vector2) -> Vector2:
	var viewport_center : Vector2 = viewport_size / 2

	var local_to_camera : Vector3 = target_camera.to_local(target_position_node.global_position)
	
	var control_pos : Vector2 = Vector2(local_to_camera.x, -local_to_camera.y)
	if control_pos.abs().aspect() > viewport_center.aspect():
		control_pos *= viewport_center.x / abs(control_pos.x)
	else:
		control_pos *= viewport_center.y / abs(control_pos.y)
	return viewport_center + control_pos

func cap_position(position_to_cap : Vector2, cap_size : Vector2, viewport_size : Vector2) -> Vector2:
	var capped_position : Vector2 = position_to_cap

	var half_size_x : float = cap_size.x / 2
	var half_size_y : float = cap_size.y / 2
	capped_position.x = clamp(position_to_cap.x, half_size_x, viewport_size.x - half_size_x)
	capped_position.y = clamp(position_to_cap.y, half_size_y, viewport_size.y - half_size_y)

	return capped_position

func calculate_cap_factor(uncapped_position : Vector2, cap_size : Vector2, viewport_size : Vector2) -> float:
	var viewport_center : Vector2 = viewport_size / 2
	var half_cap : Vector2 = cap_size / 2
	var center_relative_position : Vector2 = uncapped_position - viewport_center

	var dist_to_edge : Vector2 = viewport_center - center_relative_position.abs()
	
	var cap_dist : Vector2 = dist_to_edge - half_cap
	cap_dist = -cap_dist.min(Vector2.ZERO)

	return max(cap_dist.x / half_cap.x, cap_dist.y / half_cap.y) #0 if position is uncapped, 1 if fully capped (at the edge)

func get_distance_to_target() -> float:
	return target_position_node.global_position.distance_to(target_camera.global_position)