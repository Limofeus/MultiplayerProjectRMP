extends Resource
class_name DialogueTextProcessor

signal finished_printing_text()

var time_to_print_letter : float = 0.03
var accumulated_time : float = 0.0
var time_since_done_printing : float = 0.0

var letters_printed : int = 0
var text_letter_count : int = 0
var stripped_text : String = ""

var text_labels : Array[RichTextLabel] = []

var done_printing : bool = true


var dialogue_symbol_sound_mapping : DialogueSymbolSoundsMapping = null
var audio_source : AudioStreamPlayer = null


#idk, parse tags inside text etc.
func prepare_text(text : String) -> String: #Returns final result for window scaling, etc.
	letters_printed = 0
	accumulated_time = 0
	done_printing = false

	var strip_tags_regex = RegEx.new()
	strip_tags_regex.compile("\\[(?![lr]b\\]).*?\\]")
	stripped_text = strip_tags_regex.sub(text, "", true).replace("[lb]", "[").replace("[rb]", "]") #TODO: Я хз, подумать над этим ещё, через RegEX BBCode очищать криво как то

	text_letter_count = stripped_text.length()

	return text

func get_letter_print_time() -> float:
	return time_to_print_letter #NOTE: Can add a lookup table to make different letter take different amount of time

func on_letter_printed() -> void:
	if audio_source != null && dialogue_symbol_sound_mapping != null:

		if letters_printed > stripped_text.length():
			return

		var current_letter = stripped_text[letters_printed - 1]
		#print("CL: " + current_letter, "   ", letters_printed - 1, "/", stripped_text.length() - 1)

		var symbol_sound_clip = dialogue_symbol_sound_mapping.get_symbol_sound(current_letter.to_lower())
		var pitch_variation = dialogue_symbol_sound_mapping.pitch_variation
		if symbol_sound_clip != null:
			audio_source.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
			audio_source.stream = symbol_sound_clip
			audio_source.play(0.0)

func text_process_step(delta):
	if done_printing:
		time_since_done_printing += delta
		return

	accumulated_time += delta

	while accumulated_time >= get_letter_print_time() and !done_printing:
		accumulated_time -= get_letter_print_time()
		letters_printed += 1
		on_letter_printed()
		if letters_printed > text_letter_count:
			done_printing = true

	for text_label in text_labels:
		text_label.visible_characters = letters_printed

	if done_printing:
		time_since_done_printing = 0.0;
		finished_printing_text.emit()

func skip_text_printing():
	letters_printed = text_letter_count + 1
	done_printing = true

	for text_label in text_labels:
		text_label.visible_characters = text_letter_count
	finished_printing_text.emit()
