extends SpawnArgument
class_name ProjectileSpawnArgument

@export var team_id : int = 0
@export var add_local_velocity : Vector3 = Vector3.ZERO
@export var add_global_velocity : Vector3 = Vector3.ZERO

#@export var physical_damage_addition : float = 0.0
#@export var magical_damage_addition : float = 0.0

#idk, do smthing add something with this

func _init(_team_id : int, _add_local_velocity : Vector3, _add_global_velocity : Vector3):
	team_id = _team_id
	add_local_velocity = _add_local_velocity
	add_global_velocity = _add_global_velocity