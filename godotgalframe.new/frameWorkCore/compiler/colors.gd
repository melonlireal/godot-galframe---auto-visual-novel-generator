extends Resource
class_name Colors
@export var colour_list = {}

func add_colour(name: String, character_col: String, dialogue_col = "None"):
	colour_list[name] = {}
	colour_list[name]["character"] = character_col
	if dialogue_col == "None":
		colour_list[name]["dialogue"] = character_col
	else: 
		colour_list[name]["dialogue"] = dialogue_col
		
func process_color(name: String, which: String, script: String):
	# name -> name of character
	# which -> the input string is name of character or dialogue of character
	# script -> the string to add color
	if script == " ":
		return ""
	print("input name is ", name, " \n")
	print("input script is ", script, " \n")
	if colour_list.has(name):
		return "[color={0}]{1}[/color]"\
		.format({"0": colour_list[name][which], "1": script})
	else:
		print("script not found\n")
		# if no header to be find, return initial script
		return script
		
