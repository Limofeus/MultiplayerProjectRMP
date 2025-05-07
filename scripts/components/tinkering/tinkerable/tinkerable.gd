extends InteractionRespondingComponent #Extends InteractionRespondingComponent to be able to quickly use it's functionaliity, when godot traits(interfaces) will come, I'll rewrite that probably
class_name Tinkerable

enum TinkerableState {Focused, Unfocused, Hidden}

@export var tinker_center_node : Node3D = null
@export var tinker_range : float = 4.0
@export var tinker_angle_dot : float = 0.5 #1 = 0deg, 0 = 180deg, -1 = 360deg (dot product)

var current_tinkerable_state : TinkerableState = TinkerableState.Hidden

signal on_tinkerable_state_changed(new_state : TinkerableState) 

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if !interaction_filter(interaction):
		return
	if !routing_enabled():
		return
	var args_array = interaction_to_arguments(interaction, interacted_entity)
	args_array.push_back(interacted_entity.get_path())
	route_to_authority(args_array)

func routing_enabled() -> bool:
	return true

#DO NOT forget to call this when overriding interaction recieving child methods
func update_tinkerable_state(new_state : TinkerableState) -> void:
	current_tinkerable_state = new_state
	on_tinkerable_state_changed.emit(new_state)