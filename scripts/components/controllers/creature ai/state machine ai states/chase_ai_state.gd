extends State

@export var creature_ai_component : CreatureAIComponent = null
@export var owner_change_target_seeker : OwnerChangeTargetSeeker = null
@export var research_target_timer : Timer = null

@export var chase_distance : float = 10.0
@export var run_distance : float = 7.0
@export var target_research_interval : float = 1.0

func _ready() -> void:
	research_target_timer.wait_time = target_research_interval
	research_target_timer.start()

func _on_enter() -> void:
	creature_ai_component.movement_input_interface.movement_vector = MovementInputInterface.M_FORWARD
	creature_ai_component.movement_input_interface.dash_pressed = owner_change_target_seeker.get_dist_to_target() > run_distance

func _on_update(_delta : float) -> void:
	if owner_change_target_seeker.get_has_target():
			creature_ai_component.rotation_input_interface.desired_rotation_direction = (owner_change_target_seeker.get_target_global_position() - creature_ai_component.creature_attributes.spatial_node.global_position).normalized()

func check_conditions() -> bool:
	if research_target_timer.time_left <= 0.0:
		owner_change_target_seeker.search_distance = chase_distance
		owner_change_target_seeker.research_target()
		research_target_timer.start()
		#print("researching targets")
	var start_chase : bool = owner_change_target_seeker.get_has_target() and owner_change_target_seeker.get_dist_to_target() < chase_distance
	if start_chase:
		print("Starting the chase")
	return start_chase