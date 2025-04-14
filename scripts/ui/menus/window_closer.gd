extends Node

@export var window : Window = null

func _ready():
	window.close_requested.connect(close_window)

func close_window():
	window.queue_free()