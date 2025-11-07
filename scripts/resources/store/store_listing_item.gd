extends Resource
class_name StoreListingItem #Currency deduction is also a store listing item


#class PurchaseAvailability:
	#var is_available : bool = true
	#var not_available_reason : String = ""
# Presentation layer will be responsible for determining the reason

func purchase_available() -> bool:
	return true

func apply_purchase() -> void:
	pass