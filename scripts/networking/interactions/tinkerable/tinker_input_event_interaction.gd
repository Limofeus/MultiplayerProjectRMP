extends TinkerInteraction
class_name TinkerInputEventInteraction
#Packs input event in to tinker interaction.. maybe there's a better way to pass input events to tinkerables?

var input_event : InputEvent = null

func _init(_input_event : InputEvent):
	input_event = _input_event