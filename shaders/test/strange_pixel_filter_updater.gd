@tool
extends Node
class_name StrangePixelFilterUpdater

@export var shader_material : ShaderMaterial
@export var camera_ref : Camera3D

@export var division_factor : float = 80.0
@export var move_mult : float = 0.5

func _process(delta: float) -> void:
	shader_material.set_shader_parameter("pixel_offset", -camera_ref.global_rotation_degrees.y / camera_ref.fov * division_factor * move_mult)