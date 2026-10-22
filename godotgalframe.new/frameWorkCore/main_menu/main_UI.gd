extends CanvasLayer
class_name MainUI

signal quick_save
signal quick_load
signal start_auto_play
signal start_fast_forward
signal start_fast_forward_to_next_choice
signal leave_game

# 兄弟节点引用（owner 是 scene_auto）
@export  var dialogue_controller: DialogueController
@export  var review_dialogues:ReviewDialogues
@export  var story_tree:StoryTree
@export var choice_controller: ChoiceController
# 自身子节点引用
@onready var function_name: Label = $Control/ButtonContainer/TextureRect/CenterContainer/function_name
@onready var button_container: HBoxContainer = $Control/ButtonContainer
@onready var volumn_slider: VSlider = $Control/volumn_slider
@onready var windows_color_rect: ColorRect = $Control/ColorRect
@onready var save_button: Button = $Control/ButtonContainer/save
@onready var load_button: Button = $Control/ButtonContainer/load
@onready var quicksave_button: Button = $Control/ButtonContainer/quicksave
@onready var quickload_button: Button = $Control/ButtonContainer/quickload
@onready var setting_button: TextureButton = $Control/ButtonContainer/setting
@onready var volumn_button: TextureButton = $Control/ButtonContainer/volumn
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
	volumn_button.pressed.connect(_on_volumn_pressed)
	volumn_button.mouse_entered.connect(_on_volumn_mouse_entered)
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
	volumn_slider.value_changed.connect(_on_volumn_slider_value_changed)
	function_name.text = ""
	for nodes in button_container.get_children():
		nodes.mouse_exited.connect(_mouse_leave_button)
		nodes.mouse_entered.connect(_mouse_reach_button)
	volumn_slider.visible = false
	volumn_slider.editable = false
	var saved_data: PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	volumn_slider.value = saved_data.total_volumn
	windows_color_rect.color = saved_data.windows_color
	# 监听 review_dialogues / story_tree 的 close 信号，内化退出逻辑
	review_dialogues.connect("close", _on_quit_review_dialogue)
	story_tree.connect("close", _on_quit_story_tree)
		
		
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
	
	
func _on_volumn_mouse_entered() -> void:
	function_name.text = "音量"
	
	
func _on_volumn_pressed() -> void:
	if volumn_slider.visible:
		volumn_slider.visible = false
		volumn_slider.editable = false
		return
	volumn_slider.visible = true
	volumn_slider.editable = true
	
	
func _on_volumn_slider_value_changed(value: float) -> void:
	var saved_data:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	saved_data.total_volumn = value
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


# ======== session 管理（从 scene_auto 搬过来）========

func _open_save_session() -> void:
	dialogue_controller.set_state(GlobalType.GameState.PAUSED)
	var temp_screen = get_viewport().get_texture().get_image()
	var saver:SaveLoad = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	saver.display_save = true
	saver.get_temp_save_data(temp_screen, owner.script_tree.get_chapter(), owner.script_tree.get_line_num(), owner.variables)
	add_sibling(saver)


func _open_load_session() -> void:
	dialogue_controller.set_state(GlobalType.GameState.PAUSED)
	var loader:SaveLoad = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	loader.display_save = false
	add_sibling(loader)


func _open_setting_session() -> void:
	dialogue_controller.set_state(GlobalType.GameState.PAUSED)
	var setting:SettingMenu = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	owner.add_child(setting, true)
	setting.set_owner(owner)
	setting.reload_setting.connect(owner.load_setting)


func _open_review_dialogue_session() -> void:
	dialogue_controller.set_state(GlobalType.GameState.PAUSED)
	review_dialogues.jump_to_buttom()
	review_dialogues.show()
	dialogue_controller.hide()
	self.hide()


func _on_quit_review_dialogue() -> void:
	review_dialogues.hide()
	dialogue_controller.set_state(GlobalType.GameState.DEFAULT)
	dialogue_controller.show()
	self.show()


func _open_story_tree_session() -> void:
	dialogue_controller.set_state(GlobalType.GameState.PAUSED)
	story_tree.show()
	dialogue_controller.hide()
	self.hide()


func _on_quit_story_tree() -> void:
	story_tree.hide()
	dialogue_controller.set_state(GlobalType.GameState.DEFAULT)
	dialogue_controller.show()
	self.show()


func _hide_ui() -> void:
	if dialogue_controller.visible and self.visible and choice_controller.visible:
		dialogue_controller.hide()
		self.hide()
		choice_controller.hide()
		ui_visible = false
		dialogue_controller.set_state(GlobalType.GameState.DEFAULT)
		dialogue_controller.stop_speedup()
		dialogue_controller.pause_interaction()


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
