@icon("res://jeremys_cousine.png")
extends EntityComponent
class_name SpawnShardsOnSignal

@export var aim_on_target : bool = false

@export var spawn_team_id : int = 1

@export var shard_prefab_entity : PackedScene
@export var spawn_nodes : Array[Node3D] = []
@export var spawn_delay : float = 0.1

@export var owner_change_target_seeker : OwnerChangeTargetSeeker = null
@export var sm_ai : StateMachineAI = null
@export var agro_states : Array[Node] = []

var already_spawning : bool = false

func spawn_shards() -> void:
	if already_spawning:
		return
	if !network_entity.has_authority():
		return
	
	if !agro_states.is_empty():
		if !(sm_ai.current_state in agro_states):
			return

	already_spawning = true

	for spawn_node in spawn_nodes:
		spawn_shard_on_node(spawn_node)
		await get_tree().create_timer(spawn_delay).timeout
	already_spawning = false

func spawn_shard_on_node(node : Node3D) -> void:
	var spawn_position : Vector3 = node.global_position

	if aim_on_target and owner_change_target_seeker.get_has_target():
		node.look_at(owner_change_target_seeker.get_target_global_position(), Vector3.UP)

	var spawn_rotation : Vector3 = node.global_rotation


	var pos_rot_spawn_argument : PosRotSpawnArgument = PosRotSpawnArgument.new(spawn_position, spawn_rotation)
	var projectile_spawn_argument : ProjectileSpawnArgument = ProjectileSpawnArgument.new(spawn_team_id, Vector3.ZERO, Vector3.ZERO)

	NetworkSpawner.spawner_singleton.spawn_network_entity(shard_prefab_entity, [pos_rot_spawn_argument, projectile_spawn_argument])