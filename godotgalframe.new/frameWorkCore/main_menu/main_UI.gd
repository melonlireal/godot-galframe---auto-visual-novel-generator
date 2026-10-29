extends GameplayUI
class_name MainUI

func ui_key() -> UIManager.UI:
	return UIManager.UI.MAIN_UI

signal quick_save
signal quick_load
signal start_auto_play
signal start_fast_forward
signal start_fast_forward_to_next_choice
signal leave_game

# 自身子节点引用
@onready var function_name: Label = $Control/ButtonContainer/TextureRect/CenterContainer/function_name
@onready var button_container: HBoxContainer = $Control/ButtonContainer
@onready var volume_slider: VSlider = $Control/volume_slider
@onready var windows_color_rect: ColorRect = $Control/ColorRect
@onready var save_button: Button = $Control/ButtonContainer/save
@onready var load_button: Button = $Control/ButtonContainer/load
@onready var quicksave_button: Button = $Control/ButtonContainer/quicksave
@onready var quickload_button: Button = $Control/ButtonContainer/quickload
@onready var setting_button: TextureButton = $Control/ButtonContainer/setting
@onready var volume_button: TextureButton = $Control/ButtonContainer/volume
@onready var story_tree_button: TextureButton = $Control/ButtonContainer/story_tree
@onready var review_dialogue_button: TextureButton = $Control/ButtonContainer/review_dialogue
@onready var auto_play_button: TextureButton = $Control/ButtonContainer/auto_play
@onready var fast_forward_button: TextureButton = $Control/ButtonContainer/fast_forward
@onready var fast_forward_to_next_choice_button: TextureButton = $Control/ButtonContainer/fast_forward_to_next_choice
@onready var hide_ui_button: TextureButton = $Control/ButtonContainer/hide_UI
@onready var leave_game_button: TextureButton = $Control/ButtonContainer/leave_game

var ui_visible: bool = true
# when UI including dialogue box is not visible
# clicking will redisplay and will not play text

var press_action_disabled: bool = false
# when true, player cannot proceed to next line with press action
# hover 进 UI 按钮时设 true，离开设 false；CG/proceed 期间也会被 scene_auto 设 true

# Called when the node enters the scene tree for the first time.


func _ready():
	save_button.pressed.connect(_on_save_pressed)
	save_button.mouse_entered.connect(_on_save_mouse_entered)
	load_button.pressed.connect(_on_load_pressed)
	load_button.mouse_entered.connect(_on_load_mouse_entered)
	quicksave_button.pressed.connect(_on_quicksave_pressed)
	quicksave_button.mouse_entered.connect(_on_quicksave_mouse_entered)
	quickload_button.pressed.connect(_on_quickload_pressed)
	quickload_button.mouse_entered.connect(_on_quickload_mouse_entered)
	setting_button.pressed.connect(_on_setting_pressed)
	setting_button.mouse_entered.connect(_on_setting_mouse_entered)
	volume_button.pressed.connect(_on_volume_pressed)
	volume_button.mouse_entered.connect(_on_volume_mouse_entered)
	story_tree_button.pressed.connect(_on_story_tree_pressed)
	story_tree_button.mouse_entered.connect(_on_story_tree_mouse_entered)
	review_dialogue_button.pressed.connect(_on_review_dialogue_pressed)
	review_dialogue_button.mouse_entered.connect(_on_review_dialogue_mouse_entered)
	auto_play_button.pressed.connect(_on_auto_play_pressed)
	auto_play_button.mouse_entered.connect(_on_auto_play_mouse_entered)
	fast_forward_button.pressed.connect(_on_fast_forward_pressed)
	fast_forward_button.mouse_entered.connect(_on_fast_forward_mouse_entered)
	fast_forward_to_next_choice_button.pressed.connect(_on_fast_forward_to_next_choice_pressed)
	fast_forward_to_next_choice_button.mouse_entered.connect(_on_fast_forward_to_next_choice_mouse_entered)
	hide_ui_button.pressed.connect(_on_hide_ui_pressed)
	hide_ui_button.mouse_entered.connect(_on_hide_ui_mouse_entered)
	leave_game_button.pressed.connect(_on_leave_game_pressed)
	leave_game_button.mouse_entered.connect(_on_leave_game_mouse_entered)
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	function_name.text = ""
	for nodes in button_container.get_children():
		nodes.mouse_exited.connect(_mouse_leave_button)
		nodes.mouse_entered.connect(_mouse_reach_button)
	volume_slider.visible = false
	volume_slider.editable = false
	var saved_data: PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	volume_slider.value = saved_data.total_volume
	windows_color_rect.color = saved_data.windows_color

		
		
func _mouse_leave_button() -> void:
	function_name.text = ""
	press_action_disabled = false

func _mouse_reach_button() -> void:
	press_action_disabled = true

	
func _on_save_mouse_entered() -> void:
	function_name.text = "保存"


func _on_save_pressed() -> void:
	_open_save_session()


func _on_load_mouse_entered() -> void:
	function_name.text = "加载"


func _on_load_pressed() -> void:
	_open_load_session()


func _on_quicksave_mouse_entered() -> void:
	function_name.text = "快速保存"
	
	
func _on_quicksave_pressed() -> void:
	quick_save.emit()
	
	
func _on_quickload_mouse_entered() -> void:
	function_name.text = "快速加载"
	
	
func _on_quickload_pressed() -> void:
	quick_load.emit()
	
	
func _on_setting_mouse_entered() -> void:
	function_name.text = "设置"
	
	
func _on_setting_pressed() -> void:
	_open_setting_session()
	
	
func _on_volume_mouse_entered() -> void:
	function_name.text = "音量"
	
	
func _on_volume_pressed() -> void:
	if volume_slider.visible:
		volume_slider.visible = false
		volume_slider.editable = false
		return
	volume_slider.visible = true
	volume_slider.editable = true
	
	
func _on_volume_slider_value_changed(value: float) -> void:
	var saved_data:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.total_volume = value
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, GlobalResources.setting_save_path)
	
	
func _on_story_tree_mouse_entered() -> void:
	function_name.text = "剧情树"
	
	
func _on_story_tree_pressed() -> void:
	_open_story_tree_session()


func _on_review_dialogue_mouse_entered() -> void:
	function_name.text = "台词回顾"
	
	
func _on_review_dialogue_pressed() -> void:
	_open_review_dialogue_session()
	
	
func _on_auto_play_mouse_entered() -> void:
	function_name.text = "自动播放"
	
	
func _on_auto_play_pressed() -> void:
	start_auto_play.emit()


func _on_fast_forward_mouse_entered() -> void:
	function_name.text = "快进"


func _on_fast_forward_pressed() -> void:
	start_fast_forward.emit()
	
	
func _on_fast_forward_to_next_choice_mouse_entered() -> void:
	function_name.text = "快进到下一选项"

	
func _on_fast_forward_to_next_choice_pressed() -> void:
	start_fast_forward_to_next_choice.emit()
	
	
func _on_hide_ui_mouse_entered() -> void:
	function_name.text = "隐藏UI"

	
func _on_hide_ui_pressed() -> void:
	_hide_ui()


func _on_leave_game_mouse_entered() -> void:
	function_name.text = "退出"


func _on_leave_game_pressed() -> void:
	leave_game.emit()


# ======== session 管理 ========

func _open_save_session() -> void:
	var temp_screen = get_viewport().get_texture().get_image()
	var scene_auto: SceneAuto = get_parent() as SceneAuto
	UIManager.open(UIManager.UI.SAVE_LOAD, {
		"display_save": true,
		"temp_save": {
			"image": temp_screen,
			"curr_chap": scene_auto.script_tree.get_chapter(),
			"curr_line": scene_auto.script_tree.get_line_num(),
			"vars": scene_auto.variables
		}
	})


func _open_load_session() -> void:
	UIManager.open(UIManager.UI.SAVE_LOAD, {"display_save": false})


func _open_setting_session() -> void:
	UIManager.open(UIManager.UI.SETTING)


func _open_review_dialogue_session() -> void:
	UIManager.open(UIManager.UI.REVIEW_DIALOGUE)


func _open_story_tree_session() -> void:
	UIManager.open(UIManager.UI.STORY_TREE)


func _hide_ui() -> void:
	UIManager.hide_gameplay()
	ui_visible = false


func is_ui_visible() -> bool:
	return ui_visible


func set_ui_visible(v: bool) -> void:
	ui_visible = v


# 由 scene_auto.load_setting 调用，应用 windows_color 到 UI 顶部色条
func apply_windows_color(color: Color) -> void:
	windows_color_rect.color = color


func is_press_disabled() -> bool:
	return press_action_disabled


func set_press_disabled(v: bool) -> void:
	press_action_disabled = v
