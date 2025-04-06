extends Node

@export var character_body : CharacterBody3D
@export var move_speed : float = 5.0
@export var rotation_speed : float = 2

func _physics_process(delta):
	var input_vector : Vector2 = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
	character_body.velocity = (character_body.transform.basis.z * input_vector.x * move_speed) + (Vector3.UP * character_body.velocity.y)
	character_body.rotate(Vector3.UP, -rotation_speed * input_vector.y * delta)