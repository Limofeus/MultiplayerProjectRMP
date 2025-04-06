extends EntityComponent
class_name PlayerInputComponent

@export var movement_input_interface : MovementInputInterface = null

signal primary_action()
#TODO: improve, intended to be swapped for ai input or something else for mobs and stuff
func _unhandled_input(event : InputEvent):
	if !network_entity.has_authority():
		return
	if event.is_action_pressed("primary_action"):
		primary_action.emit()

func update_movement_input_interface():
	movement_input_interface.movement_vector = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
	movement_input_interface.jump_pressed = Input.is_action_pressed("player_jump")
	movement_input_interface.dash_pressed = Input.is_action_pressed("player_dash")

func _process(delta):
	update_movement_input_interface()

func _physics_process(delta):
	update_movement_input_interface()
