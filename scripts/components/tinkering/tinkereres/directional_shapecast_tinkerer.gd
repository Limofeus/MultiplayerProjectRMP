extends EntityComponent

@export var scan_tinkereres : bool = true

@export var dot_check_node : Node3D = null
@export var tinker_shapecast : ShapeCast3D = null

var tinkerable_display_state_dict : Dictionary[Tinkerable, Tinkerable.TinkerableState] = {}
var focused_tinkerable : Tinkerable = null

class TinkerDisplayParams:
	var is_visible : bool
	var view_angle_dot : float

	func _init(_is_visible : bool, _view_angle_dot : float):
		is_visible = _is_visible
		view_angle_dot = _view_angle_dot

func _process(delta):
	if scan_tinkereres:
		update_shapecast()

func _input(event):
	for tinkerable in tinkerable_display_state_dict.keys():
		tinkerable.recieve_interaction(TinkerInputEventInteraction.new(event), network_entity)

func update_shapecast():
	var tinkerable_list : Array[Tinkerable]
	tinker_shapecast.force_shapecast_update()
	for i in tinker_shapecast.get_collision_count():
		var collision_area : Area3D = tinker_shapecast.get_collider(i)
		if collision_area is TinkerableArea:
			tinkerable_list.append(collision_area.tinkerable)

	update_tinkerable_list(tinkerable_list)

func update_tinkerable_list(new_tinkerable_list : Array[Tinkerable]):
	var new_tinkerable_visibility_dict : Dictionary[Tinkerable, Tinkerable.TinkerableState] = {}
	var highest_view_angle_tinkerable : Tinkerable = null
	var highest_view_angle_dot : float = -1.0
	focused_tinkerable = null

	# --- Calculate new tinkerable list
	for tinkerable in new_tinkerable_list:
		var tinkerable_display_info : TinkerDisplayParams = calc_tinkerable_visinility(tinkerable)
		
		if tinkerable_display_info.is_visible and tinkerable_display_info.view_angle_dot > highest_view_angle_dot:
			highest_view_angle_dot = tinkerable_display_info.view_angle_dot
			highest_view_angle_tinkerable = tinkerable

		new_tinkerable_visibility_dict[tinkerable] = Tinkerable.TinkerableState.Unfocused if tinkerable_display_info.is_visible else Tinkerable.TinkerableState.Hidden
	if highest_view_angle_tinkerable != null:
		new_tinkerable_visibility_dict[highest_view_angle_tinkerable] = Tinkerable.TinkerableState.Focused
		focused_tinkerable = highest_view_angle_tinkerable

	# --- Update current list sending state updates to tinkerables
	for tinkerable in tinkerable_display_state_dict.keys():
		if new_tinkerable_visibility_dict.has(tinkerable):
			try_update_tinkerable_dict_entry(tinkerable, new_tinkerable_visibility_dict[tinkerable])
			new_tinkerable_list.erase(tinkerable)
		else:
			try_update_tinkerable_dict_entry(tinkerable, Tinkerable.TinkerableState.Hidden)
			tinkerable_display_state_dict.erase(tinkerable)
	
	for tinkerable in new_tinkerable_list:
		tinkerable_display_state_dict[tinkerable] = Tinkerable.TinkerableState.Hidden #Assumes tinkerables start out hidden
		tinkerable.tree_exiting.connect(on_tinkerable_tree_exit.bind(tinkerable))
		try_update_tinkerable_dict_entry(tinkerable, new_tinkerable_visibility_dict[tinkerable]) #Updates if it should be visible

func on_tinkerable_tree_exit(tinkerable : Tinkerable) -> void:
	try_update_tinkerable_dict_entry(tinkerable, Tinkerable.TinkerableState.Hidden)
	tinkerable_display_state_dict.erase(tinkerable)

func try_update_tinkerable_dict_entry(update_tinkerable : Tinkerable, new_value : Tinkerable.TinkerableState):
	if tinkerable_display_state_dict[update_tinkerable] != new_value:

		update_tinkerable.recieve_interaction(TinkerVisibilityUpdateInteraction.new(new_value), network_entity) #NOTICE: this sends interaction DIRECTLY to focused component because 1) This way it doesnt has to be part of entity, 2) Entity can have multiple tinkerable components and it should work fine

		print("TINK| Update " + str(update_tinkerable) + " to " + str(new_value))
		tinkerable_display_state_dict[update_tinkerable] = new_value

func calc_tinkerable_visinility(tinkerable : Tinkerable) -> TinkerDisplayParams:
	var forward_dir = -dot_check_node.global_basis.z
	var tinkerable_node_dir = dot_check_node.global_position.direction_to(tinkerable.tinker_center_node.global_position)
	var angle_visible : bool = forward_dir.dot(tinkerable_node_dir) > tinkerable.tinker_angle_dot
	var distance_visible : bool = dot_check_node.global_position.distance_to(tinkerable.tinker_center_node.global_position) < tinkerable.tinker_range

	return TinkerDisplayParams.new(angle_visible and distance_visible, forward_dir.dot(tinkerable_node_dir))
