extends Resource
class_name GameplaySetting 
# this is the save file for internal settings that can only be
# accessed by creator 
@export var setting_list = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func add_setting(var_name, var_value):
	setting_list[var_name] = var_value
	
func get_setting(var_name):
	return setting_list[var_name]
