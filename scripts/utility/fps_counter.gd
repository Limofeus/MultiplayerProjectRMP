extends Node

func _process(delta: float) -> void:
	DebugDraw2D.set_text("FPS", Engine.get_frames_per_second())