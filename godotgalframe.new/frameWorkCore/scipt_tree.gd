extends Resource
class_name ScriptTree

@export var all_script = {}
@export var curr_chap = "Start.txt"
@export var curr_line = 0

func clear_save():
	curr_chap = "Start.txt"
	curr_line = 0

func clear_script():
	all_script = {}
	
	
func add_line(character: String, dialogue: String, command: Array):
	curr_line += 1
	if !all_script.has(curr_chap):
		all_script[curr_chap] = {}
	all_script[curr_chap][curr_line] = {"character": character, 
	"dialogue": dialogue, "command":command}
	print("add line ", character," ",
	 dialogue," ", command, " in chapter ", curr_chap)
	
func add_choice(choices: Array):
	print("choice added ", choices)
	all_script[curr_chap]["choice"] = choices
	
func choice_reached():
	#choice is after all lines of a chapter is traveled
	#which means the line number is not in the chapter
	if !all_script[curr_chap].has(curr_line):
		return true
	return false
	
func get_choices():
	return all_script[curr_chap]["choice"]
	
func change_chapter(chapter: String):
	curr_chap = chapter
	curr_line = 0

func get_line(box: Dictionary):
	curr_line += 1
	print("get line ", curr_line, " from ", curr_chap, "\n")
	# if the line is not a standard line but a choice or the end of chapter
	# return
	if !all_script[curr_chap].has(curr_line):
		if !all_script[curr_chap].has("choice"):
			return "exit"
		return "choice reach"
	print("line content is ", all_script[curr_chap][curr_line], "\n")
	box["character"] = all_script[curr_chap][curr_line]["character"]
	box["dialogue"] = all_script[curr_chap][curr_line]["dialogue"]
	box["command"] = all_script[curr_chap][curr_line]["command"]
	return "all good"
	
func get_chapter():
	return curr_chap

func get_line_num():
	return curr_line
	
func load_progress(chapter: String, line: int):
	curr_chap = chapter
	curr_line = line
