extends CanvasLayer
signal on_button
signal out_button

signal show_save
signal show_load
signal quick_save
signal quick_load
signal show_setting
signal show_story_tree
signal show_review_dialogue
signal start_auto_play
signal start_fast_forward
signal start_fast_forward_to_next_choice
signal hide_UI
signal leave_game
# Called when the node enters the scene tree for the first time.


func _ready():
	%function_name.text = ""
	for nodes in $Control/VBoxContainer.get_children():
		nodes.mouse_exited.connect(_mouse_leave_button)
		nodes.mouse_entered.connect(_mouse_reach_button)
	$Control/volumn_slider.visible = false
	$Control/volumn_slider.editable = false
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	$Control/volumn_slider.value = saved_data.total_volumn
		
		
func _mouse_leave_button():
	%function_name.text = ""
	out_button.emit()

func _mouse_reach_button():
	on_button.emit()

	
func _on_save_mouse_entered():
	%function_name.text = "Save"


func _on_save_pressed() -> void:
	show_save.emit()
	pass # Replace with function body.


func _on_load_mouse_entered():
	%function_name.text = "Load"
	
	
func _on_load_pressed() -> void:
	show_load.emit()
	pass # Replace with function body.


func _on_quicksave_mouse_entered():
	%function_name.text = "Qsave"
	
	
func _on_quicksave_pressed() -> void:
	quick_save.emit()
	pass # Replace with function body.
	
	
func _on_quickload_mouse_entered():
	%function_name.text = "Qload"
	
	
func _on_quickload_pressed() -> void:
	quick_load.emit()
	pass # Replace with function body.
	
	
func _on_setting_mouse_entered():
	%function_name.text = "Setting"
	
	
func _on_setting_pressed() -> void:
	show_setting.emit()
	pass # Replace with function body.
	
	
func _on_volumn_mouse_entered():
	%function_name.text = "Volumn"
	
	
func _on_volumn_pressed():
	if $Control/volumn_slider.visible:
		$Control/volumn_slider.visible = false
		$Control/volumn_slider.editable = false
		return
	$Control/volumn_slider.visible = true
	$Control/volumn_slider.editable = true
	
	
func _on_volumn_slider_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.voice_volumn = value
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	
	
func _on_story_tree_mouse_entered():
	%function_name.text = "Story Tree"
	
	
func _on_story_tree_pressed() -> void:
	show_story_tree.emit()
	pass # Replace with function body.


func _on_review_dialogue_mouse_entered():
	%function_name.text = "Review Dialogue"
	
	
func _on_review_dialogue_pressed() -> void:
	show_review_dialogue.emit()
	pass # Replace with function body.
	
	
func _on_auto_play_mouse_entered():
	%function_name.text = "Auto Play"
	
	
func _on_auto_play_pressed() -> void:
	start_auto_play.emit()
	pass # Replace with function body.


func _on_fast_forward_mouse_entered():
	%function_name.text = "Fast Forward"


func _on_fast_forward_pressed() -> void:
	start_fast_forward.emit()
	pass # Replace with function body.
	
	
func _on_fast_forward_to_next_choice_mouse_entered():
	%function_name.text = "Skip"

	
func _on_fast_forward_to_next_choice_pressed() -> void:
	start_fast_forward_to_next_choice.emit()
	pass # Replace with function body.
	
	
func _on_hide_ui_mouse_entered():
	%function_name.text = "Hide UI"

	
func _on_hide_ui_pressed() -> void:
	hide_UI.emit()
	pass # Replace with function body.


func _on_leave_game_mouse_entered():
	%function_name.text = "Exit"


func _on_leave_game_pressed() -> void:
	leave_game.emit()
	pass # Replace with function body.
