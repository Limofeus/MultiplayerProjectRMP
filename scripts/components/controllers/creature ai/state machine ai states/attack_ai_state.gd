extends State

@export var creature_ai_component : CreatureAIComponent = null
@export var owner_change_target_seeker : OwnerChangeTargetSeeker = null

@export var attack_distance : float = 2.0
@export var attack_windup_time : float = 0.4
@export var attack_delay_time : float = 0.1

@export var scaler_spring : SquishScalerSpring = null
@export var scaler_spring_attack_velocity_bump : float = -15.0

var attacking : bool = true

func _on_enter() -> void:
	attacking = true
	creature_ai_component.movement_input_interface.movement_vector = Vector2.ZERO
	creature_ai_component.movement_input_interface.dash_pressed = false

	attacking_coroutine()

	if scaler_spring != null:
		start_attack_visual.rpc()

func attacking_coroutine() -> void:
	await get_tree().create_timer(attack_windup_time).timeout
	creature_ai_component.use_item.emit()
	await get_tree().create_timer(attack_delay_time).timeout
	attacking = false

func state_locked() -> bool:
	return attacking

func check_conditions() -> bool:
	if not owner_change_target_seeker.get_has_target():
		return false
	return owner_change_target_seeker.get_dist_to_target() < attack_distance

@rpc("unreliable", "call_local", "any_peer")
func start_attack_visual() -> void:
	visual_attack_process()

func visual_attack_process() -> void:
	var windup_timer : float = 0.0
	while windup_timer < attack_windup_time:
		var delta = get_process_delta_time()
		windup_timer += delta
		scaler_spring.spring_target_value = windup_timer / attack_windup_time
		await get_tree().process_frame
	scaler_spring.spring_target_value = 0.0
	scaler_spring.bump_spring_velocity(scaler_spring_attack_velocity_bump)