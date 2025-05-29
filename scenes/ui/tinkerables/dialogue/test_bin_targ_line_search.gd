@tool
extends RichTextLabel

const MAX_ITERS : int = 30

@export var targ_line_count : int = 4
@export var start_max_size : float = 2000.0
@export var container_to_apply_size_to : Container = null


@export_tool_button("Do shit")
var button = do_shit

func do_shit():
	custom_minimum_size.x = 0.0

	var min_size : float = 0.0
	var max_size : float = start_max_size
	var last_comfortable_size : float = 0.0
	for i in range(MAX_ITERS):
		var check_size : float = (min_size + max_size) / 2.0
		if check_step_size(check_size):
			min_size = check_size
		else:
			last_comfortable_size = check_size + 1.0
			max_size = check_size
	if container_to_apply_size_to == null:
		size.x = last_comfortable_size
		size.y = 0.0
	else:
		custom_minimum_size.x = last_comfortable_size
		size.y = 0.0
		scale_to_zero_ig.call_deferred()

func scale_to_zero_ig():
	container_to_apply_size_to.size.x = 0.0
	container_to_apply_size_to.size.y = 0.0

func check_step_size(cur_size : float) -> bool:
	size.x = cur_size
	return get_line_count() > targ_line_count