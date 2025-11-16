extends Resource
class_name Variables
@export var variables = {}

func load_var(vars: Dictionary):
	variables = vars

func new_var(name: String, variable: String):
	variables[name] = int(variable)
	
func var_op(variable: String, operation: String, value: String):
	var op = Callable(self, operation)
	op.call(variable, value)

func add(variable: String, value: String):
	if variables.has(value):
		variables[variable] += variables[value]
		print("add {0} to variable {1}\n".format({"0":variables[value], "1": variable}))
	else:
		variables[variable] += int(value)
	return

func sub(variable: String, value: String):
	if variables.has(value):
		variables[variable] -= variables[value]
		print("subtract {0} to variable {1}\n".format({"0":variables[value], "1": variable}))
	else:
		variables[variable] -= int(value)
	return
	
func rand(variable: String, value: String):
	var random = RandomNumberGenerator.new()
	random.randomize()
	variables[variable] = random.randi_range(0, int(value))
	print("randomize variable {0} to {1}\n".format({"0":variable, "1": variables[variable]}))
	
func assign(variable: String, value: String):
	if variables.has(value):
		variables[variable] = variables[value]
		print("assign value in {0} to variable {1}\n".format({"0":variables[value], "1": variable}))
	else:
		variables[variable] = int(value)
	return
	
func var_con(variable: String, operation: String, value: String):
	var op = Callable(self, operation)
	return op.call(variable, value)

func great(variable: String, value: String):
	if variables.has(value):
		return variables[variable] > variables[value]
	else:
		return variables[variable] > int(value)
	
func less(variable: String, value: String):
	if variables.has(value):
		return variables[variable] < variables[value]
	else:
		return variables[variable] < int(value)
	
func greate(variable: String, value: String):
	if variables.has(value):
		return variables[variable] >= variables[value]
	else:
		return variables[variable] >= int(value)
	
func lesse(variable: String, value: String):
	if variables.has(value):
		return variables[variable] <= variables[value]
	else:
		return variables[variable] <= int(value)

func equal(variable: String, value: String):
	if variables.has(value):
		return variables[variable] == variables[value]
	else:
		return variables[variable] == int(value)
