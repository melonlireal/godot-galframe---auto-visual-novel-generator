extends Resource
class_name CurrGameProgress
# progress data tracks the progress of current game, 
# it is used for game saving and loading
@export var which_file: String = "Start.txt"
@export var which_line: int = 1
@export var variables: Variables = null
