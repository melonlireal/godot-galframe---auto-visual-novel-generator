extends Node2D
var scene_auto = preload("res://frameWorkCore/gameplay_basic/scene_auto.tscn")
var save_path = "user://save/"
var global_progress_save_name = "global_game_progress_save.tres"
var setting_save_name = "player_setting_save.tres"

var progress:ProgressData = ProgressData.new()

@onready var start_game_transition: CanvasLayer = $start_game_transition
@onready var start_game_animation_player: AnimationPlayer = $start_game_transition/AnimationPlayer
@onready var input_blocker: ColorRect = $start_game_transition/input_blocker
@onready var menu_ui: CanvasLayer = $menu_UI
@onready var menu_bgm: AudioStreamPlayer = $menu_UI/menuBGM



func _ready():
	GlobalSignals.load_game_progress.connect(_on_load_game_progress)
	GlobalSignals.game_created.connect(game_created)
	var saved_variables: Variables = ResourceLoader.load(GlobalResources.variables_path)
	progress.variables = saved_variables.get_all_var()
	print("main scene log start\n")
	# when start game, create default setting if no setting file exists
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	if global_progress_save_name in DirAccess.get_files_at(save_path)\
		and setting_save_name in DirAccess.get_files_at(save_path):
		pass
	else:
		var default_player_setting = PlayerSetting.new()
		var default_progress = GlobalGameProgress.new()
		ResourceSaver.save(default_player_setting, save_path + setting_save_name)
		ResourceSaver.save(default_progress, save_path + global_progress_save_name)
	#add setting and dialogue review once to load values
	#this is a temporary solution
	var setting = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	add_child(setting, true)
	setting.queue_free()
	
		
# UI input for main scene
# the code here are no longer awful
# hopefully I think the same after a year

func _on_start_pressed():
	start_game_animation_player.play("fade_in")
	# when start game screen will fade and load game before fading out
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_bgm.playing = false
	
#	
# the below code are UI related code
func _on_load_pressed():
	var loader = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	loader.display_save = false
	add_child(loader)

func _on_cg_pressed():
	var CG = preload("res://frameWorkCore/art/cg_display.tscn").instantiate()
	add_child(CG)

func _on_setting_pressed():
	var setting = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	add_child(setting)

	
func _on_quit_pressed():
	get_tree().quit()

# the above code are UI related code

# the below code are menu transition code
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		GlobalSignals.start_game.emit()
	if anim_name == "fade_in":
		menu_ui.visible = false
		start_game_animation_player.play("loading")
		# when completely fade in make menu invisible and play loading animation
		var current_game:SceneAuto = find_scene_auto()
		if current_game:
			current_game.queue_free()
		var scene:SceneAuto = scene_auto.instantiate()
		scene.back_to_menu.connect(back_to_menu)
		scene.set_process(false)
		# dont create new game if a game is already instantiated
		add_child(scene)
		scene.load_progress(progress)
		scene.proceed_to_next_line()

		
	if anim_name == "loading":
		print("loading")

func game_created():
	start_game_animation_player.play("fade_out")

func back_to_menu():
	var current_game:SceneAuto = find_scene_auto()
	if current_game:
		current_game.queue_free()
	progress = ProgressData.new()
	menu_bgm.playing = true
	menu_ui.visible = true
	start_game_animation_player.play("fade_out")
	
func find_scene_auto():
	for child in self.get_children():
		if child is SceneAuto:
			return child

func _on_load_game_progress(game_progress: ProgressData):
	progress = game_progress
	_on_start_pressed()


# the above code are menu transition code
