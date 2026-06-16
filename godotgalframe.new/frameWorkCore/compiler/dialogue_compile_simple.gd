extends Node
#WARNING
# THIS CODE IS AI SLOP PRODUCED BY FEEDING MY 100% HUMAN SLOP AND ASK IT TO SIMPLIFY
# IT HAS NOT BEEN ATTACHED TO ANY NODE
# I WILL NOT USE IT UNTIL I UNDERSTAND WHAT IT DOES
# AND UNDERTSNAD MY PREVIOUS HUMAN SLOP
var save_path = "res://save/"
var scripts_file = "processed_script.tres"
var res_dialogue = "res://dialogue/"
var dialogue_start = "res://dialogue/Start.txt"
var prev_command = {}
# dialogue_list is a list instead of dictionary to prevent overide duplicate files.
var dialogue_list = []
var processed_dialogue = []


func compile_dialogues():
	var script_tree = ScriptTree.new()
	ResourceSaver.save(script_tree, save_path + scripts_file)
	dialogue_list = find_all_dialogue(res_dialogue)
	dialogue_proof_read(["Start.txt", dialogue_start])
	var scripts: ScriptTree = ResourceLoader.load(save_path + scripts_file)
	scripts.set_starting_point()
	ResourceSaver.save(scripts, save_path + scripts_file)


func find_all_dialogue(dir: String):
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
	for chapters in dialogue_list:
		if chapters[0] == which_chap:
			return chapters


func dialogue_proof_read(chapter: Array):
	var chap_name = chapter[0]
	var chap_dir = chapter[1]
	var file = FileAccess.open(chap_dir, FileAccess.READ)
	var script_tree: ScriptTree = ResourceLoader.load(save_path + scripts_file)
	script_tree.change_chapter(chap_name)

	while !file.eof_reached():
		var text = _read_next_non_empty_line(file, script_tree)
		if text == null:
			return

		if text == "choice":
			_handle_choice_block(file, script_tree, chap_name)
			return

		if text == "game":
			_handle_game_block(file, chap_name)
			return

		var parsed = _parse_dialogue_line(text)
		var command_list = process_commands(parsed["command"])
		script_tree.add_line(parsed["character"], parsed["dialogue"], command_list)

	ResourceSaver.save(script_tree, save_path + scripts_file)


func _read_next_non_empty_line(file: FileAccess, script_tree: ScriptTree):
	var text = file.get_line()
	while text == "":
		if file.eof_reached():
			script_tree.set_starting_point()
			ResourceSaver.save(script_tree, save_path + scripts_file)
			return null
		text = file.get_line()
	return text


func _handle_choice_block(file: FileAccess, script_tree: ScriptTree, chap_name: String):
	var choices = get_choice(file)
	script_tree.add_choice(choices)
	file.close()
	processed_dialogue.append(chap_name)
	ResourceSaver.save(script_tree, save_path + scripts_file)
	var temp_command = prev_command
	for choice in choices:
		prev_command = temp_command
		if choice[1] not in processed_dialogue:
			dialogue_proof_read(helper_find_chapter_from_choice(choice[1]))


func _handle_game_block(file: FileAccess, chap_name: String):
	var game = file.get_line()
	file.close()
	processed_dialogue.append(chap_name)
	if game != "":
		game = Array(game.rsplit(" "))
		var script_tree: ScriptTree = ResourceLoader.load(save_path + scripts_file)
		script_tree.add_game(game[0])
		var temp_command = prev_command
		for i in range(1, len(game)):
			prev_command = temp_command
			if game[i] not in processed_dialogue:
				dialogue_proof_read(helper_find_chapter_from_choice(game[i]))


func _parse_dialogue_line(text: String):
	text = text.replace("：", ":")
	var command = ""
	var command_start = text.find(" command:")
	var main_text = text
	if command_start != -1:
		command = text.substr(command_start + len(" command:"))
		main_text = text.substr(0, command_start)

	var character = ""
	var dialogue = main_text
	var speaker_split = main_text.find(":")
	if speaker_split != -1:
		character = main_text.substr(0, speaker_split)
		dialogue = main_text.substr(speaker_split + 1)

	dialogue = dialogue.replace("\\command:", "command:")
	if $"..".auto_color_text:
		var text_colors: Colors = ResourceLoader.load(GlobalResources.color_all_path)
		dialogue = text_colors.process_color(character, "dialogue", dialogue)
		if character != "":
			character = text_colors.process_color(character, "character", character)

	return {
		"character": character,
		"dialogue": dialogue,
		"command": command
	}


func process_commands(commands: String):
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
	var fixed_commands = {}
	var defaults = {
		"character": "mid",
		"background": "true"
	}
	for order in order_list:
		var order_type = order[0]
		if not fixed_commands.has(order_type):
			fixed_commands[order_type] = []
		if order_type == "effect":
			var effect_order = [order[1]]
			for step in order.slice(2):
				if step[0] == "effect" and step.size() >= 3:
					effect_order.append(step[2])
				else:
					effect_order.append(step)
			fixed_commands[order_type].append(effect_order)
			print("current order is ", order, "\n")
			continue
		if defaults.has(order_type) and order.size() < 3:
			order.append(defaults[order_type])
		fixed_commands[order_type].append(order.slice(1))
		print("current order is ", order, "\n")
	return fixed_commands


func extend_from_prev_command(order_list: Dictionary):
	for command_type in ["background", "bgm", "character"]:
		if not order_list.has(command_type) and prev_command.has(command_type):
			order_list[command_type] = prev_command[command_type]

	if order_list.has("effect"):
		order_list["effect"] = _group_effects_by_pos(order_list["effect"])
	return


func _group_effects_by_pos(effects: Array):
	var grouped = {}
	for effect in effects:
		var pos = effect[0]
		if not grouped.has(pos):
			grouped[pos] = [pos]
		grouped[pos].append(effect.slice(1))
	var final_effects = []
	for pos in grouped:
		final_effects.append(grouped[pos])
	return final_effects


func set_prev_command(command: Dictionary):
	var new_prev = command.duplicate(true)
	if new_prev.has("effect"):
		for effect_group in new_prev["effect"]:
			var pos = effect_group[0]
			for step_group in effect_group.slice(1):
				for step in step_group:
					if step[0] == "transit":
						_apply_transit_to_prev(new_prev, pos, step[1])
	return new_prev


func _apply_transit_to_prev(new_prev: Dictionary, pos, sprite):
	if not new_prev.has("character"):
		new_prev["character"] = []
	var updated = false
	for character in new_prev["character"]:
		if character[1] == pos:
			character[0] = sprite
			updated = true
	if not updated:
		new_prev["character"].append([sprite, pos])


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
	return choice_list
