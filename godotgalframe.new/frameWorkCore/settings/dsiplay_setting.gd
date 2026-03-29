extends GridContainer

var loading
@onready var play_speed_slider: HSlider = $play_speed/HBoxContainer/MarginContainer/play_speed
@onready var play_speed_label: Label = $play_speed/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var auto_play_speed_slider: HSlider = $auto_play_speed/HBoxContainer/MarginContainer/auto_play_speed
@onready var auto_play_speed_label: Label = $auto_play_speed/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var transparency_slider: HSlider = $transparency/HBoxContainer/MarginContainer/transparency
@onready var transparency_label: Label = $transparency/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var play_example: TextureRect = $play_example/TextureRect
@onready var auto_play_example: TextureRect = $auto_play_example/TextureRect

# Called when the node enters the scene tree for the first time.

# WARNING SHIT CODE MUST FIX
	
func load_value():
	var saved_data:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	
	var play_speed = saved_data.play_speed
	play_speed_slider.value = play_speed
	play_speed_label.text = str(play_speed)
	
	var auto_play_speed = saved_data.auto_play_speed
	auto_play_speed_slider.value = auto_play_speed 
	auto_play_speed_label.text = str(auto_play_speed )
	
	var transparency = saved_data.dialogue_box_transparency
	transparency_slider.value = transparency
	transparency_label.text = str(transparency)
	play_example.modulate.a = transparency/100
	auto_play_example.modulate.a = transparency/100
	
func _on_play_speed_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.save_play_speed(value)
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	play_speed_label.text = str(value)
	

func _on_auto_play_speed_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.save_auto_play_speed(value)
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	auto_play_speed_label.text = str(value)


func _on_transparency_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.dialogue_box_transparency = value
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	transparency_label.text = str(value)
	play_example.modulate.a = value/100
	auto_play_example.modulate.a = value/100

func _on_windows_button_down():
	%fullscreen.disabled = false
	%windows.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fullscreen_button_down():	
	%windows.disabled = false
	%fullscreen.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
