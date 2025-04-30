extends State

@export var creature_ai_component : CreatureAIComponent = null
@export var owner_change_target_seeker : OwnerChangeTargetSeeker = null

@export var health_threshold : float = 3.0

func _on_enter() -> void:
	creature_ai_component.movement_input_interface.movement_vector = MovementInputInterface.M_FORWARD
	creature_ai_component.movement_input_interface.dash_pressed = true

func _on_update(_delta : float) -> void:
	if owner_change_target_seeker.get_has_target():
			creature_ai_component.rotation_input_interface.desired_rotation_direction = (creature_ai_component.creature_attributes.spatial_node.global_position - owner_change_target_seeker.get_target_global_position()).normalized()


func check_conditions() -> bool:
	return creature_ai_component.creature_attributes.health <= health_threshold