class_name  SettingMenu
extends CanvasLayer
signal reload_setting

@onready var settings: Control = $settings
@onready var display_setting: GridContainer = $settings/display_setting
@onready var volumn_setting: GridContainer = $settings/volumn_setting
@onready var game_play_setting: GridContainer = $settings/game_play_setting
@onready var options_display: Button = $options/display
@onready var options_volumn: Button = $options/volumn
@onready var options_play: Button = $options/play
@onready var return_button: TextureButton = $return

# Called when the node enters the scene tree for the first time.
func _ready():
	options_display.pressed.connect(_on_display_pressed)
	options_volumn.pressed.connect(_on_volumn_pressed)
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
	GlobalSignals.close_ui.emit()
	reload_setting.emit()
	self.queue_free()


func _on_display_pressed() -> void:
	volumn_setting.visible = false
	game_play_setting.visible = false
	display_setting.visible = true

func _on_volumn_pressed() -> void:
	display_setting.visible = false
	game_play_setting.visible = false
	volumn_setting.visible = true


func _on_play_pressed() -> void:
	volumn_setting.visible = false
	display_setting.visible = false
	game_play_setting.visible = true
