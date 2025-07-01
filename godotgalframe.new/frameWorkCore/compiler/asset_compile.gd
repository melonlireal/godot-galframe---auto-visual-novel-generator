extends Node
var save_path = "res://save/"
var asset_save = "mapper_total.tres"
var res_background = "res://artResource/background/"
var res_character = "res://artResource/character/"
var res_music = "res://music/"
# Called when the node enters the scene tree for the first time.

func compile_asset():
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	var assets = AssetPath.new()
	ResourceSaver.save(assets, save_path + asset_save)
	find_all_asset(res_background)
	find_all_asset(res_character)
	find_all_asset(res_music)

func find_all_asset(dir: String):
	# find all file and location under the respected folder
	# and save them in mapper_total
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = $"..".helper_search_file(dir, file)
		var mapper = ResourceLoader.load(save_path + asset_save)
		mapper.add_path(file, location)
		print("mapped ", file, " to location ", location)
		ResourceSaver.save(mapper, save_path + asset_save)
	for directories in files.get_directories():
		find_all_asset(dir + "/" + directories)
		
