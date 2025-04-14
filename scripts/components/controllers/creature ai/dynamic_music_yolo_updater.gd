extends UnsyncedComponent

@export var yolo_ai : DumbYoloAIComponent = null
@export var creature_attributes : CreatureAttributes = null

var contributes_to_counter : bool = false

var quick_dynamic_music : QuickDynamicMusic = null

func _ready() -> void:
	super()
	quick_dynamic_music = unsynced_node
	yolo_ai.target_updated.connect(on_aggro_change)
	creature_attributes.on_death.connect(on_death)

func on_aggro_change(aggroed : bool):
	propagate_change_counter.rpc(aggroed)

func on_death() -> void:
	change_counter(false)

@rpc("call_local", "any_peer", "unreliable")
func propagate_change_counter(contribution : bool) -> void:
	change_counter(contribution)

func change_counter(contribution : bool) -> void:
	if contributes_to_counter:
		if not contribution:
			contributes_to_counter = false
			quick_dynamic_music.update_danger_count(-1)
	else:
		if contribution:
			contributes_to_counter = true
			quick_dynamic_music.update_danger_count(1)
