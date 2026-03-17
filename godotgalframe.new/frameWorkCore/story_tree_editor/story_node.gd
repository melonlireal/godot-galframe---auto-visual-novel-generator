extends TextureButton
class_name  StoryNode
var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
## name of this node shown in story tree after player reached first section
@export var section_name: String = ""
## section name when player havn't reached this section default as ???????
@export var section_name_locked: String = "???????"
## this story node will be unlocked when this chapter name is reached
@export var unlock_chap: String = ""
# TODO, travel chap may not fit well with current variable settings
## the chapter this story node will load when it is cliecked
@export var travel_chap: String = ""
## it is advised to turn off this section when the chapter has variable requirements
@export var enable_travel = true
## if you want player to be able to travel to variable related chapter
## fill the variables at the start of chapter in here
@export var variable_when_travel = {}
@onready var displayed_section_name: RichTextLabel = $displayed_section_name

signal load_chapter
var locked = false
# you do not need to edit any code here
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	displayed_section_name.text = section_name_locked

func unlock():
	displayed_section_name.text = section_name
	locked = false
	pass


func _on_pressed() -> void:
	if not locked and enable_travel:
		load_chapter.emit(travel_chap, variable_when_travel)
