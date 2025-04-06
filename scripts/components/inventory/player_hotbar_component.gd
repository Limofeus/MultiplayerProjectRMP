extends UnsyncedComponent
class_name PlayerHotbarComponent

@export var creature_inventory : CreatureInventoryComponent = null

func connect_container_to_hotbar() -> void:
	var hotbar_node : Hotbar = unsynced_node
	if network_entity.has_authority():
		hotbar_node.connect_item_container(creature_inventory.creature_item_container)
