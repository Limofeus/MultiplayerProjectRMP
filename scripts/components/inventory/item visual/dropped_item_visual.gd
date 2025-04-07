extends Node3D
class_name DroppedItemVisual

@export var item_display_plane : MeshInstance3D = null

func update_visual(item : InventoryItem, ammount : int) -> void:
	var item_material : StandardMaterial3D = item_display_plane.material_override
	item_material.albedo_texture = item.icon