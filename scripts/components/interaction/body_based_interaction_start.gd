extends EntityComponent

@export var interaction : Interaction

func start_interaction(body : Node) -> void:
	print("Body entererd: " + str(body.name))
	var entity_check : Node = body.get_parent()
	while entity_check != null and !(entity_check is InteractableNetworkEntity):
		entity_check = entity_check.get_parent()

	#if entity_check == null:
		#return

	#if self == null:
		#return

	#if network_entity == null:
		#return

	if entity_check is InteractableNetworkEntity:
		interact_with_entity(entity_check)
	else:
		print("No interactable entity found")

func interact_with_entity(interactable_entity : InteractableNetworkEntity) -> void:
	network_entity.start_interaction(interactable_entity, interaction)
