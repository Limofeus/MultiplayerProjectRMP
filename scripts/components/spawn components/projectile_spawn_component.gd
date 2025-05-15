extends SpawnTransformSetter
class_name ProjectileSpawnComponent

@export var projectile_component : ProjectileComponent
@export var global_velocity_transfer : float = 1.0

func process_spawn_argument(spawn_argument : SpawnArgument) -> void:
	super(spawn_argument) #Sets position and rotation
	if spawn_argument is ProjectileSpawnArgument:
		update_projectile_team.rpc(spawn_argument.team_id)

		var added_velocity_vector : Vector3 = Vector3.ZERO
		added_velocity_vector += spawn_argument.add_local_velocity
		added_velocity_vector += (projectile_component.projectile_node.global_transform.basis.inverse() * spawn_argument.add_global_velocity * global_velocity_transfer)

		if added_velocity_vector.length() > 0:
			update_projectile_velocity.rpc(added_velocity_vector)

@rpc("reliable", "call_local", "any_peer")
func update_projectile_team(team_id : int) -> void:
	projectile_component.projectile_team = team_id

@rpc("reliable", "call_local", "any_peer")
func update_projectile_velocity(add_local_velocity : Vector3) -> void:
	projectile_component.velocity += add_local_velocity
