extends InteractionStartingComponent
class_name RaycastBasedInteractionStartingComponent

@export var interaction : Interaction
@export var interaction_raycat : RayCast3D

func start_interaction() -> void:
	interaction_raycat.force_raycast_update()
	if interaction_raycat.is_colliding():
		var hit = interaction_raycat.get_collider()

		var interacted_entity = StaticNetworkUtility.get_network_entity_from_node(hit.get_parent(), true)

		print(StaticNetworkUtility.find_shared_component_on_entity(interacted_entity, OptimizedPositionSyncComponent))
		print(StaticNetworkUtility.find_shared_component_on_entity(interacted_entity, PositionSyncComponent))

		if interacted_entity != null:
			interact_with_entity(interacted_entity)

func interact_with_entity(interactable_entity : InteractableNetworkEntity) -> void:
	network_entity.start_interaction(interactable_entity, interaction)
