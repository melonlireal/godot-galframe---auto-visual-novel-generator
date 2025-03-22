extends GridContainer

var setting_save = "user://save/save_total.tres"
# Called when the node enters the scene tree for the first time.


func load_value():
	var saved_data = ResourceLoader.load(setting_save)
	%play_speed.value = saved_data.play_speed * (50/20)
	$play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.play_speed * (50.0 / 20))
	%auto_play_speed.value = saved_data.play_speed * (50.0 / 20)
	$auto_play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.play_speed * (50.0 / 20))
	%transparency.value = saved_data.dialogue_box_transparency
	$transparency/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.dialogue_box_transparency)
	
func _on_play_speed_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.calc_play_speed(value)
	ResourceSaver.save(saved_data, setting_save)
	$play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value)


func _on_auto_play_speed_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.calc_auto_play_speed(value)
	ResourceSaver.save(saved_data, setting_save)
	$auto_play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value)


func _on_transparency_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.dialogue_box_transparency = value
	ResourceSaver.save(saved_data, setting_save)
	$transparency/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value)
	$play_example/TextureRect.modulate.a = value/100
	$auto_play_example/TextureRect.modulate.a = value/100


func _on_windows_button_down():
	%fullscreen.disabled = false
	%windows.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fullscreen_button_down():	
	%windows.disabled = false
	%fullscreen.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
