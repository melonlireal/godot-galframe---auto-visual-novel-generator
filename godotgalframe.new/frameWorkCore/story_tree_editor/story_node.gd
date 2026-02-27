extends PanelContainer
class_name  StoryNode
var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
@export var node_name: String = ""
@export var txt_included: Array[String] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	



func _on_button_pressed() -> void:
	pass # Replace with function body.
