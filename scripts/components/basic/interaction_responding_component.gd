extends AuthorityRoutingInteractionComponent
class_name InteractionRespondingComponent

var response_interaction : Interaction = null

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if !interaction_filter(interaction):
		return
	var args_array = interaction_to_arguments(interaction, interacted_entity)
	args_array.push_back(interacted_entity.get_path())
	route_to_authority(args_array)

func authority_recieve_interaction(interaction_args : Array) -> void:
	var response_path = interaction_args.pop_back()
	respond_to_interaction(response_interaction, response_path)

func respond_to_interaction(response : Interaction, entity_to_respond_to_path : NodePath) -> void:
	network_entity.send_interaction(get_node(entity_to_respond_to_path), response)