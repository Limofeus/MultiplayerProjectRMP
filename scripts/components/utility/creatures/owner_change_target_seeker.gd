extends EntityComponent
class_name OwnerChangeTargetSeeker

@export var search_distance : float = 20.0

@export var head_raycast : RayCast3D = null
@export var creature_ai_component : CreatureAIComponent = null
@export var owner_change_component : OwnerChangeComponent = null
@export var process_enable_spawn_component : ProcessEnableSpawnComponent = null

var target_creature_attributes : CreatureAttributes = null
var target_node : Node3D = null

var global_seeker_start_position : Vector3

var auto_update_owner : bool = true #Dunno wether this will ever be false
var change_owner_on_attributes_damage : bool = true

var entity_ready : bool = false

@onready var targeting_component : TargetingComponent = creature_ai_component.targeting_component
@onready var creature_attributes : CreatureAttributes = creature_ai_component.creature_attributes

func _ready():
	process_enable_spawn_component.nodes_enabled.connect(on_entity_ready)
	creature_attributes.on_take_damage.connect(_on_creature_attributes_on_take_damage)

func on_entity_ready() -> void:
	entity_ready = true #TODO: See yolo_ai_component
	global_seeker_start_position = creature_attributes.spatial_node.global_position
	research_target()

func research_target():
	if !entity_ready or !network_entity.has_authority():
		return #Only authority does all this

	#TODO: make this a tad bit prettier
	var target_aray : Array[CreatureAttributes] = targeting_component.find_different_team_creatures(creature_attributes)
	target_aray = filter_targets_by_distance(target_aray, search_distance)
	target_aray = filter_targets_by_visibility(target_aray)

	if target_aray.size() > 0:
		set_target(target_aray[0])
	else:
		target_aray = targeting_component.find_different_team_creatures(creature_attributes, false)
		target_aray = filter_targets_by_distance(target_aray, search_distance)
		target_aray = filter_targets_by_visibility(target_aray)

		if target_aray.size() > 0:
			set_target(target_aray[0]) #Implement, search for closest target
		else:
			clear_target()
	
	if target_creature_attributes != null and target_creature_attributes.network_entity.get_current_authority() != network_entity.get_current_authority():
		try_change_owner(target_creature_attributes.network_entity.get_current_authority())

func set_target(target_ca : CreatureAttributes):
	target_creature_attributes = target_ca
	target_node = target_ca.spatial_node

func clear_target():
	target_creature_attributes = null
	target_node = null

func get_has_target() -> bool:
	return target_creature_attributes != null

func get_dist_to_target() -> float:
	if target_node == null:
		print("Target node is null")
		return INF
	return creature_attributes.spatial_node.global_position.distance_to(target_node.global_position)

func get_can_see_target() -> bool:
	return true
	#TODO: Also implement this

func get_target_global_position() -> Vector3:
	return target_node.global_position

func get_dist_to_start_position() -> float:
	return creature_attributes.spatial_node.global_position.distance_to(global_seeker_start_position)

func filter_targets_by_distance(targets_to_filter : Array[CreatureAttributes], filter_distance : float = 100) -> Array[CreatureAttributes]:
	var return_array : Array[CreatureAttributes] = []
	for target in targets_to_filter:
		if creature_attributes.spatial_node.global_position.distance_to(target.spatial_node.global_position) < filter_distance:
			return_array.append(target)

	return return_array

func filter_targets_by_visibility(targets_to_filter : Array[CreatureAttributes]) -> Array[CreatureAttributes]:
	#TODO: Implement
	return targets_to_filter

func try_change_owner(new_owner_id : int):
	if new_owner_id == network_entity.get_current_authority():
		return
	if network_entity.has_authority():
		owner_change_component.change_owner(new_owner_id, true)

func _on_creature_attributes_on_take_damage(_damage_ammount : float, damager_peer : int):
	if change_owner_on_attributes_damage:
		try_change_owner(damager_peer)