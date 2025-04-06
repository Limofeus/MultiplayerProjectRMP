extends EntityComponent
class_name MovementInputInterface

const M_FORWARD : Vector2 = Vector2.LEFT
const M_BACKWARD : Vector2 = Vector2.RIGHT
const M_RIGHTWARD : Vector2 = Vector2.DOWN
const M_LEFTWARD : Vector2 = Vector2.UP

var movement_vector : Vector2 = Vector2.ZERO
var jump_pressed : bool = false 
var dash_pressed : bool = false

func get_movement_vector() -> Vector2:
	return movement_vector

func get_jump_input() -> bool:
	return jump_pressed

func get_dash_input() -> bool:
	return dash_pressed