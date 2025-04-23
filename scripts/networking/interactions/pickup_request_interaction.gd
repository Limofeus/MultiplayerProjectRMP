extends Interaction
class_name PickupRequestInteraction

#Ammount of items entity requests to be picked up (Ususally = to max inventory space)
var pickup_amount : int = 1

func _init(amount : int = 1) -> void:
	pickup_amount = amount