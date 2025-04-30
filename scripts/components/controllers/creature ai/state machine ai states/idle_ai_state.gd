extends State
class_name IdleAiState

@export var creature_ai_component : CreatureAIComponent = null
@export var owner_change_target_seeker : OwnerChangeTargetSeeker = null

@export var threshold_distance : float = 0.5

func _on_enter() -> void:
	creature_ai_component.movement_input_interface.movement_vector = Vector2.ZERO
	creature_ai_component.movement_input_interface.dash_pressed = false

func check_conditions() -> bool:
	return owner_change_target_seeker.get_dist_to_start_position() < threshold_distance