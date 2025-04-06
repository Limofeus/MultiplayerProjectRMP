extends OwnerChangeComponent
class_name TimedOwnerChangeComponent

@export var minimum_owner_change_interval : float = 0.2

var last_owner_change_time : float = 0.0


func change_owner(new_owner : int, propagate : bool = false) -> void:
	if last_owner_change_time + minimum_owner_change_interval < Time.get_unix_time_from_system():
		super.change_owner(new_owner, propagate)
		last_owner_change_time = Time.get_unix_time_from_system()

	else:
		print("Timer prevented owner change")