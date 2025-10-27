extends DialogueWindowElement
class_name VisibilityBasedOnExpressionWindowElement

@export var expression : String = "val(\"speaker_name\")"


func dialogue_metadata_updated(metadata : Dictionary) -> void:
	print("Expression result: ", StaticUtility.expression_on_dict(metadata, expression))