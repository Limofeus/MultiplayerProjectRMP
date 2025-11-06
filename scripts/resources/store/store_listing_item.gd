extends Resource
class_name StoreListingItem #Currency deduction is also a store listing item

func purchase_available() -> bool:
	return true

func apply_purchase() -> void:
	pass