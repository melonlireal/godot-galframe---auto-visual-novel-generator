extends GridContainer
@onready var red_slider: HSlider = $red/HBoxContainer/MarginContainer/red
@onready var red_label: Label = $red/HBoxContainer/data_display_box/CenterContainer/data_display
@onready var green_slider: HSlider = $green/HBoxContainer/MarginContainer/green
@onready var green_label: Label = $green/HBoxContainer/data_display_box/CenterContainer/data_display
@onready var blue_slider: HSlider = $blue/HBoxContainer/MarginContainer/blue
@onready var blue_label: Label = $blue/HBoxContainer/data_display_box/CenterContainer/data_display
@onready var alpha_slider: HSlider = $alpha/HBoxContainer/MarginContainer/alpha
@onready var alpha_label: Label = $alpha/HBoxContainer/data_display_box/CenterContainer/data_display
@onready var play_example: ColorRect = $play_example/example


func load_value():
	var saved_data:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	play_example.color = saved_data.windows_color
	
	var red = saved_data.red
	red_slider.value = red
	red_label.text = str(red)
	
	var green = saved_data.green
	green_slider.value = green
	green_label.text = str(green)
	
	var blue = saved_data.blue
	blue_slider.value = blue
	blue_label.text = str(blue)
	
	var alpha = saved_data.alpha
	alpha_slider.value = alpha
	alpha_label.text = str(alpha)
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_red_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.change_red(value)
	play_example.color.r = value/255
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	red_label.text = str(saved_data.red)


func _on_green_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.change_green(value)
	play_example.color.g = value/255
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	green_label.text = str(saved_data.green)
	
	
func _on_blue_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.change_blue(value)
	play_example.color.b = value/255
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	green_label.text = str(saved_data.blue)
	
	
func _on_alpha_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.change_alpha(value)
	play_example.color.a = value/100
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	green_label.text = str(saved_data.alpha)
