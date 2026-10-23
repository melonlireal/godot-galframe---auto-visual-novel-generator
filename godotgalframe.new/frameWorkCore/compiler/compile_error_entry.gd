extends PanelContainer
class_name CompileErrorEntry

@export var message: String = ""

@onready var message_label: Label = $message_label

func _ready() -> void:
	message_label.text = message
