extends CreatureInventoryComponent
class_name PlayerInventoryComponent

#Streamline this so that all creatures can have an inventory
@export var player_hotbar_component : PlayerHotbarComponent = null

func _ready():
	super()

func _input(event):
	if network_entity.has_authority():
		if event is InputEventMouseButton and event.pressed:
			if Input.is_action_just_pressed("hotbar_increment"):
				offset_selected_slot(1)
			if Input.is_action_just_pressed("hotbar_decrement"):
				offset_selected_slot(-1)