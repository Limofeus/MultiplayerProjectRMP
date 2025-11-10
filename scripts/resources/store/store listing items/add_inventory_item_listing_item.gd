extends StoreListingItem
class_name AddInventoryItemListingItem

@export var inventory_item : InventoryItem = null
@export var item_count : int = 1

var recipient_inventory : ItemContainer = null

signal request_item_add(inventory_item : InventoryItem, count : int)

func purchase_available() -> bool:
	return recipient_inventory.max_free_space_for_item(inventory_item) >= item_count

func purchase_listing() -> void:
	request_item_add.emit(inventory_item, item_count)
	#recipient_inventory.add_item(inventory_item) #Add directly