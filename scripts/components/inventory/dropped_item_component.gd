extends InteractionRespondingComponent
class_name DroppedItemComponent

@export var owner_prevent_pickup_timer : Timer = null
@export var destruction_component : DestructionComponent = null

var inventory_item_resource : InventoryItem = null
var item_ammount : int = 0

signal item_set(item : InventoryItem, amount : int)
signal item_picked_up()

func set_item(item : InventoryItem, amount : int = 1) -> void:
	inventory_item_resource = item
	item_ammount = amount
	response_interaction = AddItemInteraction.new(item, amount)
	item_set.emit(item, amount)

func interaction_filter(interaction : Interaction) -> bool:
	return interaction is PickupRequestInteraction

func interaction_to_arguments(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> Array:
	return [interaction.pickup_amount]

func authority_recieve_interaction(interaction_args : Array) -> void:
	if network_entity.get_current_authority() == multiplayer.get_unique_id():
		if owner_prevent_pickup_timer.time_left > 0:
			return

	response_interaction.amount = min(interaction_args[0], item_ammount)
	item_ammount -= response_interaction.amount

	super(interaction_args)
	item_picked_up.emit()

	if item_ammount <= 0:
		destruction_component.destroy_entity(true)
