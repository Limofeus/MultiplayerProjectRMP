extends InteractionRecievingComponent
class_name AuthorityRoutingInteractionComponent

#For ease of use, ignores interaction if filter returnes false
func interaction_filter(interaction : Interaction) -> bool:
	return true

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if !interaction_filter(interaction):
		return
	route_to_authority(interaction_to_arguments(interaction, interacted_entity))

#Redefine this thig to compress interaction in to arguments you want to pass to owner's peer
func interaction_to_arguments(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> Array:
	return []

#Use varargs here maybe when they'll be available
@rpc("reliable", "call_local", "any_peer")
func route_to_authority(authority_function_arguments : Array) -> void:
	if network_entity.has_authority():
		authority_recieve_interaction(authority_function_arguments)
	else:
		route_to_authority.rpc_id(network_entity.get_current_authority(), authority_function_arguments)

func authority_recieve_interaction(interaction_args : Array) -> void:
	pass
