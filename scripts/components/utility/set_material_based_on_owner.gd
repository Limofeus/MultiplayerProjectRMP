extends EntityComponent

@export var materials : Array[Material]
@export var mesh : MeshInstance3D

func _on_entity_authority_change():
	var net_index = network_entity.get_current_owner_index()
	mesh.set_material_override(materials[net_index % materials.size()])