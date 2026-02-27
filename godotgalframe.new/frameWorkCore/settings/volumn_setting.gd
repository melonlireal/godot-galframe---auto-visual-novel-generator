extends GridContainer



func load_value():
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	%total_volumn.value = saved_data.total_volumn
	$total_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.total_volumn * 100)
	%bgm_volumn.value = saved_data.bgm_volumn
	$bgm_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.bgm_volumn * 100)
	%voice_volumn.value = saved_data.voice_volumn
	$voice_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.voice_volumn * 100)
	%sfx_volumn.value = saved_data.sfx_volumn
	$sfx_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(saved_data.sfx_volumn * 100)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_total_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.total_volumn = value
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	$total_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value * 100)
	
func _on_bgm_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.bgm_volumn = value
	var bus = AudioServer.get_bus_index("bgm")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	$bgm_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value * 100)

func _on_voice_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.voice_volumn = value
	var bus = AudioServer.get_bus_index("voice")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	$voice_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value * 100)

func _on_sfx_volumn_value_changed(value):
	var saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.sfx_volumn = value
	var bus = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	$sfx_volumn/HBoxContainer/data_display_box/CenterContainer/data_display.text = str(value * 100)
