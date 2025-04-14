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
var prev_text = {}
var dialogue_list = []
@export var character_based_color = false
# Called when the node enters the scene tree for the first time.
# TODO
# refactor dialogue_proof_read such that it proofs reads chapters in the same order
# as actual game play
# for example, when start has 2 choices a, b where a link to c and b links to d
# it will first proofread a , then c, then b, then d
# i.e dfs
# this will assure correct commands are extended
# I think to todo is completed

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
	dialogue_list = find_all_dialogue(res_dialogue)
	print(dialogue_list)
	dialogue_proof_read(["Start.txt", "res://dialogue/Start.txt"])
	# compile 文案
	print("COMPILE COMPLETE")
# Called every frame. 'delta' is the elapsed time since the previous frame.

func find_all_file(dir: String):
	# find all file and location under the respected folder
	# and save them in mapper_total
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = helper_search_file(dir, file)
		var mapper = ResourceLoader.load("res://save/mapper_total.tres")
		mapper.add_path(file, location)
		print("mapped ", file, " to location ", location)
		ResourceSaver.save(mapper, "res://save/mapper_total.tres")
	for directories in files.get_directories():
		find_all_file(dir + "/" + directories)

func find_all_dialogue(dir: String):
	# find all txt file and their respected link
	# under dialogue folder and return as a list
	var all_dialogue = []
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = helper_search_file(dir, file)
		all_dialogue.append([file, location])
		print("find dialogue ", file, " at location ", location)
	for directories in files.get_directories():
		all_dialogue += find_all_dialogue(dir + "/" + directories)
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

func helper_find_chapter_from_choice(which_chap: String):
	# a helper function that returns the respected txt path based on
	# chapter name
	for chapters in dialogue_list:
		if chapters[0] == which_chap:
			return chapters

func dialogue_proof_read(chapter: Array):
	var character;
	var dialogue;
	var command;
	var text;
	
	var chap_name = chapter[0]
	var chap_dir = chapter[1]
	var file = FileAccess.open(chap_dir, FileAccess.READ)
	var script_tree = ResourceLoader.load("res://save/processed_script.tres")
	script_tree.change_chapter(chap_name)
	while !file.eof_reached():
		text = file.get_line()
		if text == "choice":
			var choices = get_choice(file)
			script_tree.add_choice(choices, prev_command, prev_text)
			# the art and text at choice block MUST be from previous line
			file.close()
			ResourceSaver.save(script_tree, "res://save/processed_script.tres")
			for choice in choices:
				dialogue_proof_read(helper_find_chapter_from_choice(choice[1]))
			return
		text = text.replace("：", ":")
		character = text.substr(0, text.find(":") + 1)
		# this includes the ":"
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
			print("since current command is empty, commands have been extended!\n")
			command_list = extend_commands()
		# if there is no command, it means the line follows the command 
		# from previous line, except voice and charatcer transition
		# this allows the art/music to always be displayed when loading
		extend_music(command_list)
		print("after extend music ", command_list, "\n")
		extend_background(command_list)
		print("after extend background ", command_list, "\n")
		prev_command = command_list
		character = character.substr(0, len(character) - 1)
		# remove the ":"
		prev_text = {"character": character, "dialogue": dialogue}
		if not (character == "" and dialogue == "" and command_list == []):
			script_tree.add_line(character, dialogue, command_list)
		# make sure complete empty line are ignored
	script_tree.clear_save()
	ResourceSaver.save(script_tree, "res://save/processed_script.tres")
	return
	

func process_commands(commands: String):
	#return the list of commands
	var format = RegEx.new()
	format.compile("[(][^)]*[)]")
	var order_list = []
	for order in format.search_all(commands):
		var temp = order.get_string().substr(1).left(-1)
		order_list.append(Array(temp.replace(" ", "").rsplit(",")))
	print("processed commands are", order_list, "\n")
	return help_fix_commands(order_list)

func help_fix_commands(order_list: Array):
	#pre process the commands into the format that can be used by 
	#internal code. Allows user to type less complex command and
	#get the same effect
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
	print("fixed commands are: ", fixed_commands, "\n")
	return fixed_commands

func extend_commands():
	# make current empty command prev command so 
	# when load it loads all the art and music resource
	var extended = []
	for command in prev_command:
		if command[0] != "voice" and command[1] != "clear":
			extended.append(command)
	return extended

func extend_background(order_list: Array):
	for command in order_list:
		if command[0] == "background" or command[0] == "CG":
			return
	for command in prev_command:
		if command[0] == "background":
			order_list.append(command)
	return
	
func extend_music(order_list: Array):
	for command in order_list:
		# first confirm there isn't a change in music
		if command[0] == "bgm":
			return
	for command in prev_command:
		if command[0] == "bgm" and command[1] != "clear":
			order_list.append(command)
	return

#return the list of choices and respected new chapter	
func get_choice(file: FileAccess):
	var choice_list = []
	while not file.eof_reached():
		var line = file.get_line()
		if line != "":
			var choice_text = line.substr(0, line.rfind(" "))
			var going_to= line.substr(line.rfind(" ") + 1)
			choice_list.append([choice_text, going_to])
		# 将所有的选项都放进一个列表里
	return choice_list
		
