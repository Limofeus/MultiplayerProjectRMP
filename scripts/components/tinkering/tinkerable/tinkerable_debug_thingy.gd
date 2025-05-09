extends Tinkerable

func routing_enabled() -> bool:
	return false

func interaction_filter(interaction : Interaction) -> bool:
	if interaction is TinkerVisibilityUpdateInteraction:
		update_tinkerable_state(interaction.tinkerable_visibility_state)
	return interaction is TinkerInteraction