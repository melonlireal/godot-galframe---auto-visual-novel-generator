extends Resource
class_name CGS
@export var cg_list = []
@export var cg_cover_list = []

func add_cg(cg: String, cg_cover: String):
	cg_list.append(cg)
	cg_cover_list.append(cg_cover)
	return
	
func get_cg():
	return cg_list
	
func get_cg_cover():
	return cg_cover_list

func check_unlock(cg_name: String):
	if cg_name in cg_list:
		var game_progress:GlobalGameProgress = ResourceLoader.load(GlobalResources.global_progress_path)
		game_progress.add_cg(cg_name)
		ResourceSaver.save(game_progress, GlobalResources.global_progress_path)
