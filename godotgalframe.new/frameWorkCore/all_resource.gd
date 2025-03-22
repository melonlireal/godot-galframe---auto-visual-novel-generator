extends Resource
class_name AssetPath

@export var resource_dic = {}

func clear():
	resource_dic = {}

func add_path(file: String, path: String):
	resource_dic[file] = path

func search_path(file: String):
	return resource_dic.get(file)
