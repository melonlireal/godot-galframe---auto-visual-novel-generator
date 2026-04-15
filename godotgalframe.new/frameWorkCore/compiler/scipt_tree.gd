extends Resource
class_name ScriptTree

@export var all_script = {}
@export var curr_chap = "Start.txt"
@export var curr_line = 1

func set_starting_point():
	curr_chap = "Start.txt"
	curr_line = 0

func clear_script():
	all_script = {}
	
	
func add_line(character: String, dialogue: String, command: Dictionary):
	curr_line += 1
	if !all_script.has(curr_chap):
		all_script[curr_chap] = {}
	all_script[curr_chap][curr_line] = {"character": character, 
	"dialogue": dialogue, "command":command}
	print("add line ", character," ",
	 dialogue," ", command, " in chapter ", curr_chap)
	
func add_choice(choices: Array):
	print("choice added ", choices)
	all_script[curr_chap]["lines"] = curr_line - 1
	all_script[curr_chap]["choice"] = choices
	
func add_game(game: String):
	all_script[curr_chap]["lines"] = curr_line - 1
	all_script[curr_chap]["game"] = game
	
	
func has_nextchap():
	if !all_script[curr_chap].has("choice") and !all_script[curr_chap].has("game"):
		return false
	return true
	
func get_choices():
	if !all_script[curr_chap].has("choice"):
		return []
	return all_script[curr_chap]["choice"]
	
func get_game():
	return all_script[curr_chap]["game"]
	
func change_chapter(chapter: String):
	curr_chap = chapter
	curr_line = 1

func get_line(box: Dictionary):
	print("get line ", curr_line, " from ", curr_chap, "\n")
	# if the line is not a standard line but a choice or the end of chapter
	# return
	if !all_script[curr_chap].has(curr_line):
		if all_script[curr_chap].has("choice"):
			return "choice reach"
		elif all_script[curr_chap].has("game"):
			return "game"
		else:
			return "exit"
		
	print("line content is ", all_script[curr_chap][curr_line], "\n")
	box["character"] = all_script[curr_chap][curr_line]["character"]
	box["dialogue"] = all_script[curr_chap][curr_line]["dialogue"]
	box["command"] = all_script[curr_chap][curr_line]["command"]
	curr_line += 1
	return "all good"
	
func get_chapter():
	return curr_chap

func get_line_num():
	if not all_script[curr_chap].has(curr_line):
		return all_script[curr_chap]["lines"] + 1
	return curr_line
	
func jump_choice():
	curr_line = all_script[curr_chap]["lines"]
	return
	
func load_progress(chapter: String, line: int):
	curr_chap = chapter
	curr_line = line
	
