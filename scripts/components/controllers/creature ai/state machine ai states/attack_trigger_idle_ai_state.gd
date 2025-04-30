extends IdleAiState

func state_locked():
	return creature_ai_component.creature_attributes.health == creature_ai_component.creature_attributes.max_health