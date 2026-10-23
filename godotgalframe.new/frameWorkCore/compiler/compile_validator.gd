extends Node

var save_path = "res://save/"
var header_cg_doc = "res://header/cg.txt"
var header_color_doc = "res://header/color.txt"
var header_variable_doc = "res://header/variable.txt"

var error_entry_scene = preload("res://frameWorkCore/compiler/compile_error_entry.tscn")

@onready var error_container: VBoxContainer = $"../error_list/ScrollContainer/VBoxContainer"
@onready var summary_label: Label = $"../summary_label"

const KNOWN_EFFECTS = [
	GlobalType.EFFECT_TRANSIT,
	GlobalType.EFFECT_APPEAR,
	GlobalType.EFFECT_DISAPPEAR,
	GlobalType.EFFECT_SHAKE,
	GlobalType.EFFECT_JUMP,
	GlobalType.EFFECT_NOD,
	GlobalType.EFFECT_TILTLEFT,
	GlobalType.EFFECT_TILTRIGHT,
	GlobalType.EFFECT_WAIT,
]

const KNOWN_BACKGROUND_EFFECTS = ["fadeout", "flash"]

func validate() -> void:
	var script_tree: ScriptTree = ResourceLoader.load(save_path + "processed_script.tres")
	var asset_map: AssetPath = ResourceLoader.load(save_path + "mapper_total.tres")
	var variables: Variables = ResourceLoader.load(save_path + "variables.tres")
	var cgs: CGS = ResourceLoader.load(save_path + "cg.tres")

	var raw_errors: Array = []
	raw_errors += _validate_headers()
	raw_errors += _validate_script(script_tree, asset_map, variables, cgs)

	for error in raw_errors:
		var entry = error_entry_scene.instantiate()
		entry.message = error
		error_container.add_child(entry)

	if raw_errors.is_empty():
		summary_label.text = "finished processing scripts"
	else:
		summary_label.text = "finished processing scripts - %d error found" % raw_errors.size()


func _validate_headers() -> Array:
	var errors = []
	errors += _check_header_cg_file()
	errors += _check_header_color_file()
	errors += _check_header_variable_file()
	return errors


func _check_header_cg_file() -> Array:
	var errors = []
	var file = FileAccess.open(header_cg_doc, FileAccess.READ)
	if file == null:
		return errors
	var line_num = 0
	while not file.eof_reached():
		var text = file.get_line()
		line_num += 1
		if text.strip_edges() == "":
			continue
		var tokens = text.split(" ", false)
		if tokens.size() != 2:
			errors.append("ERROR [cg.txt line %d]: incorrect format, expected \"CG_name cover_filename\"" % line_num)
	file.close()
	return errors


func _check_header_color_file() -> Array:
	var errors = []
	var file = FileAccess.open(header_color_doc, FileAccess.READ)
	if file == null:
		return errors
	var line_num = 0
	while not file.eof_reached():
		var text = file.get_line()
		line_num += 1
		if text.strip_edges() == "":
			continue
		var tokens = text.split(" ", false)
		if tokens.size() < 2 or tokens.size() > 3:
			errors.append("ERROR [color.txt line %d]: incorrect format, expected \"character_name hex_color [dialogue_hex_color]\"" % line_num)
	file.close()
	return errors


func _check_header_variable_file() -> Array:
	var errors = []
	var file = FileAccess.open(header_variable_doc, FileAccess.READ)
	if file == null:
		return errors
	var line_num = 0
	while not file.eof_reached():
		var text = file.get_line()
		line_num += 1
		if text.strip_edges() == "":
			continue
		var tokens = text.split(" ", false)
		if tokens.size() != 2:
			errors.append("ERROR [variable.txt line %d]: incorrect format, expected \"variable_name initial_integer\"" % line_num)
		elif not tokens[1].is_valid_int():
			errors.append("ERROR [variable.txt line %d]: variable initial value must be an integer" % line_num)
	file.close()
	return errors


func _validate_script(script_tree: ScriptTree, asset_map: AssetPath, variables: Variables, cgs: CGS) -> Array:
	var errors = []
	# tracks (chap, command_type, value) for inheritable commands to avoid duplicate reports
	var inherited_seen: Dictionary = {}
	var all_script = script_tree.all_script

	for chap in all_script:
		var chap_data = all_script[chap]

		# check choice/game jump targets exist
		if chap_data.has("choice"):
			for choice in chap_data["choice"]:
				var target = choice[1]
				if not all_script.has(target):
					errors.append("ERROR [%s]: unable to proceed to chapter file %s check your spelling" % [chap, target])

		if chap_data.has("game"):
			var target = chap_data["game"]
			if target != "" and not all_script.has(target):
				errors.append("ERROR [%s]: unknown game scene %s check your spelling" % [chap, target])

		# check every dialogue line's commands
		for key in chap_data:
			if typeof(key) != TYPE_INT:
				continue
			var line_num = key
			var command: Dictionary = chap_data[line_num]["command"]
			errors += _validate_command(command, chap, line_num, asset_map, variables, cgs, inherited_seen)

	return errors


func _validate_command(command: Dictionary, chap: String, line_num: int, asset_map: AssetPath, variables: Variables, cgs: CGS, inherited_seen: Dictionary) -> Array:
	var errors = []
	var loc = "[%s line %d]" % [chap, line_num]

	# character
	if command.has(GlobalType.COMMAND_CHARACTER):
		for entry in command[GlobalType.COMMAND_CHARACTER]:
			var avatar_name = entry[0]
			if avatar_name != GlobalType.COMMAND_CLEAR and asset_map.search_path(avatar_name) == null:
				var dedup_key = "%s|character|%s" % [chap, avatar_name]
				if not inherited_seen.has(dedup_key):
					inherited_seen[dedup_key] = true
					errors.append("ERROR %s: unknown character avatar %s check your spelling and file type (.jpg, .png)" % [loc, avatar_name])

	# background
	if command.has(GlobalType.COMMAND_BACKGROUND):
		for entry in command[GlobalType.COMMAND_BACKGROUND]:
			var bg_name = entry[0]
			if bg_name in KNOWN_BACKGROUND_EFFECTS:
				continue
			if bg_name != GlobalType.COMMAND_CLEAR and asset_map.search_path(bg_name) == null:
				var dedup_key = "%s|background|%s" % [chap, bg_name]
				if not inherited_seen.has(dedup_key):
					inherited_seen[dedup_key] = true
					errors.append("ERROR %s: unknown background %s check your spelling and file type (.jpg, .png)" % [loc, bg_name])

	# bgm
	if command.has(GlobalType.COMMAND_BGM):
		for entry in command[GlobalType.COMMAND_BGM]:
			var music_name = entry[0]
			if music_name != GlobalType.COMMAND_CLEAR and asset_map.search_path(music_name) == null:
				var dedup_key = "%s|bgm|%s" % [chap, music_name]
				if not inherited_seen.has(dedup_key):
					inherited_seen[dedup_key] = true
					errors.append("ERROR %s: unknown music %s check your spelling" % [loc, music_name])

	# sound_effect
	if command.has(GlobalType.COMMAND_SOUND_EFFECT):
		for entry in command[GlobalType.COMMAND_SOUND_EFFECT]:
			var sfx_name = entry[0]
			if sfx_name != GlobalType.COMMAND_CLEAR and asset_map.search_path(sfx_name) == null:
				errors.append("ERROR %s: unknown music %s check your spelling" % [loc, sfx_name])

	# voice
	if command.has(GlobalType.COMMAND_VOICE):
		for entry in command[GlobalType.COMMAND_VOICE]:
			var voice_name = entry[0]
			if voice_name != GlobalType.COMMAND_CLEAR and asset_map.search_path(voice_name) == null:
				errors.append("ERROR %s: unknown music %s check your spelling" % [loc, voice_name])

	# chubby
	if command.has(GlobalType.COMMAND_CHUBBY):
		for entry in command[GlobalType.COMMAND_CHUBBY]:
			var chubby_name = entry[0]
			if chubby_name != GlobalType.COMMAND_CLEAR and asset_map.search_path(chubby_name) == null:
				errors.append("ERROR %s: unknown character avatar %s check your spelling and file type (.jpg, .png)" % [loc, chubby_name])

	# CG
	if command.has(GlobalType.COMMAND_CG):
		for entry in command[GlobalType.COMMAND_CG]:
			var cg_name = entry[0]
			if not cgs.has_cg(cg_name):
				errors.append("ERROR %s: unknown CG %s check your spelling" % [loc, cg_name])

	# effect
	if command.has(GlobalType.COMMAND_EFFECT):
		for effect_group in command[GlobalType.COMMAND_EFFECT]:
			# effect_group format: [position, [step], [step], ...]
			for step_group in effect_group.slice(1):
				for step in step_group:
					var effect_name = step[0] if typeof(step) == TYPE_ARRAY else step
					if effect_name not in KNOWN_EFFECTS:
						errors.append("ERROR %s: unknown character effect %s check your spelling" % [loc, effect_name])

	# update (variable operations)
	if command.has(GlobalType.COMMAND_UPDATE):
		for entry in command[GlobalType.COMMAND_UPDATE]:
			var var_name = entry[0]
			if not variables.check_has_var(var_name):
				errors.append("ERROR %s: unknown variable %s check your spelling" % [loc, var_name])

	return errors
