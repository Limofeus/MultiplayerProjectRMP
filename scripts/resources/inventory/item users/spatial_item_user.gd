extends ItemUser
class_name SpatialItemUser

var item_use_node : Node3D = null #Node that represents position, rotation (maybe even scale idk) from which the item is used (can be used for raycasts, instatiation of projectiles, etc.)
var team_id : int = 0

func _init(spatial_node : Node3D, _team_id : int): #Default value REMOVED because I forgot to set it and wondered *ph hey, where did this bug come from :o
	item_use_node = spatial_node
	team_id = _team_id