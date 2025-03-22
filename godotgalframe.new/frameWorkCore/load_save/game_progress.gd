extends Resource
class_name progress_data
@export var which_file = "Start.txt"
@export var which_line = 0

func get_type():
	return "progress data, only includes which file and which line"
