extends State

@export var creature_ai_component : CreatureAIComponent = null
@export var owner_change_target_seeker : OwnerChangeTargetSeeker = null

@export var target_lost_return_distance : float = 23.0

@export var force_return_distance : float = 25.0
@export var away_from_spawn_return_distance : float = 30.0


func _on_enter() -> void:
	creature_ai_component.movement_input_interface.movement_vector = MovementInputInterface.M_FORWARD
	creature_ai_component.movement_input_interface.dash_pressed = false

func _on_update(_delta : float) -> void:
	creature_ai_component.rotation_input_interface.desired_rotation_direction = (owner_change_target_seeker.global_seeker_start_position - creature_ai_component.creature_attributes.spatial_node.global_position).normalized()

func state_locked() -> bool:
	return owner_change_target_seeker.get_dist_to_start_position() > force_return_distance

func check_conditions() -> bool:
	var target_lost : bool = owner_change_target_seeker.get_has_target() and owner_change_target_seeker.get_dist_to_target() > target_lost_return_distance
	var too_far_from_spawn : bool = owner_change_target_seeker.get_dist_to_start_position() > away_from_spawn_return_distance

	return target_lost or too_far_from_spawn