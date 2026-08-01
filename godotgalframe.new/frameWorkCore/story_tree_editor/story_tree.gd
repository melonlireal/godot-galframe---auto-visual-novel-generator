extends CanvasLayer
class_name StoryTree
signal load_chap
signal close
@onready var scroll_container: ScrollContainer = $scroll_container
@onready var place_nodes_under_here: Control = $scroll_container/place_nodes_under_here



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in place_nodes_under_here.get_children():
		if child.has_signal("load_chapter"):
			child.load_chapter.connect(_on_load_chapter_received)
	update_canvas_size()
	scroll_container.gui_input.connect(_on_scroll_input)

func update_chapter(chapter_name: String):
	for child in place_nodes_under_here.get_children():
		if child.has_method("story_node_unlock"):
			child.story_node_unlock(chapter_name)
		elif child.has_method("choice_pointer_unlock"):
			child.choice_pointer_unlock()
	update_canvas_size()
	
func update_canvas_size():
	var max_bound = Vector2(get_viewport().size)
	for child in place_nodes_under_here.get_children():
		if child is Control and child.visible:
			var end_pos = child.position + child.size
			max_bound.x = max(max_bound.x, end_pos.x)
			max_bound.y = max(max_bound.y, end_pos.y)
	place_nodes_under_here.custom_minimum_size = max_bound + Vector2(300, 300) # 预留边距

func _on_load_chapter_received(chapter_name: String, variable_of_chapter):
	load_chap.emit(chapter_name, variable_of_chapter)

func _on_close_pressed() -> void:
	close.emit()
	
func _on_scroll_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			scroll_container.scroll_horizontal -= event.relative.x
			scroll_container.scroll_vertical -= event.relative.y
