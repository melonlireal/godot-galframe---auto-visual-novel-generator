extends GridContainer

var setting_save = "user://save/save_total.tres"
var loading
# Called when the node enters the scene tree for the first time.

# WARNING SHIT CODE MUST FIX
func _ready():
	loading = true
	
func load_value():
	var saved_data = ResourceLoader.load(setting_save)
	var play_speed = saved_data.play_speed
	var auto_play_speed = saved_data.auto_play_speed
	%play_speed.value = play_speed
	$play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(play_speed)
	%auto_play_speed.value = auto_play_speed
	$auto_play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(auto_play_speed)
	%transparency.value = saved_data.dialogue_box_transparency
	$transparency/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.dialogue_box_transparency)
	loading = false
	
func _on_play_speed_value_changed(value):
	if loading:
		return
	var saved_data = ResourceLoader.load(setting_save)
	print("saving play speed", value)
	saved_data.save_play_speed(value)
	ResourceSaver.save(saved_data, setting_save)
	$play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value)


func _on_auto_play_speed_value_changed(value):
	if loading:
		return
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.save_auto_play_speed(value)
	ResourceSaver.save(saved_data, setting_save)
	$auto_play_speed/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value)


func _on_transparency_value_changed(value):
	if loading:
		return
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.dialogue_box_transparency = value
	ResourceSaver.save(saved_data, setting_save)
	$transparency/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value)
	$play_example/TextureRect.modulate.a = value/100
	$auto_play_example/TextureRect.modulate.a = value/100

func _on_windows_button_down():
	if loading:
		return
	%fullscreen.disabled = false
	%windows.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fullscreen_button_down():	
	if loading:
		return
	%windows.disabled = false
	%fullscreen.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
