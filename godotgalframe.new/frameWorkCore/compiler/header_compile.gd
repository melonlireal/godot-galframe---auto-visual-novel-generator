extends Node
var save_path = "res://save/"
var head_file = "header.tres"
var var_file = "variables.tres"
var cg = "res://header/cg.txt"
var cg_file = FileAccess.open(cg, FileAccess.READ)
var colour = "res://header/color.txt"
var colour_all = FileAccess.open(colour, FileAccess.READ)
var variable = "res://header/variable.txt"
var var_all = FileAccess.open(variable, FileAccess.READ)
# Called when the node enters the scene tree for the first time.

func compile_headers():
	var header = Header.new()
	var vals = Variables.new()
	ResourceSaver.save(header, save_path + head_file)
	ResourceSaver.save(vals, save_path + var_file)
	find_cg(cg_file)
	find_colour(colour_all)
	find_variable(var_all)

func find_cg(cg_all: FileAccess):
	var header:Header = ResourceLoader.load(save_path + head_file)
	while not cg_all.eof_reached():
		var temp = cg_all.get_line()
		if temp != "":
			# 如果有可解锁CG再解锁CG
			var line = Array(temp.rsplit(" "))
			header.add_cg(line[0], line[1])
			print("Cg{0}, with cover {1} has been added"\
			.format({"0":line[0], "1":line[1]}))
	ResourceSaver.save(header, save_path + head_file)
	return
	
func find_colour(color: FileAccess):
	var header:Header = ResourceLoader.load(save_path + head_file)
	while  not color.eof_reached():
		var temp = color.get_line()
		if temp != "":
			var line = Array(temp.rsplit(" "))
			if len(line) == 2:
				header.add_colour(line[0], line[1])
			elif len(line) == 3:
				header.add_colour(line[0], line[1], line[2])
	header.add_colour("nar",$"..".narrator_color,$"..".narrator_color)
	ResourceSaver.save(header, save_path + head_file)
	return
	
func find_variable(val: FileAccess):
	var variables:Variables = ResourceLoader.load(save_path + var_file)
	while not val.eof_reached():
		var temp = val.get_line()
		if temp != "":
			var line = Array(temp.rsplit(" "))
			print(line)
			variables.new_var(line[0], line[1])
	ResourceSaver.save(variables,save_path + var_file)
