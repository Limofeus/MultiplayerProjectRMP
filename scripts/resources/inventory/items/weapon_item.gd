extends EntitySpawnerItem
class_name WeaponItem

@export var item_cooldown : float = 0.1
@export var useable_on_cooldown : bool = false
@export var combo_scenes : Array[PackedScene] = []
@export var combo_add_cooldowns : Array[float] = []

signal weapon_used(item_user : ItemUser)

func _item_selected(item_container : SelectionItemContainer, item_user : ItemUser = null) -> void:
	if item_user != null:
		item_user.item_user_metadata["combo_progress"] = 0

func spawn_network_entity(_item_user : SpatialItemUser, item_use_node : Node3D) -> void:
	if (!useable_on_cooldown) and _item_user.item_use_cooldown > 0.0:
		return

	weapon_used.emit(_item_user)
	_item_user.item_use_cooldown = item_cooldown
	
	var cur_instantiate_scene : PackedScene = scene_to_instantiate
	
	if combo_scenes.size() > 0:
		var combo_progress = 0
		if _item_user.item_user_metadata.has("combo_progress"):
			combo_progress = _item_user.item_user_metadata["combo_progress"]
		cur_instantiate_scene = combo_scenes[combo_progress]

		if combo_add_cooldowns.size() > combo_progress:
			_item_user.item_use_cooldown += combo_add_cooldowns[combo_progress]

		_item_user.item_user_metadata["combo_progress"] = (combo_progress + 1) % combo_scenes.size()

	var additional_velocity_vector : Vector3 = Vector3.ZERO

	if _item_user is CreatureItemUser:
		additional_velocity_vector = _item_user.character_body.velocity #In global basis (theoretically)

	var pos_rot_spawn_argument : PosRotSpawnArgument = PosRotSpawnArgument.new(item_use_node.global_position + (-item_use_node.global_basis.z * position_offset), item_use_node.global_rotation)
	var projectile_spawn_argument : ProjectileSpawnArgument = ProjectileSpawnArgument.new(_item_user.team_id, Vector3.ZERO, additional_velocity_vector)

	return NetworkSpawner.spawner_singleton.spawn_network_entity(cur_instantiate_scene, [pos_rot_spawn_argument, projectile_spawn_argument])