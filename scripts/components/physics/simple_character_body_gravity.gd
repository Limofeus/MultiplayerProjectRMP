extends Node

@export var gravity : float = 10
@export var character_body : CharacterBody3D
@export var apply_move_and_slide : bool = true

func _physics_process(delta):
	if(!character_body.is_on_floor()):
		character_body.velocity += Vector3.DOWN * gravity * delta
	if apply_move_and_slide:
		character_body.move_and_slide()