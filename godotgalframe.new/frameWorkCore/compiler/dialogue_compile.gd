extends Node
var save_path = "res://save/"
var scripts_file = "processed_script.tres"
var head_file = "header.tres"
var res_dialogue = "res://dialogue/"
var dialogue_start = "res://dialogue/Start.txt"
var curr_dialogue
var prev_command = []
var prev_text = {}
var dialogue_list = []
var processed_dialogue = []

# Called when the node enters the scene tree for the first time.

func compile_dialogues():
	var script_tree = ScriptTree.new()
	ResourceSaver.save(script_tree, save_path + scripts_file)
	# 先创建对应的保存文件
	dialogue_list = find_all_dialogue(res_dialogue)
	dialogue_proof_read(["Start.txt", dialogue_start])
	# compile 文案
	var scripts: ScriptTree = ResourceLoader.load(save_path + scripts_file)
	scripts.clear_save()
	ResourceSaver.save(scripts, save_path + scripts_file)

func find_all_dialogue(dir: String):
	# find all txt file and their respected link
	# under dialogue folder and return as a list
	var all_dialogue = []
	var files = DirAccess.open(dir)
	for file in files.get_files():
		var location = $"..".helper_search_file(dir, file)
		all_dialogue.append([file, location])
		print("find dialogue ", file, " at location ", location)
	for directories in files.get_directories():
		all_dialogue += find_all_dialogue(dir + "/" + directories)
	return all_dialogue
	
func helper_find_chapter_from_choice(which_chap: String):
	# a helper function that returns the respected txt path based on
	# chapter name
	for chapters in dialogue_list:
		if chapters[0] == which_chap:
			return chapters

func dialogue_proof_read(chapter: Array):
	# holy fuck this code is shit
	# this is one of the uglyest function I have ever written
	curr_dialogue = chapter
	var character
	var dialogue
	var command
	var temp_command
	var text
	var chap_name = chapter[0]
	var chap_dir = chapter[1]
	var file = FileAccess.open(chap_dir, FileAccess.READ)
	var script_tree: ScriptTree = ResourceLoader.load(save_path + scripts_file)
	script_tree.change_chapter(chap_name)
	while !file.eof_reached():
		text = file.get_line()
		while text == "":
		# incase a blank line is left, once a blank line is detected
		# skip until a none blank line is reached
			if file.eof_reached():
				script_tree.clear_save()
				ResourceSaver.save(script_tree, save_path + scripts_file)
				return
			text = file.get_line()
		#TODO join choice and game into sth else
		# so the code isn't this massive piece of shit
		# and can be easily extended
		if text == "choice":
			var choices = get_choice(file)
			script_tree.add_choice(choices)
			# the art and text at choice block MUST be from previous line
			file.close()
			processed_dialogue.append(chap_name)
			ResourceSaver.save(script_tree, save_path + scripts_file)
			temp_command = prev_command
			for choice in choices:
				prev_command = temp_command
				if choice[1] not in processed_dialogue:
					dialogue_proof_read(helper_find_chapter_from_choice(choice[1]))
			return
		if text == "game":
			var game = file.get_line()
			file.close()
			processed_dialogue.append(chap_name)
			if game != "":
				game = Array(game.rsplit(" "))
				script_tree.add_game(game[0])
				temp_command = prev_command
				for i in range(1, len(game)):
					prev_command = temp_command
					if game[i] not in processed_dialogue:
						dialogue_proof_read(helper_find_chapter_from_choice(game[i]))
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
		character = character.substr(0, len(character) - 1)
		# remove the ":"
		dialogue = dialogue.replace("\\command:", "command:")
		command = text.substr(text.find(" command:"))
		if $"..".auto_color and character != "":
			var header:Header = ResourceLoader.load(save_path + head_file)
			dialogue = header.process_color(character, "dialogue", dialogue)
			character = header.process_color(character, "character", character)
		elif $"..".auto_color and character == "":
			var header:Header = ResourceLoader.load(save_path + head_file)
			dialogue = header.process_color("nar", "dialogue", dialogue)
			# this colours the narrator which does not have a character name
		var command_list = process_commands(command)
		prev_text = {"character": character, "dialogue": dialogue}
		script_tree.add_line(character, dialogue, command_list)
		# make sure complete empty line are ignored
	ResourceSaver.save(script_tree, save_path + scripts_file)
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
	var fixed_commands = help_fix_commands(order_list)
	if fixed_commands == []:
		print("since current command is empty, commands have been extended!\n")
		fixed_commands = extend_commands()
		# if there is no command, it means the line follows the command 
		# from previous line, except voice and charatcer transition
		# this allows the art/music to always be displayed when loading
	extend_music(fixed_commands)
	print("after extend music ", fixed_commands, "\n")
	extend_background(fixed_commands)
	print("after extend background ", fixed_commands, "\n")
	prev_command = fixed_commands
	return fixed_commands

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
			_:
				fixed_commands.append(order)
	print("fixed commands are: ", fixed_commands, "\n")
	return fixed_commands

func extend_commands():
	# make current empty command prev command so 
	# when load it loads all the art and music resource
	var extended = []
	for command in prev_command:
		if extendable(command):
			extended.append(command)
	return extended

func extendable(command: Array):
	return command[0] != "voice" and command[0] != "update" \
	and command[1] != "clear"
	
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
			line = Array(line.rsplit(" "))
			if len(line) == 2:
				line.append("false")
			choice_list.append(line)
		# 将所有的选项都放进一个列表里
	return choice_list
		
