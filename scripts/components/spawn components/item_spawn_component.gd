extends SpawnTransformSetter
class_name ItemSpawnComponent

@export var dropped_item_component : DroppedItemComponent = null

func process_spawn_argument(spawn_argument : SpawnArgument) -> void:
	super(spawn_argument)
	if spawn_argument is ItemSpawnArgument and dropped_item_component != null:
		dropped_item_component.set_item(spawn_argument.item, spawn_argument.ammount)
		set_dropped_item.rpc(spawn_argument.item.resource_path, spawn_argument.ammount)

@rpc("reliable", "call_remote", "any_peer")
func set_dropped_item(item_resource_path : String, ammount : int = 1) -> void:
	var inventory_item = ResourceLoader.load(item_resource_path, "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	dropped_item_component.set_item(inventory_item, ammount)