extends AuthorityRoutingInteractionComponent
class_name ItemPickupComponent

@export var item_pickup_area : Area3D = null
@export var creature_inventory : CreatureInventoryComponent = null

func _ready():
	#super()
	item_pickup_area.area_entered.connect(process_item_pickup)

func interaction_filter(interaction : Interaction) -> bool:
	return interaction is AddItemInteraction

func interaction_to_arguments(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> Array:
	return [interaction.item.resource_path, interaction.amount]

func authority_recieve_interaction(interaction_args : Array) -> void:
	var inventory_item = ResourceLoader.load(interaction_args[0], "InventoryItem", ResourceLoader.CACHE_MODE_REUSE)
	creature_inventory.add_item(inventory_item, interaction_args[1])

func process_item_pickup(item_reference_node : Node3D) -> void:
	if creature_inventory == null:
		return
	
	if network_entity.has_authority() == false:
		return

	var creature_item_container : ItemContainer = creature_inventory.creature_item_container
	var dropped_item_entity : InteractableNetworkEntity = StaticNetworkUtility.get_network_entity_from_node(item_reference_node, true)
	if dropped_item_entity == null:
		return

	var dropped_item_component : DroppedItemComponent = StaticNetworkUtility.find_shared_component_on_entity(dropped_item_entity, DroppedItemComponent)
	if dropped_item_component == null:
		return

	var inventory_item : InventoryItem = dropped_item_component.inventory_item_resource
	if inventory_item == null:
		return

	if creature_item_container.has_room_for(inventory_item):
		var item_pickup_interaction = GenericActionInteraction.new("pickup_item")
		network_entity.send_interaction(dropped_item_entity, item_pickup_interaction)