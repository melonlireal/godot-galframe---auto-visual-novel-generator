class_name SettingMenu
extends PopupUI
signal reload_setting


func ui_key() -> UIManager.UI:
	return UIManager.UI.SETTING

@onready var settings: Control = $settings
@onready var display_setting: GridContainer = $settings/display_setting
@onready var volume_setting: GridContainer = $settings/volume_setting
@onready var game_play_setting: GridContainer = $settings/game_play_setting
@onready var options_display: Button = $options/display
@onready var options_volume: Button = $options/volume
@onready var options_play: Button = $options/play
@onready var return_button: TextureButton = $return

# Called when the node enters the scene tree for the first time.
func _ready():
	options_display.pressed.connect(_on_display_pressed)
	options_volume.pressed.connect(_on_volume_pressed)
	options_play.pressed.connect(_on_play_pressed)
	return_button.button_down.connect(_on_return_button_down)
	load_setting()
	%windows.disabled = true
	%fullscreen.disabled = false
	options_display._on_pressed()
# Called every frame. 'delta' is the elapsed time since the previous frame.

func load_setting() -> void:
	for node in settings.get_children():
		node.load_value()


func set_default() -> void:
	pass

func _on_return_button_down() -> void:
	UIManager.close(UIManager.UI.SETTING)
	GlobalSignals.reload_setting.emit()


func _on_display_pressed() -> void:
	volume_setting.visible = false
	game_play_setting.visible = false
	display_setting.visible = true

func _on_volume_pressed() -> void:
	display_setting.visible = false
	game_play_setting.visible = false
	volume_setting.visible = true


func _on_play_pressed() -> void:
	volume_setting.visible = false
	display_setting.visible = false
	game_play_setting.visible = true
