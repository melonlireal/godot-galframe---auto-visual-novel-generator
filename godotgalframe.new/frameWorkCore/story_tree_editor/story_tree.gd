extends CanvasLayer

signal load_chap
signal close
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in self.get_children():
		if child.has_method("story_node_unlock"):
			child.connect("load_chapter", load_chapter)
	pass # Replace with function body.

func update_chapter(chapter_name):
	for child in self.get_children():
		if child.has_method("story_node_unlock"):
			child.story_node_unlock(chapter_name)
		elif child.has_method("choice_pointer_unlock"):
			child.choice_pointer_unlock()

func load_chapter(chapter_name: String, variable_of_chapter):
	load_chap.emit(chapter_name, variable_of_chapter)
	pass


func _on_close_pressed() -> void:
	close.emit()
