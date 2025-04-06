extends InventoryVisualModule
class_name DisplayToolItem

@export var tool_item_parent_node : Node3D

var last_selected_item : int = -1

func set_creature_inventory(creature_selection_container : SelectionItemContainer) -> void:
	super(creature_selection_container)
	selection_container.on_container_updated.connect(update_displayed_item)

func update_displayed_item():
	if last_selected_item == selection_container.selected_slot: #Only update if the selected slot has changed
		return
	

	last_selected_item = selection_container.selected_slot

	var selected_item = selection_container.items[selection_container.selected_slot]

	if tool_item_parent_node.get_child_count() > 0:
		tool_item_parent_node.get_child(0).queue_free()

	if selected_item is ToolItem and selected_item.tool_scene != null:
		var display_item = selected_item.tool_scene.instantiate()
		tool_item_parent_node.add_child(display_item)