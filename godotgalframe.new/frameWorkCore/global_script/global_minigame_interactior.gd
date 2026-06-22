extends Node


var curr_variable:Variables =  null

func set_variable(variable: Variables):
	curr_variable = variable
# read method
func get_game_var(varname: String): # get one game variable 
	return curr_variable.get_var_val(varname)

func get_all_var(): # get all variable and return as dictionary
	return curr_variable.get_all_var()

# write method
func update_game_var(varname: String, value:int):
	curr_variable.update_var_val(varname, value)
	GlobalSignals.minigame_edit_var.emit(curr_variable)
	

func create_game_var(varname: String, value: int):
	curr_variable.set_new_var(varname, value)
	GlobalSignals.minigame_edit_var.emit(curr_variable)
