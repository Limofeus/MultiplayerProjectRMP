extends Resource
class_name StoreListing

@export var listing_items : Array[InventoryItem] = []

func can_purchase() -> bool:
	for listing_item in listing_items:
		if !listing_item.purchase_available():
			return false
	return true

func purchase_listing() -> void:
	for listing_item in listing_items:
		listing_item.apply_purchase()