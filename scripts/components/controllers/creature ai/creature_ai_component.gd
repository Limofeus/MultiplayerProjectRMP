extends EntityComponent
class_name CreatureAIComponent

#Most AI's will probably need this, so I'll make it a base class
#And if not... well, just don't use it I guess

@export var creature_attributes : CreatureAttributes = null #Attributes for controlled creature
@export var targeting_component : TargetingComponent = null #Targeting component for finding allied, enemy or other creatures
@export var movement_input_interface : MovementInputInterface = null #Interface between AI and movement components, allows different AI's to be used with different movement types, uses local vector2.
@export var rotation_input_interface : RotationInputInterface = null #Interface for AI to control rotation and aim, you better use normalized global vector, dunno what happens if you dont.

signal use_item() #Signal for using an item in hand
signal change_item_slot(item_slot : int) #Signal for changing selected item