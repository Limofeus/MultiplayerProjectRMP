extends CreatureAIComponent
class_name DumbYoloAIComponent

@export var ignore_distance : float = 20.0
@export var far_distance : float = 10.0
@export var close_distance : float = 3.0

@export var windup_time : float = 0.4 #Somewhat lazy solution to absence of time
@export var attack_time : float = 0.1

var monster_spring : SpringUtility.SpringParams = SpringUtility.SpringParams.new(0.0, 0.0)
@export var monster_spring_power : float = 0.1 #In % of creature height change
@export var monster_spring_freq : float = 30.0
@export var monster_spring_damping : float = 0.5
@export var monster_spring_attack_velocity_bump : float = -15.0

@export var monster_springing_node : Node3D = null

@export var owner_change_component : OwnerChangeComponent = null

var current_target : Node3D = null
var attacking : bool = false #idealy should be a stat
var monster_spring_target_value : float = 0.0

var mega_kostyl : bool = false #This is some mega ultra kostyl, I know of a better way to do this, but I dont want to do it until I have all the core systems done better (State machine AI at least)

var entity_ready : bool = false #TODO: Look in to implementing such bool in actual net entity

func cur_dist_to_target() -> float:
	if current_target == null:
		return 0.0
	return creature_attributes.spatial_node.global_position.distance_to(current_target.global_position)

func on_entity_ready() -> void: #TODO: See above + contemplate on how common are rpcs on entity readying (such as this owner change rpc in reassign target function)
	entity_ready = true #TODO: Look in to entity spawner, this thing should be called after spawn arguments NOT entity ready, I made a signal in enable process spawn component purely for this
	reassign_target()

func reassign_target() -> void:

	if !entity_ready or !network_entity.has_authority():
		return #Only authority does all this

	print("Searching for targets")
	var target_aray : Array[CreatureAttributes] = targeting_component.find_different_team_creatures(creature_attributes)
	target_aray = filter_targets_by_distance(target_aray)
	if target_aray.size() > 0:
		print("Found a target or smh")
		current_target = target_aray[0].spatial_node
	else:
		#No same peer entities, searching all peers
		target_aray = targeting_component.find_different_team_creatures(creature_attributes, false)
		target_aray = filter_targets_by_distance(target_aray)
		if target_aray.size() > 0:
			current_target = target_aray[0].spatial_node

	#Update authority to be on the same peer as target
	if current_target != null:
		var target_entity = StaticNetworkUtility.get_network_entity_from_node(current_target, false)
		if network_entity.get_current_authority() != target_entity.get_current_authority():
			owner_change_component.change_owner(target_entity.get_current_authority(), true)

func filter_targets_by_distance(targets_to_filter : Array[CreatureAttributes]) -> Array[CreatureAttributes]:
	var return_array : Array[CreatureAttributes] = []
	for target in targets_to_filter:
		if creature_attributes.spatial_node.global_position.distance_to(target.spatial_node.global_position) < ignore_distance:
			return_array.append(target)

	return return_array

func attack_check() -> void:
	if current_target != null:
		if cur_dist_to_target() < close_distance:
			attacking = true
			attacking_coroutine()
			visualise_attack.rpc()
			#use_item.emit()

func _ready():
	network_entity.entity_ready.connect(start_kostyl)

func start_kostyl():
	start_kostyl_process.rpc()

func _process(delta):
	if attacking:
		return
	else:
		if current_target != null and cur_dist_to_target() < ignore_distance:
			rotation_input_interface.desired_rotation_direction = (current_target.global_position - creature_attributes.spatial_node.global_position).normalized()
		movement_input_interface.dash_pressed = cur_dist_to_target() > far_distance
		movement_input_interface.movement_vector = MovementInputInterface.M_FORWARD if (cur_dist_to_target() > close_distance and cur_dist_to_target() < ignore_distance) else Vector2.ZERO
		attack_check()

func kostyl_process():
	while true:
		update_monster_spring(get_process_delta_time())
		await get_tree().process_frame

func attacking_coroutine():
	await get_tree().create_timer(windup_time).timeout
	use_item.emit()
	await get_tree().create_timer(attack_time).timeout
	attacking = false

func visual_attack_coroutine():
	var windup_timer : float = 0.0
	while windup_timer < windup_time:
		var delta = get_process_delta_time()
		windup_timer += delta
		monster_spring_target_value = windup_timer / windup_time
		await get_tree().process_frame
	monster_spring_target_value = 0.0
	monster_spring.vel += monster_spring_attack_velocity_bump

func update_monster_spring(delta : float):
	SpringUtility.UpdateSpring(monster_spring, monster_spring_target_value, delta, monster_spring_freq, monster_spring_damping)
	var scale_change_val = monster_spring.pos * monster_spring_power
	monster_springing_node.scale = Vector3.ONE + (Vector3.UP * scale_change_val) - ((Vector3.RIGHT + Vector3.BACK) * scale_change_val)

@rpc("any_peer", "call_local", "unreliable")
func visualise_attack() -> void:
	visual_attack_coroutine()

@rpc("any_peer", "call_local", "reliable")
func start_kostyl_process():
	if not mega_kostyl:
		mega_kostyl = true
		kostyl_process()

func _on_creature_attributes_on_take_damage(damage_ammount:float, damager_peer:int):
	if damager_peer == network_entity.get_current_authority():
		return

	if network_entity.has_authority():
		owner_change_component.change_owner(damager_peer, true)