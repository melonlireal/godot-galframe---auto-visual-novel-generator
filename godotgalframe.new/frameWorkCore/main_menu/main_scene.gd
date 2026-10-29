extends Node2D
var scene_auto = preload("res://frameWorkCore/gameplay_basic/scene_auto.tscn")
var save_path: String = "user://save/"
var global_progress_save_name: String = "global_game_progress_save.tres"
var setting_save_name: String = "player_setting_save.tres"

var progress:CurrGameProgress = CurrGameProgress.new()

@onready var start_game_transition: CanvasLayer = $start_game_transition
@onready var start_game_animation_player: AnimationPlayer = $start_game_transition/AnimationPlayer
@onready var input_blocker: ColorRect = $start_game_transition/input_blocker
@onready var menu_ui: CanvasLayer = $menu_UI
@onready var menu_bgm: AudioStreamPlayer = $menu_UI/menuBGM
@onready var start_button: Button = $menu_UI/HBoxContainer/start
@onready var load_button: Button = $menu_UI/HBoxContainer/load
@onready var cg_button: Button = $menu_UI/HBoxContainer/CG
@onready var setting_button: Button = $menu_UI/HBoxContainer/setting
@onready var quit_button: Button = $menu_UI/HBoxContainer/quit



func _ready():
	start_button.pressed.connect(_on_start_pressed)
	load_button.pressed.connect(_on_load_pressed)
	cg_button.pressed.connect(_on_cg_pressed)
	setting_button.pressed.connect(_on_setting_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_game_animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	GlobalSignals.load_game_progress.connect(_on_load_game_progress)
	GlobalSignals.game_created.connect(game_created)
	GlobalSignals.back_to_menu.connect(_on_back_to_menu)
	var saved_variables: Variables = ResourceLoader.load(GlobalResources.variables_path)
	progress.variables = saved_variables.duplicate(true)
	print("main scene log start\n")
	# when start game, create default setting if no setting file exists
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	if not FileAccess.file_exists(GlobalResources.global_progress_path):
		var default_progress = GlobalGameProgress.new()
		ResourceSaver.save(default_progress, GlobalResources.global_progress_path)
	if  !(setting_save_name in DirAccess.get_files_at(save_path)):
		var default_player_setting = PlayerSetting.new()
		ResourceSaver.save(default_player_setting, save_path + setting_save_name)

		
# UI input for main scene
# the code here are no longer awful
# hopefully I think the same after a year

func _on_start_pressed() -> void:
	start_game_animation_player.play("fade_in")
	# when start game screen will fade and load game before fading out
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_bgm.playing = false
	
#	
# the below code are UI related code
func _on_load_pressed() -> void:
	UIManager.open(UIManager.UI.SAVE_LOAD, {"display_save": false})

func _on_cg_pressed() -> void:
	UIManager.open(UIManager.UI.CG_DISPLAY)

func _on_setting_pressed() -> void:
	UIManager.open(UIManager.UI.SETTING)

	
func _on_quit_pressed() -> void:
	get_tree().quit()

# the above code are UI related code

# the below code are menu transition code
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if anim_name == "fade_in":
		menu_ui.visible = false
		start_game_animation_player.play("loading")
		# when completely fade in make menu invisible and play loading animation
		var current_game:SceneAuto = find_scene_auto()
		if current_game:
			current_game.queue_free()
		var scene:SceneAuto = scene_auto.instantiate()
		scene.set_process(false)
		add_child(scene)
		scene.load_progress(progress)
		scene.set_process(true)
		scene.proceed_to_next_line()
	if anim_name == "loading":
		pass

func game_created() -> void:
	if start_game_animation_player.is_playing():
		start_game_animation_player.play("fade_out")

func _on_back_to_menu() -> void:
	var current_game:SceneAuto = find_scene_auto()
	if current_game:
		current_game.queue_free()
	progress = CurrGameProgress.new()
	var saved_variables: Variables = ResourceLoader.load(GlobalResources.variables_path)
	progress.variables = saved_variables.duplicate(true)
	menu_bgm.playing = true
	menu_ui.visible = true
	start_game_animation_player.play("fade_out")

func find_scene_auto():
	for child in self.get_children():
		if child is SceneAuto:
			return child

func _on_load_game_progress(game_progress: CurrGameProgress) -> void:
	progress = game_progress
	_on_start_pressed()


# the above code are menu transition code
