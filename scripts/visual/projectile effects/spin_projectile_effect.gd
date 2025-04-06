extends Node
class_name SpinProjectileLifetime

#@export var projectile : ProjectileComponent

@export var visual_to_spin : Node3D
@export var spin_axis : Vector3 = Vector3.UP
@export var spin_speed : float = 1.0

func _process(delta: float) -> void:
	visual_to_spin.rotate(spin_axis, spin_speed * delta)