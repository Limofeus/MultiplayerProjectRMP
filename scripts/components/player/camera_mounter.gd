extends UnsyncedComponent


@export var camera_mount : Node3D
#@export var unsynced_node_path : String = "/root/Main/CameraRig" #Cant override defaould values in godot

func _process(_delta):
	if camera_mount:
		unsynced_node.global_transform = camera_mount.global_transform
