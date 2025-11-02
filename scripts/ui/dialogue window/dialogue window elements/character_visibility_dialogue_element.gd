extends DialogueWindowElement
class_name CharacterVisibilityDialogueElement

@export
var sprite_control : Control = null
@export
var name_control : Control = null

@export
var char_sprite_key_name : String = "speaker_texture"
@export
var char_name_key_name : String = "speaker_name"

@export var anim_curve : Curve = null

var sprite_visible : bool = false
var name_visible : bool = false

var sprite_visibility_value : float = 0.0
var name_visibility_value : float = 0.0

var start_sprite_pos : Vector2 = Vector2.ZERO
var start_name_pos : Vector2 = Vector2.ZERO

@export
var sprite_show_up_time : float = 0.4
@export
var name_show_up_time : float = 0.3

@export
var sprite_hidden_offset : Vector2 = Vector2.ZERO
@export
var name_hidden_offset : Vector2 = Vector2.ZERO


func _ready():
	super()
	start_sprite_pos = sprite_control.position
	start_name_pos = name_control.position

func _process(delta):
	sprite_visibility_value = move_toward(sprite_visibility_value, 1.0 if sprite_visible else 0.0, delta / sprite_show_up_time)
	name_visibility_value = move_toward(name_visibility_value, 1.0 if name_visible else 0.0, delta / name_show_up_time)

	var sprite_value = anim_curve.sample(sprite_visibility_value)
	var name_value = anim_curve.sample(name_visibility_value)

	sprite_control.position = lerp(start_sprite_pos + sprite_hidden_offset, start_sprite_pos, sprite_value)
	name_control.position = lerp(start_name_pos + name_hidden_offset, start_name_pos, name_value)

	sprite_control.self_modulate.a = sprite_value
	name_control.self_modulate.a = name_value

func dialogue_metadata_updated(metadata : Dictionary) -> void:
	var char_sprite : Texture = StaticUtility.get_dict_value_if_present(metadata, char_sprite_key_name)
	var char_name = StaticUtility.get_dict_value_if_present(metadata, char_name_key_name)

	var tinkerable_in_focus = StaticUtility.get_dict_value_if_present(metadata, "tinkerable_state") == Tinkerable.TinkerableState.Focused

	sprite_visible = tinkerable_in_focus && char_sprite != null
	name_visible = tinkerable_in_focus && char_name != null && char_name != ""
