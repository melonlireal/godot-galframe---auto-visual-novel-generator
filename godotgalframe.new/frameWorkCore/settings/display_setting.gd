extends GridContainer

@onready var play_speed_slider: HSlider = $play_speed/HBoxContainer/MarginContainer/play_speed
@onready var play_speed_label: Label = $play_speed/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var auto_play_speed_slider: HSlider = $auto_play_speed/HBoxContainer/MarginContainer/auto_play_speed
@onready var auto_play_speed_label: Label = $auto_play_speed/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var transparency_slider: HSlider = $transparency/HBoxContainer/MarginContainer/transparency
@onready var transparency_label: Label = $transparency/HBoxContainer/data_display_box/CenterContainer/data_display

@onready var play_example: TextureRect = $play_example/TextureRect
@onready var auto_play_example: TextureRect = $auto_play_example/TextureRect
@onready var play_example_label: RichTextLabel = $play_example/Label
@onready var auto_play_example_label: RichTextLabel = $auto_play_example/Label
@onready var windows_button: TextureButton = $display/CenterContainer/HBoxContainer/windows
@onready var fullscreen_button: TextureButton = $display/CenterContainer/HBoxContainer/fullscreen

var _saved_data: PlayerSetting

func _ready():
	_saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	play_example_label.dialogue_play_finished.connect(_replay_play_example)
	auto_play_example_label.dialogue_play_finished.connect(_replay_auto_play_example)
	play_speed_slider.value_changed.connect(_on_play_speed_value_changed)
	auto_play_speed_slider.value_changed.connect(_on_auto_play_speed_value_changed)
	transparency_slider.value_changed.connect(_on_transparency_value_changed)
	play_speed_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	auto_play_speed_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	transparency_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	windows_button.button_down.connect(_on_windows_button_down)
	fullscreen_button.button_down.connect(_on_fullscreen_button_down)

func load_value() -> void:
	_saved_data = ResourceLoader.load(GlobalResources.setting_save_path)

	var play_speed: float = _saved_data.play_speed
	play_speed_slider.value = play_speed
	play_speed_label.text = str(play_speed)

	var auto_play_speed: float = _saved_data.auto_play_speed
	auto_play_speed_slider.value = auto_play_speed
	auto_play_speed_label.text = str(auto_play_speed)

	var transparency: float = _saved_data.dialogue_box_transparency
	transparency_slider.value = transparency
	transparency_label.text = str(transparency)
	play_example.modulate.a = transparency/100
	auto_play_example.modulate.a = transparency/100
	_replay_play_example()
	_replay_auto_play_example()


func _replay_play_example() -> void:
	var preview_text: String = play_example_label.text
	play_example_label.play_dialogue(preview_text, preview_text.length() / (maxf(_saved_data.play_speed, 0.001) * 0.4))


func _replay_auto_play_example() -> void:
	var preview_text: String = auto_play_example_label.text
	auto_play_example_label.play_dialogue(preview_text, preview_text.length() / (maxf(_saved_data.auto_play_speed, 0.001) * 0.4))

func _on_play_speed_value_changed(value: float) -> void:
	_saved_data.save_play_speed(value)
	play_speed_label.text = str(value)


func _on_auto_play_speed_value_changed(value: float) -> void:
	_saved_data.save_auto_play_speed(value)
	auto_play_speed_label.text = str(value)


func _on_transparency_value_changed(value: float) -> void:
	_saved_data.dialogue_box_transparency = value
	transparency_label.text = str(value)
	play_example.modulate.a = value/100
	auto_play_example.modulate.a = value/100

func _on_windows_button_down() -> void:
	%fullscreen.disabled = false
	%windows.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fullscreen_button_down() -> void:
	%windows.disabled = false
	%fullscreen.disabled = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
