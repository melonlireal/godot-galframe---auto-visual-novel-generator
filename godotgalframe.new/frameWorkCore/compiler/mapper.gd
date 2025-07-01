extends Node
var save_path = "res://save/"
@export var auto_color = false
# auto assign BBcode around respected character's
# name and script so no need to manually color each line
@export var narrator_color = "434444"
# to adjust the color of narrator

func _ready():
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	$header_compile.compile_headers()
	$asset_compile.compile_asset()
	$dialogue_compile.compile_dialogues()
	print("COMPILE COMPLETE")
	
func helper_search_file(directory: String, files: String):
	# recursion helper
	# 智力巅峰, 然而崩了一次，BUG还复现不出来。
	var direction = DirAccess.open(directory)
	if files not in direction.get_files() and direction.get_directories().is_empty():
		return null
	if files in DirAccess.open(directory).get_files():
		return directory + "/" + files
	else:
		for path in DirAccess.open(directory).get_directories():
			if helper_search_file(directory +"/" + path+ "/", files) != null:
				return helper_search_file(directory +"/" + path, files)
		return null
