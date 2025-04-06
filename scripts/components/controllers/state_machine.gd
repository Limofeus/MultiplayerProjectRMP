extends EntityComponent
class_name StateMachineComponent

@export var current_state : State

func _ready() -> void:
	current_state._on_enter()

func _process(delta: float) -> void:
	change_state_if_needed()
	current_state._on_update(delta)
	DebugDraw2D.set_text("Current state:", current_state.name)

func _physics_process(delta: float) -> void:
	change_state_if_needed()
	current_state._on_physics_update(delta)

func change_state_if_needed() -> void:
	if current_state.state_locked():
		return
	for transition_state : State in current_state.next_states:
		if transition_state.check_conditions():
			current_state._on_exit()
			current_state = transition_state
			current_state._on_enter()
			break
