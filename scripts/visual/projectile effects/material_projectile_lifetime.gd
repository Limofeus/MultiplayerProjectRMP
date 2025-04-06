extends Node
class_name MaterialProjectileLifetime

@export var projectile : ProjectileComponent
@export var curve_mapping : Curve
@export var shader_material : ShaderMaterial
@export var parameter_name : String = "projectile_lifetime"

func _process(delta: float) -> void:
	var projectile_lifetime := projectile.projectile_lifetime_progress
	var mapped_lifetime : float = curve_mapping.sample(projectile_lifetime)
	shader_material.set_shader_parameter(parameter_name, mapped_lifetime)