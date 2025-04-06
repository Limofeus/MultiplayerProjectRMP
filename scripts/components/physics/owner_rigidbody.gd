extends EntityComponent

@export var rigidbody : RigidBody3D

func on_owner_change():
	if(network_entity.has_authority()):
		rigidbody.freeze = false
	else:
		rigidbody.freeze = true