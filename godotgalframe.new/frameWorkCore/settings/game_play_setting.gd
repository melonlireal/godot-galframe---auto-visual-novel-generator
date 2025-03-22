extends GridContainer
var setting_save = "user://save/save_total.tres"
# Called when the node enters the scene tree for the first time.


func load_value():
	var saved_data = ResourceLoader.load(setting_save)
	$play_example/example.color = saved_data.windows_color
	%red.value = saved_data.red
	$red/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.red)
	%green.value = saved_data.green
	$green/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.green)
	%blue.value = saved_data.blue
	$blue/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.blue)
	%alpha.value = saved_data.alpha
	$alpha/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.alpha)
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_red_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.change_red(value)
	$play_example/example.color.r = value/255
	ResourceSaver.save(saved_data, setting_save)
	$red/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.red)


func _on_green_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.change_green(value)
	$play_example/example.color.g = value/255
	ResourceSaver.save(saved_data, setting_save)
	$green/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.green)
	
	
func _on_blue_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.change_blue(value)
	$play_example/example.color.b = value/255
	ResourceSaver.save(saved_data, setting_save)
	$blue/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.blue)
	
	
func _on_alpha_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.change_alpha(value)
	$play_example/example.color.a = value/100
	ResourceSaver.save(saved_data, setting_save)
	$alpha/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.alpha)
