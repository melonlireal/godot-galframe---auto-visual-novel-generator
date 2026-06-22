extends Resource
class_name Variables
@export var variables = {}

func get_all_var():
	return variables
	
func get_var_val(name: String):
	return variables.get(name, 0)

func set_new_var(name: String, value: int):
	variables[name] = value
	
func update_var_val(name: String, value: int):
	if variables.has(name):
		variables[name] = value
	
func check_has_var(name:String):
	return variables.has(name)
	
func perform_var_ops(operations: Array):
	for operation in operations:
		var_op(operation[0], operation[1], operation[2])
		
func var_op(variable: String, operation: String, value: String = "0"):
	if self.has_method(operation):
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
	if self.has_method(operation):
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
