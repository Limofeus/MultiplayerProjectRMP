@icon("res://editor/custom script icons/dialogue/message-circle-pin.svg")
extends Node3D
class_name SimpleDialoguePoint #Utility class for faster and easier setup of dialogues

@export var default_tinkerable_area : TinkerableArea = null
@export var dialogue_updater : TinkerableDialogueUpdater = null

@export_group("Window position connection")
@export var auto_connect_window : bool = true
@export var dialogue_window_visual : DialogueWindowVisual = null
@export var world_ui_reposition : WorldBasedControlAlter = null

var dynamic_anchor_node : Node3D = null
var use_default_tinkerable_area : bool = true

func _enter_tree():
	print("SDP ready")
	if dynamic_anchor_node == null:
		dynamic_anchor_node = self

	for i in range(1, get_child_count()):
		var child = get_child(i)
		print("SDP child:", child.name)
		if child is DialogueActorVisual:
			process_dialogue_actor_visual(child)
		elif child is DialogueTrigger:
			print("Setting triggers")
			dialogue_updater.dialogue_triggers.append(child)

	connect_window()

func _ready():
	if use_default_tinkerable_area:
		default_tinkerable_area.reparent(self)
		default_tinkerable_area.position = Vector3.ZERO


func process_dialogue_actor_visual(dialogue_actor_visual : DialogueActorVisual):
	if dialogue_actor_visual.dynamic_dialogue_point != null:
		dynamic_anchor_node = dialogue_actor_visual.dynamic_dialogue_point
	if dialogue_actor_visual.tinkerable_area_override != null:
		dialogue_updater.tinkerable_dialogue.tinker_center_node = dialogue_actor_visual.tinkerable_area_override
		dialogue_actor_visual.tinkerable_area_override.tinkerable = dialogue_updater.tinkerable_dialogue
		default_tinkerable_area.queue_free()
		use_default_tinkerable_area = false

func connect_window():
	if !auto_connect_window:
		return

	#May use diff way to connect this all later (rn just grabbing things from dynamic window variables)
	world_ui_reposition.target_position_node = dynamic_anchor_node
	world_ui_reposition.control_to_reposition = dialogue_window_visual.scale_copy_node
	world_ui_reposition.size_ref_container = dialogue_window_visual.dynamic_dialogue_box_container
	world_ui_reposition.modulate_node = dialogue_window_visual.modulate_item
