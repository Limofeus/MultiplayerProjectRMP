extends Node3D
class_name DroppedItemVisual

@export var item_display_plane : MeshInstance3D = null
@export var tool_item_model_holder : Node3D = null

func update_visual(item : InventoryItem, ammount : int) -> void:
	if item is ToolItem:
		tool_item_model_holder.visible = true
		item_display_plane.visible = false

		for child in tool_item_model_holder.get_children():
			child.queue_free()
		
		var tool_item_scene : PackedScene = item.tool_scene
		var tool_item_instance : Node3D = tool_item_scene.instantiate()
		tool_item_model_holder.add_child(tool_item_instance)

	else:
		tool_item_model_holder.visible = false
		item_display_plane.visible = true
		var item_material : StandardMaterial3D = item_display_plane.material_override
		item_material.albedo_texture = item.icon