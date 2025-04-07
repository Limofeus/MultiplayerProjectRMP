extends EntityComponent
class_name PlayerItemDropComponent

@export var dropped_item_scene : PackedScene = null
@export var player_inventory_component : PlayerInventoryComponent = null
@export var item_drop_spawn_position : Node3D = null

func _process(delta):
	if Input.is_action_just_pressed("drop_item"):
		var selection_item_container = player_inventory_component.creature_item_container
		var item_to_drop : InventoryItem = selection_item_container.get_selected_item()
		var item_drop_ammount : int = selection_item_container.get_selected_item_ammount()
		if item_to_drop == null:
			return
		print("Dropping item " + item_to_drop.name + " with ammount: " + str(item_drop_ammount))
		player_inventory_component.clear_slot(selection_item_container.selected_slot)
		StaticNetworkUtility.spatial_spawn_network_entity(dropped_item_scene, item_drop_spawn_position.global_position, Vector3.ZERO, [ItemSpawnArgument.new(item_to_drop, item_drop_ammount)])