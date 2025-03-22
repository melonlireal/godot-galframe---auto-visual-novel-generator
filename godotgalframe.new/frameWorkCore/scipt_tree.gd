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
	if !all_script.has(curr_chap):
		all_script[curr_chap] = {}
	all_script[curr_chap][curr_line] = {"character": character, 
	"dialogue": dialogue, "command":command}
	print("add line ", character," ",
	 dialogue," ", command, " in chapter ", curr_chap)
	curr_line += 1
	
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

func get_line():
	if !all_script[curr_chap].has(curr_line):
		if !all_script[curr_chap].has("choice"):
			return {"exit": 1}
		return {"choice_reach": 0}
		#又是一个傻逼设计，但后面再说吧，这个改起来不难
	var line_content = all_script[curr_chap][curr_line]
	curr_line += 1
	return line_content
	
func get_chapter():
	return curr_chap

func get_line_num():
	return curr_line
	
func load_progress(chapter: String, line: int):
	curr_chap = chapter
	curr_line = line
