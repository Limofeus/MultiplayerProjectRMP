extends Node
class_name ProjectileHitEffect

@export var killable_attributes : KillableAttributes
@export var hit_effect_scene : PackedScene

func _ready():
	killable_attributes.on_hit_by_projectile.connect(spawn_hit_effect)

func spawn_hit_effect(hit_position : Vector3) -> void:
	spawn_hit_effect_rpc.rpc(hit_position)

@rpc("any_peer", "call_local", "unreliable")
func spawn_hit_effect_rpc(hit_position : Vector3) -> void:
	var hit_effect_instance = hit_effect_scene.instantiate()
	NetworkSpawner.spawner_singleton.spawn_parent.add_child(hit_effect_instance)
	hit_effect_instance.global_position = hit_position