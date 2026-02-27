extends Node
var save_path = "res://save/"
var color_save = "color.tres"
var cg_save = "cg.tres"
var var_save = "variables.tres"
var cg_doc = "res://header/cg.txt"
var cg_all = FileAccess.open(cg_doc, FileAccess.READ)
var color_doc = "res://header/color.txt"
var color_all = FileAccess.open(color_doc, FileAccess.READ)
var variable_doc = "res://header/variable.txt"
var var_all = FileAccess.open(variable_doc, FileAccess.READ)
# Called when the node enters the scene tree for the first time.

func compile_headers():
	var vals = Variables.new()
	var cgs = CGS.new()
	var colors = Colors.new()
	ResourceSaver.save(cgs, save_path + cg_save)
	ResourceSaver.save(vals, save_path + var_save)
	ResourceSaver.save(colors, save_path + color_save)
	find_cg(cg_all)
	find_colour(color_all)
	find_variable(var_all)

func find_cg(cg: FileAccess):
	var cgs:CGS = ResourceLoader.load(save_path + cg_save)
	while not cg.eof_reached():
		var temp = cg.get_line()
		if temp != "":
			# 如果有可解锁CG再解锁CG
			var line = Array(temp.rsplit(" "))
			cgs.add_cg(line[0], line[1])
			print("Cg{0}, with cover {1} has been added"\
			.format({"0":line[0], "1":line[1]}))
	ResourceSaver.save(cgs, save_path + cg_save)
	return
	
func find_colour(color: FileAccess):
	var colors:Colors = ResourceLoader.load(save_path + color_save)
	while  not color.eof_reached():
		var temp = color.get_line()
		if temp != "":
			var line = Array(temp.rsplit(" "))
			if len(line) == 2:
				colors.add_colour(line[0], line[1])
			elif len(line) == 3:
				colors.add_colour(line[0], line[1], line[2])
	colors.add_colour("nar",$"..".narrator_color,$"..".narrator_color)
	ResourceSaver.save(colors, save_path + color_save)
	return
	
func find_variable(val: FileAccess):
	var variables:Variables = ResourceLoader.load(save_path + var_save)
	while not val.eof_reached():
		var temp = val.get_line()
		if temp != "":
			var line = Array(temp.rsplit(" "))
			print(line)
			variables.new_var(line[0], line[1])
	ResourceSaver.save(variables,save_path + var_save)
