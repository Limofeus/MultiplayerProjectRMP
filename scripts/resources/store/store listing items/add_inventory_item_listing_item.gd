extends StoreListingItem
class_name AddInventoryItemListingItem

@export var inventory_item : InventoryItem = null

var recipient_inventory : ItemContainer = null

func purchase_available() -> bool:
	return recipient_inventory.max_free_space_for_item(inventory_item) > 0

func purchase_listing() -> void:
	pass
	#recipient_inventory.add_item(inventory_item)
	#Cus inventory add function is probly different for players