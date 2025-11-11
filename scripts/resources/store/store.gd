extends Resource
class_name Store

@export var store_listings : Array[StoreListing] = []

signal availability_checked()

func can_purchase_listing(store_listing : StoreListing) -> bool:
	return store_listing.can_purchase()

func purchase_listing(store_listing : StoreListing) -> void:
	if !can_purchase_listing(store_listing):
		return
	store_listing.purchase_listing()