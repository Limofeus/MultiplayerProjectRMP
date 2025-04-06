@tool

extends Node

@export var set_mat_size : bool = false
@export var material_to_apply : StandardMaterial3D = null
@export var csg_array : Array[CSGBox3D] = []

func set_csg_texture_size(csg_node : CSGBox3D) -> void:
	var csg_size : Vector3 = csg_node.size
	var csg_material : StandardMaterial3D = material_to_apply.duplicate()
	csg_material.uv1_scale = Vector3(csg_size.z, csg_size.x, csg_size.y) #Godot moment
	csg_node.material = csg_material

func _process(delta):
	if set_mat_size:
		print("Tool test")
		for csg_node in csg_array:
			set_csg_texture_size(csg_node)
		set_mat_size = false