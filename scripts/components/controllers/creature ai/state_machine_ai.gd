extends CreatureAIComponent
class_name StateMachineAI 

#Here shall begin my longing for traits in godot... untill then I'll have to copy my state machine code in to here..

#Actually, I won't have time (and courage rn) to code this properly rn, so I'll just hardcode 2 ai types

#To be continued...

#The continuation is now.. ;_;

@export var current_state : State

signal on_state_changed(new_state : State)

func _ready() -> void:
	current_state._on_enter()

func _process(delta: float) -> void:
	change_state_if_needed()
	current_state._on_update(delta)
	DebugDraw2D.set_text("Current AI state:", current_state.name)

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

			on_state_changed.emit(current_state)
			break