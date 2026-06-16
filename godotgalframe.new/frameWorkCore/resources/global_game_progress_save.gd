extends Resource
class_name GlobalGameProgress
# global game progress is used to track progess that needs to exists around
# multiple game save, for example, cg and story tree are not unlocked based
# on current progress in save 

@export var explored_chapters:Array[String] = []
@export var unlocked_cg:Array[String] = []


func add_chap(chap_name: String):
	if chap_name not in explored_chapters:
		explored_chapters.append(chap_name)
	
func has_chap(chap_name: String):
	return chap_name in explored_chapters

func add_cg(cg_name: String):
	if cg_name not in unlocked_cg:
		unlocked_cg.append(cg_name)

func has_cg(cg_name: String):
	return cg_name in unlocked_cg
	
