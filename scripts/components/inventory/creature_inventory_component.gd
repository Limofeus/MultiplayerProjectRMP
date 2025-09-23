extends EntityComponent
class_name CreatureInventoryComponent

#Streamline this so that all creatures can have an inventory

@export var inventory_size : int = 1
@export var initial_items : Array[InventoryItem] = []

var creature_item_container : SelectionItemContainer = null
var creature_item_user : CreatureItemUser = null

func _ready():
	print("ready on creature inventory node")
	creature_item_container = SelectionItemContainer.new(inventory_size)

	for child in get_children():
		if child is InventoryVisualModule:
			child.set_creature_inventory(creature_item_container)

func add_initial_items() -> void:
	if network_entity.has_authority():
		for item in initial_items:
			add_item(item)

func add_item(item : InventoryItem, ammount : int = 1) -> void: #Rewrite with support to item count
	creature_item_container.add_item(item, ammount)
	propagate_add_item.rpc(item.resource_path, ammount)

func clear_slot(slot_id : int) -> void:
	creature_item_container.clear_slot(slot_id)
	propagate_clear_slot.rpc(slot_id)

func use_selected_item(item_user : ItemUser) -> void:
	var item : InventoryItem = creature_item_container.get_selected_item()
	if item is UsableItem:
		item.use_item(item_user)
	elif item is ToolItem:
		item._use_tool(item_user)

func offset_selected_slot(offset : int) -> void:
	creature_item_container.offset_selected_slot(offset, creature_item_user)
	propagate_selection.rpc(creature_item_container.selected_slot)

func select_slot(selected_slot : int) -> void:
	creature_item_container.select_slot(selected_slot, creature_item_user)
	propagate_selection.rpc(selected_slot)

func get_selected_slot() -> int:
	return creature_item_container.selected_slot

#Quick and dirty func
func free_space_for_item(item : InventoryItem) -> int:
	if creature_item_container != null and creature_item_container.has_room_for(item):
		return creature_item_container.max_free_space_for_item(item)
	return 0

@rpc("call_remote", "any_peer", "unreliable") #Since logic is handled on owner of the entity, we can make this unreliable as it should only affect visuals
func propagate_selection(selected_slot : int) -> void:
	creature_item_container.select_slot(selected_slot, creature_item_user)

@rpc("call_remote", "any_peer", "reliable") #Adding items is reliable
func propagate_add_item(item_resource_path : String, ammount : int) -> void:
	var item : InventoryItem = ResourceLoader.load(item_resource_path, "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	print("Recieved propagated item: " + item.name)
	creature_item_container.add_item(item, ammount)

@rpc("call_remote", "any_peer", "reliable")
func propagate_clear_slot(slot_id : int) -> void:
	creature_item_container.clear_slot(slot_id)