extends InteractionReceivingComponent

@export var owner_change_component : OwnerChangeComponent
@export var force_change_owner : bool = false #Use with caution (at least use this with timed owner change, tho TODO make alternative owner changed timed that will check for whoever was first to forve change, not both...)

#Another TODO: make force change possible to be pulled from interaction?

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if interaction is OwnerChangeInteraction:
		var new_owner : int = interaction.new_owner
		if(interaction.auto_set_owner):
			new_owner = interacted_entity.get_current_authority()

		owner_change_component.set_new_owner(new_owner, force_change_owner)