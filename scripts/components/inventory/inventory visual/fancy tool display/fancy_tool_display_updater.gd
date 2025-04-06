extends InventoryVisualModule

@export var tool_display_visual : FancyToolDisplayVisual
@export var creature_item_user_component : CreatureItemUserComponent

var last_selected_item : InventoryItem = null

func set_creature_inventory(creature_selection_container : SelectionItemContainer) -> void:
	super(creature_selection_container)
	creature_selection_container.on_container_updated.connect(update_tool_display)

func update_tool_display() -> void:
	if selection_container.get_selected_item() == last_selected_item:
		return
	
	if last_selected_item is WeaponItem:
		last_selected_item.weapon_used.disconnect(on_item_used)
	last_selected_item = selection_container.get_selected_item()

	if last_selected_item is ToolItem:
		tool_display_visual.item_selected(last_selected_item.tool_scene)
		
		if last_selected_item is WeaponItem:
			last_selected_item.weapon_used.connect(on_item_used)
	else:
		tool_display_visual.item_deselected()

func on_item_used(item_user : ItemUser):
	if creature_item_user_component.creature_item_user == item_user:
		on_item_used_rpc.rpc()

@rpc("call_local", "any_peer", "unreliable")
func on_item_used_rpc():
	tool_display_visual.item_used()
