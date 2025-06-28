extends TinkerableSelectMultibutton
class_name TinkerableDialogue

var current_focusing_tinkerer : NetworkEntity = null


signal tinkerer_changed(new_tinkerer : NetworkEntity)
signal main_tinker_action_no_choice()

func tinker_input_enabled() -> bool:
	return current_focusing_tinkerer != null and current_focusing_tinkerer.has_authority()

func other_peer_tinkering() -> bool:
	return current_focusing_tinkerer != null and !current_focusing_tinkerer.has_authority()

func process_tinker_input(input_event : InputEvent) -> void:
	if tinker_input_enabled():
		if interact_prompt_buttons.size() == 0:
			if input_event.is_action_pressed(tinker_action_name):
				main_tinker_action_no_choice.emit()
		else:
			super(input_event)
	#else:
		#print("TINKER INPUT DISABLED, cur tinkerer: ", current_focusing_tinkerer)

func recieve_interaction(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if !interaction_filter(interaction):
		return
	update_current_tinkerer(interaction, interacted_entity)

func update_current_tinkerer(interaction : Interaction, interacted_entity : InteractableNetworkEntity) -> void:
	if interaction is TinkerVisibilityUpdateInteraction:
		var tinker_state = interaction.tinkerable_visibility_state
		if tinker_state == Tinkerable.TinkerableState.Focused:
			request_tinkerer_change.rpc_id(network_entity.get_current_authority(), interacted_entity.get_path(), true)
		else:
			request_tinkerer_change.rpc_id(network_entity.get_current_authority(), interacted_entity.get_path(), false)

#-- Driver connections and stuff --

func update_dialogue_options(dialogue_options : Array[String]) -> void:
	interact_prompt_settings.clear()
	for dialogue_option in dialogue_options:
		var interact_prompt_setting = TinkerableInteractButtonPromptSettings.new()
		interact_prompt_setting.interact_prompt = dialogue_option
		interact_prompt_settings.append(interact_prompt_setting)
	recreate_interact_prompt_buttons()
#--RPCs--

@rpc("reliable", "call_local", "any_peer")
func request_tinkerer_change(new_tinkerer_path : NodePath, is_tinkering : bool) -> void:
	if is_tinkering and current_focusing_tinkerer == null:
		print("+REQ tinkerer: " + str(new_tinkerer_path))
		notice_tinkerer_changed.rpc(str(new_tinkerer_path))
	elif !is_tinkering and current_focusing_tinkerer == get_node(new_tinkerer_path):
		print("-REQ tinkerer: " + str(new_tinkerer_path))
		notice_tinkerer_changed.rpc("")

@rpc("reliable", "call_local", "any_peer")
func notice_tinkerer_changed(new_tinkerer_path_str : String) -> void:
	print("UPD tinkerer: " + new_tinkerer_path_str)
	if new_tinkerer_path_str == "":
		current_focusing_tinkerer = null
	else:
		current_focusing_tinkerer = get_node(new_tinkerer_path_str)
	tinkerer_changed.emit(current_focusing_tinkerer)