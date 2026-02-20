extends Node

# Called when the node enters the scene tree for the first time.
var save_path = "res://save/"
var asset_save = "internal_setting.tres"

# The below section is background setting in gameplay
@export var review_dialogue_limit = 30
# the upper limit of dialogue to review
@export var review_dialogue_narrator_name = "[color=434444]旁白[/color]"
# if a dialogue is naration, it will be displaced with this narrator name
# in review dialogue
@export var auto_clear_bgm = false
@export var auto_clear_sound_effect = false
@export var auto_clear_voice = false
# The above section is background setting in gameplay


# TODO NOT COMPLETED YET
#TODO SHIT CODE FIX LATER 
# WHEN FIGUREOUT HOW TO USE get_property_list() PREPERLY
func _ready() -> void:
	var settings = GameplaySetting.new()
	settings.add_setting("limit", review_dialogue_limit)
	settings.add_setting("narrator", review_dialogue_narrator_name)
	settings.add_setting("auto_clear_bgm", auto_clear_bgm)
	settings.add_setting("auto_clear_sound_effect", auto_clear_sound_effect)
	settings.add_setting("auto_clear_voice", auto_clear_voice)
	ResourceSaver.save(settings, save_path + asset_save)
	return
