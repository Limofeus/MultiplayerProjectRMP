extends OriginalActorMultibuttonInteractionProcessor
class_name PickupItemButtonInteraction

@export var inventory_item : InventoryItem
@export var amount : int = 1
@export var dropped_item_component : DroppedItemComponent

func _ready():
	super()
	if dropped_item_component != null:
		dropped_item_component.set_item(inventory_item, amount)
		print("item set")

func prepare_interaction(interacting_entity : InteractableNetworkEntity) -> Interaction:
	var actor_inventory_component : CreatureInventoryComponent = StaticNetworkUtility.find_shared_component_on_entity(interacting_entity, CreatureInventoryComponent)
	var free_space_for_item = actor_inventory_component.free_space_for_item(inventory_item)
	if free_space_for_item > 0:
		return PickupRequestInteraction.new(free_space_for_item)
	return null