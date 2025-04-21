extends UnsyncedComponent

@export var state_machine_ai : StateMachineAI = null
@export var creature_attributes : CreatureAttributes = null

@export var aggroed_states : Array[State] = []

var contributes_to_counter : bool = false

var quick_dynamic_music : QuickDynamicMusic = null
var cashed_state : State = null

func _ready() -> void:
	super()
	quick_dynamic_music = unsynced_node
	state_machine_ai.on_state_changed.connect(on_state_change)
	creature_attributes.on_death.connect(on_death)

func on_state_change(new_state : State):
	if cashed_state == new_state:
		return
	cashed_state = new_state
	propagate_change_counter.rpc(new_state in aggroed_states)

func on_death() -> void:
	change_counter(false)

@rpc("call_local", "any_peer", "unreliable")
func propagate_change_counter(contribution : bool) -> void:
	change_counter(contribution)

func change_counter(contribution : bool) -> void:
	if contributes_to_counter:
		if not contribution:
			contributes_to_counter = false
			quick_dynamic_music.update_danger_count(-1)
	else:
		if contribution:
			contributes_to_counter = true
			quick_dynamic_music.update_danger_count(1)
