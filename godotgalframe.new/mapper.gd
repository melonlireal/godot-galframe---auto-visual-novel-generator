extends Node
var save_path = "res://save/"
var save_file = "mapper_total.tres"
var scripts = "processed_script.tres"
var res_background = "res://artResource/background/"
var res_character = "res://artResource/character/"
var res_music = "res://music/"
var res_dialogue = "res://dialogue/"
var dialogue_start = "res://dialogue/Start.txt"
var prev_command = []
# Called when the node enters the scene tree for the first time.


func _ready():
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	var compile_data = AssetPath.new()
	var script_tree = ScriptTree.new()
	ResourceSaver.save(compile_data, save_path + save_file)
	ResourceSaver.save(script_tree, save_path + scripts)
	# 先创建对应的保存文件
	find_all_file(res_background)
	find_all_file(res_character)
	find_all_file(res_music)
	# compile所有的美术和音乐素材
	find_all_file(res_dialogue) # idk if this is useful anymore
	var dialogue_list = find_all_dialogue(res_dialogue)
	print(dialogue_list)
	for chapter in dialogue_list:
		dialogue_proof_read(chapter)
	# compile 文案
	print("COMPILE COMPLETE")
# Called every frame. 'delta' is the elapsed time since the previous frame.


func find_all_file(dir: String):
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = helper_search_file(dir, file)
		var mapper = ResourceLoader.load("res://save/mapper_total.tres")
		mapper.add_path(file, location)
		# print("mapped ", file, " to location ", location)
		ResourceSaver.save(mapper, "res://save/mapper_total.tres")
	for directories in files.get_directories():
		find_all_file(dir + "/" + directories)

func find_all_dialogue(dir: String):
	var all_dialogue = []
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = helper_search_file(dir, file)
		all_dialogue.append([file, location])
		print("find dialogue ", file, " at location ", location)
	for directories in files.get_directories():
		all_dialogue += find_all_file(dir + "/" + directories)
	return all_dialogue
	
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

func dialogue_proof_read(chapter: Array):
	var text;
	var character;
	var dialogue;
	var command;
	var chap_name = chapter.pop_front()
	var chap_dir = chapter.pop_front()
	var file = FileAccess.open(chap_dir, FileAccess.READ)
	var script_tree = ResourceLoader.load("res://save/processed_script.tres")
	script_tree.change_chapter(chap_name)
	while !file.eof_reached():
		text = file.get_line()
		if text == "choice":
			script_tree.add_choice(get_choice(file))
			file.close()
			ResourceSaver.save(script_tree, "res://save/processed_script.tres")
			return
		text = text.replace("：", ":")
		character = text.substr(0, text.find(":")+1)
		if character == " command:" or character == ":":
			character = ""
			#清理特殊字符command和隔开角色和台词的：
			#同时考虑到该行没有人物或对话的情况
		if text.find(" command:") != -1:
			dialogue = text.substr(text.find(":") + 1, text.find(" command:") - text.find(":"))
		else:
			dialogue = text.substr(text.find(":") + 1, text.find(" command:"))
			#根据是否有command隔离开dialogue和角色
		dialogue = dialogue.replace("\\command:", "command:")
		command = text.substr(text.find(" command:"))
		var command_list = process_commands(command)
		if command_list == []:
			command_list = extend_commands()
		# if there is no command, it means the line follows the command 
		# from previous line, except voice and charatcer transition
		# this allows the art/music to always be displayed when loading
		prev_command = command_list
		script_tree.add_line(character, dialogue, command_list)
	script_tree.clear_save()
	ResourceSaver.save(script_tree, "res://save/processed_script.tres")
	return
	
#return the list of commands
func process_commands(commands: String):
	var format = RegEx.new()
	format.compile("[(][^)]*[)]")
	var order_list = []
	for order in format.search_all(commands):
		var temp = order.get_string().substr(1).left(-1)
		order_list.append(Array(temp.replace(" ", "").rsplit(",")))
	print(order_list)
	return help_fix_commands(order_list)

#pre process the commands into the format that can be used by 
#internal code. Allows user to type less complex command and
#get the same effect
func help_fix_commands(order_list: Array):
	var fixed_commands = []
	for order in order_list:
		var temp = []
		var which_order = order[0]
		print("current order is ", order, "\n")
		match which_order:
			"character":
				if order.size() == 5:
					# complete command
					fixed_commands.append(order)
				elif order.size() == 4:
					# did not include transition
					temp = [order[0], order[1], order[2], order[3], "false"]
					fixed_commands.append(temp)
				elif order.size() == 3:
					temp = [order[0], order[1], order[2], "character", "false"]
					fixed_commands.append(temp)
				else:
					temp = [order[0], order[1], "mid", "character", "false"]
					fixed_commands.append(temp)
			"background":
				if order.size() == 4:
					fixed_commands.append(order)
				elif order.size() == 3:
					temp = [order[0], order[1], order[2], "false"]
					fixed_commands.append(temp)
				else:
					temp = [order[0], order[1], "true", "false"]
					fixed_commands.append(temp)
			"bgm", "sound_effect", "voice":
				fixed_commands.append(order)
			"CG":
				fixed_commands.append(order)
				print("CG")
	print("fixed commands are: ", fixed_commands, "\n")
	return fixed_commands

func extend_commands():
	var extended = []
	for command in prev_command:
		if command[0] != "voice":
			extended.append(command)
	return extended
#return the list of choices and respected new chapter
func get_choice(file: FileAccess):
	var choice_list = []
	while not file.eof_reached():
		var line = file.get_line()
		if line != "":
			choice_list.append(line)
		# 将所有的选项都放进一个列表里
	return choice_list
		
