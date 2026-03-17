extends Node
var save_path = "res://save/"
var scripts_file = "processed_script.tres"
var res_dialogue = "res://dialogue/"
var dialogue_start = "res://dialogue/Start.txt"
var prev_command = {}
# dialogue_list is a list instead of dictionary to prevent overide duplicate files.
var dialogue_list = []
var processed_dialogue = []

# Called when the node enters the scene tree for the first time.

func compile_dialogues():
	var script_tree = ScriptTree.new()
	ResourceSaver.save(script_tree, save_path + scripts_file)
	# 先创建对应的保存文件
	dialogue_list = find_all_dialogue(res_dialogue)
	# compile dialogues
	dialogue_proof_read(["Start.txt", dialogue_start])
	var scripts: ScriptTree = ResourceLoader.load(save_path + scripts_file)
	scripts.set_starting_point() # reset the starting point 
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
	var temp_command
	var chap_name = chapter[0]
	var chap_dir = chapter[1]
	var file = FileAccess.open(chap_dir, FileAccess.READ)
	var script_tree: ScriptTree = ResourceLoader.load(save_path + scripts_file)
	script_tree.change_chapter(chap_name)
	while !file.eof_reached():
		var text = file.get_line()
		while text == "":
		# incase a blank line is left, once a blank line is detected
		# skip until a none blank line is reached
			if file.eof_reached():
				script_tree.set_starting_point()
				ResourceSaver.save(script_tree, save_path + scripts_file)
				return
			text = file.get_line()
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
		elif text == "game":
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
		var character = text.substr(0, text.find(":") + 1)
		# this includes the ":"
		if character == " command:" or character == ":":
			character = ""
			#清理特殊字符command和隔开角色和台词的：
			#同时考虑到该行没有人物或对话的情况
		var dialogue
		if text.find(" command:") != -1:
			dialogue = text.substr(text.find(":") + 1, text.find(" command:") - text.find(":"))
		else:
			dialogue = text.substr(text.find(":") + 1, text.find(" command:"))
			#根据是否有command隔离开dialogue和角色
		character = character.substr(0, len(character) - 1)
		# remove the ":"
		dialogue = dialogue.replace("\\command:", "command:")
		if $"..".auto_color_text:
			var text_colors:Colors = ResourceLoader.load(GlobalResources.color_all_path)
			dialogue = text_colors.process_color(character, "dialogue", dialogue)
			if character != "":
				character =  text_colors.process_color(character, "character", character)
			# colours dialogue and character (including narrator)
		var command = text.substr(text.find(" command:"))
		if command.begins_with(" command:"):
			command = command.substr(len(" command:"))
		var command_list = process_commands(command)
		script_tree.add_line(character, dialogue, command_list)
		# make sure complete empty line are ignored
	ResourceSaver.save(script_tree, save_path + scripts_file)
	return
	
func process_commands(commands: String):
	#return the list of commands
	print(commands)
	var order_list = help_parse_nested_commands(commands)
	print("processed commands are", order_list, "\n")
	var fixed_commands = help_fix_commands(order_list)
	extend_from_prev_command(fixed_commands)
	prev_command = set_prev_command(fixed_commands)
	return fixed_commands

func help_parse_nested_commands(text: String):
	var result = []
	var token = ""
	var stack = [result]
	for c in text:
		match c:
			"(":
				var new_list = []
				stack[-1].append(new_list)
				stack.append(new_list)
				token = ""
			")":
				if token.strip_edges() != "":
					stack[-1].append(token.strip_edges())
				token = ""
				stack.pop_back()
			",":
				if token.strip_edges() != "":
					stack[-1].append(token.strip_edges())
				token = ""
			_:
				token += c
	if token.strip_edges() != "":
		stack[0].append(token.strip_edges())

	return result

func help_fix_commands(order_list: Array):
	#pre process the commands into the format that can be used by 
	#internal code. Allows user to type less complex command and
	#get the same effect
	var fixed_commands = {}
	for order in order_list:
		var order_type = order[0]
		if not fixed_commands.has(order_type):
			fixed_commands[order_type] = []
		match order_type:				
			"character":
				if order.size() < 3:
					order.append("mid")
			"background":
				if order.size() < 3:
					order.append("true")
		fixed_commands[order_type].append(order.slice(1))
		print("current order is ", order, "\n")
	return fixed_commands
	
func extend_from_prev_command(order_list: Dictionary):
	if not order_list.has("background") and prev_command.has("background"):
		order_list["background"] = prev_command["background"]
		
	if not order_list.has("bgm") and prev_command.has("bgm"):
		order_list["bgm"] = prev_command["bgm"]
		
	if not order_list.has("character") and prev_command.has("character"):
		order_list["character"] = prev_command["character"]
		
	if order_list.has("effect"):
		var effects = order_list["effect"]
		var grouped = {}
		for effect in effects:
			var pos = effect[0]
			if not grouped.has(pos):
				grouped[pos] = [pos]
			grouped[pos].append(effect.slice(1))
		var final_effects = []
		for pos in grouped:
			final_effects.append(grouped[pos])
		order_list["effect"] = final_effects
	return
		
func set_prev_command(command: Dictionary):
	var new_prev = command.duplicate(true)
	if new_prev.has("effect"):
		for effect_group in new_prev["effect"]:
			var pos = effect_group[0]
			for step_group in effect_group.slice(1):
				for step in step_group:
					if step[0] == "transit":
						var sprite = step[1]
						if not new_prev.has("character"):
							new_prev["character"] = []
						var updated = false
						for character in new_prev["character"]:
							if character[1] == pos:
								character[0] = sprite
								updated = true
						if not updated:
							new_prev["character"].append([sprite, pos])
	return new_prev
	
#return the list of choices and respected new chapter	
func get_choice(file: FileAccess):
	var choice_list = []
	var regex = RegEx.new()
	regex.compile("^\\((.*?)\\)\\s*(.*)$")
	while not file.eof_reached():
		var line = file.get_line()
		if line == "":
			continue
		var match = regex.search(line)
		if match:
			var description = match.get_string(1)
			var rest = match.get_string(2)
			var tokens = [description]
			if rest != "":
				tokens += Array(rest.split(" ", false))
			if tokens.size() == 2:
				tokens.append("false")
			choice_list.append(tokens)
	# 将所有的选项都放进一个列表里
	return choice_list
		
