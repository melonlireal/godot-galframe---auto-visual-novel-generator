extends GridContainer
@onready var total_volumn_slider: HSlider = $total_volumn/HBoxContainer/MarginContainer/total_volumn
@onready var total_volumn_label: Label = $total_volumn/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var bgm_volumn_slider: HSlider = $bgm_volumn/HBoxContainer/MarginContainer/bgm_volumn
@onready var bgm_volumn_label: Label = $bgm_volumn/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var voice_volumn_slider: HSlider = $voice_volumn/HBoxContainer/MarginContainer/voice_volumn
@onready var voice_volumn_label: Label = $voice_volumn/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var sfx_volumn_slider: HSlider = $sfx_volumn/HBoxContainer/MarginContainer/sfx_volumn
@onready var sfx_volumn_label: Label = $sfx_volumn/HBoxContainer/data_display_box/CenterContainer/data_display




func load_value():
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	
	var total_volumn = saved_data.total_volumn
	total_volumn_slider.value = total_volumn
	total_volumn_label.text = str(total_volumn * 100)
	
	var bgm_volumn = saved_data.bgm_volumn
	bgm_volumn_slider.value = bgm_volumn
	bgm_volumn_label.text = str(bgm_volumn * 100)
	
	var voice_volumn = saved_data.voice_volumn
	voice_volumn_slider.value = voice_volumn
	voice_volumn_label.text = str(voice_volumn * 100)
	
	var sfx_volumn = saved_data.sfx_volumn
	sfx_volumn_slider.value = sfx_volumn
	sfx_volumn_label.text = str(sfx_volumn * 100)



func _on_total_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.total_volumn = value
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	total_volumn_label.text = str(value * 100)
	
func _on_bgm_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.bgm_volumn = value
	var bus = AudioServer.get_bus_index("bgm")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	bgm_volumn_label.text = str(value * 100)

func _on_voice_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.voice_volumn = value
	var bus = AudioServer.get_bus_index("voice")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	voice_volumn_label.text = str(value * 100)

func _on_sfx_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.sfx_volumn = value
	var bus = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	sfx_volumn_label.text = str(value * 100)
