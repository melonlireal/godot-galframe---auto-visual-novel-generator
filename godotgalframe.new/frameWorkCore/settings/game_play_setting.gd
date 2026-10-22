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

var _saved_data: PlayerSetting

func _ready():
	_saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	red_slider.value_changed.connect(_on_red_value_changed)
	green_slider.value_changed.connect(_on_green_value_changed)
	blue_slider.value_changed.connect(_on_blue_value_changed)
	alpha_slider.value_changed.connect(_on_alpha_value_changed)
	red_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	green_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	blue_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))
	alpha_slider.drag_ended.connect(func(_c): ResourceSaver.save(_saved_data, GlobalResources.setting_save_path))


func load_value() -> void:
	_saved_data = ResourceLoader.load(GlobalResources.setting_save_path)
	play_example.color = _saved_data.windows_color

	var red: float = _saved_data.red
	red_slider.value = red
	red_label.text = str(red)

	var green: float = _saved_data.green
	green_slider.value = green
	green_label.text = str(green)

	var blue: float = _saved_data.blue
	blue_slider.value = blue
	blue_label.text = str(blue)

	var alpha: float = _saved_data.alpha
	alpha_slider.value = alpha
	alpha_label.text = str(alpha)


func _on_red_value_changed(value: float) -> void:
	_saved_data.change_red(value)
	play_example.color.r = value/255
	red_label.text = str(_saved_data.red)


func _on_green_value_changed(value: float) -> void:
	_saved_data.change_green(value)
	play_example.color.g = value/255
	green_label.text = str(_saved_data.green)


func _on_blue_value_changed(value: float) -> void:
	_saved_data.change_blue(value)
	play_example.color.b = value/255
	blue_label.text = str(_saved_data.blue)


func _on_alpha_value_changed(value: float) -> void:
	_saved_data.change_alpha(value)
	play_example.color.a = value/100
	alpha_label.text = str(_saved_data.alpha)
