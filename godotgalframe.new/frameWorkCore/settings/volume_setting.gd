extends GridContainer
@onready var total_volume_slider: HSlider = $total_volume/HBoxContainer/MarginContainer/total_volume
@onready var total_volume_label: Label = $total_volume/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var bgm_volume_slider: HSlider = $bgm_volume/HBoxContainer/MarginContainer/bgm_volume
@onready var bgm_volume_label: Label = $bgm_volume/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var voice_volume_slider: HSlider = $voice_volume/HBoxContainer/MarginContainer/voice_volume
@onready var voice_volume_label: Label = $voice_volume/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var sfx_volume_slider: HSlider = $sfx_volume/HBoxContainer/MarginContainer/sfx_volume
@onready var sfx_volume_label: Label = $sfx_volume/HBoxContainer/data_display_box/CenterContainer/data_display

var _saved_data: PlayerSetting

func _ready() -> void:
	_saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	total_volume_slider.value_changed.connect(_on_total_volume_value_changed)
	bgm_volume_slider.value_changed.connect(_on_bgm_volume_value_changed)
	voice_volume_slider.value_changed.connect(_on_voice_volume_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_value_changed)
	total_volume_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	bgm_volume_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	voice_volume_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	sfx_volume_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))

func load_value() -> void:
	_saved_data = ResourceLoader.load(GlobalResources.setting_save_path)

	var total_volume: float = _saved_data.total_volume
	total_volume_slider.value = total_volume
	total_volume_label.text = str(total_volume * 100)

	var bgm_volume: float = _saved_data.bgm_volume
	bgm_volume_slider.value = bgm_volume
	bgm_volume_label.text = str(bgm_volume * 100)

	var voice_volume: float = _saved_data.voice_volume
	voice_volume_slider.value = voice_volume
	voice_volume_label.text = str(voice_volume * 100)

	var sfx_volume: float = _saved_data.sfx_volume
	sfx_volume_slider.value = sfx_volume
	sfx_volume_label.text = str(sfx_volume * 100)


func _on_total_volume_value_changed(value: float) -> void:
	_saved_data.total_volume = value
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	total_volume_label.text = str(value * 100)

func _on_bgm_volume_value_changed(value: float) -> void:
	_saved_data.bgm_volume = value
	var bus = AudioServer.get_bus_index("bgm")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	bgm_volume_label.text = str(value * 100)

func _on_voice_volume_value_changed(value: float) -> void:
	_saved_data.voice_volume = value
	var bus = AudioServer.get_bus_index("voice")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	voice_volume_label.text = str(value * 100)

func _on_sfx_volume_value_changed(value: float) -> void:
	_saved_data.sfx_volume = value
	var bus = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	sfx_volume_label.text = str(value * 100)
