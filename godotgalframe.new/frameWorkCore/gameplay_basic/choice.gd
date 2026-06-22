class_name Choice
extends TextureButton

signal travel_to_new_chap(loaction: String)

@onready var choice_text_label: Label = $center/choice_text


@export var choice_description:String
@export var travel_chapter:String
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	choice_text_label.text = choice_description

func _on_pressed():
	travel_to_new_chap.emit(travel_chapter)
