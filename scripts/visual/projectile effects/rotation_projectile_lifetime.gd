extends Node
class_name RotationProjectileLifetime

@export var projectile : ProjectileComponent

@export var visual_to_rotate : Node3D

@export var curve_mapping : Curve
@export var start_rotation : Vector3 = Vector3.ZERO #Interpolates linearly, consider using several rotation nodes or writing a custom one for complex effects
@export var end_rotation : Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	var projectile_lifetime := projectile.projectile_lifetime_progress
	var mapped_lifetime : float = curve_mapping.sample(projectile_lifetime)

	var mapped_rotation : Vector3 = lerp(start_rotation, end_rotation, mapped_lifetime)

	visual_to_rotate.rotation = mapped_rotation
