extends DumbYoloAIComponent
class_name DumbRangedAIComponent

@export var far_dist_threshold : float = 2.0
var runaway : bool = false
var sin_timer_or_something : float = 0.0

func attack_check() -> void:
	if current_target != null:
		if cur_dist_to_target() > close_distance and rotation_input_interface.rotation_vector.angle_to(rotation_input_interface.desired_rotation_direction) < 0.1 and (not runaway):
			attacking = true
			attacking_coroutine()
			visualise_attack.rpc()
			#use_item.emit()

func _process(delta):
	sin_timer_or_something += delta
	if attacking:
		rotation_input_interface.desired_rotation_direction = (current_target.global_position - creature_attributes.spatial_node.global_position).normalized()
	else:
		if current_target != null:
			var cur_dist = cur_dist_to_target()

			if runaway:
				rotation_input_interface.desired_rotation_direction = (-current_target.global_position + creature_attributes.spatial_node.global_position).normalized()
				movement_input_interface.movement_vector = MovementInputInterface.M_FORWARD
				movement_input_interface.dash_pressed = true
				if cur_dist > far_distance:
					runaway = false
			else:
				movement_input_interface.dash_pressed = false
				if cur_dist < ignore_distance:
					if cur_dist > close_distance:
						rotation_input_interface.desired_rotation_direction = (current_target.global_position - creature_attributes.spatial_node.global_position).normalized()
					else:
						runaway = true
				movement_input_interface.movement_vector = MovementInputInterface.M_FORWARD if (cur_dist_to_target() > far_distance and cur_dist_to_target() < ignore_distance) else Vector2.ZERO
				if cur_dist < (far_distance - far_dist_threshold):
					movement_input_interface.movement_vector = MovementInputInterface.M_BACKWARD
				movement_input_interface.movement_vector += MovementInputInterface.M_LEFTWARD * roundf(sin(sin_timer_or_something))
		attack_check()