extends Node3D

@export var spin_speed : float = 2.0
@export var spin_axis : Vector3 = Vector3.UP

func _process(delta):
	rotate(spin_axis, spin_speed * delta)