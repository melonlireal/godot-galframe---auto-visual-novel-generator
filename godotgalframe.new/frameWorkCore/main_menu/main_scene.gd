extends Node2D
var scene_auto = preload("res://frameWorkCore/gameplay_basic/scene_auto.tscn")
var save_path = "user://save/"
var global_progress_save_name = "global_game_progress_save.tres"
var setting_save_name = "player_setting_save.tres"

var progress:ProgressData = ProgressData.new()

func _ready():
	GlobalSignals.load_game_progress.connect(_on_load_game_progress)
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
	$".".add_child(setting, true)
	setting.queue_free()
	
		
# UI input for main scene
# the code here are no longer awful
# hopefully I think the same after a year

func _on_start_pressed():
	$color/AnimationPlayer.play("fade_in")
	# when start game screen will fade and load game before fading out
	$color/ColorRect.mouse_filter = 0
	$menu_UI/menuBGM.playing = false
	
#	
# the below code are UI related code
func _on_load_pressed():
	var loader = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	loader.display_save = false
	$".".add_child(loader)

func _on_cg_pressed():
	var CG = preload("res://frameWorkCore/art/cg_display.tscn").instantiate()
	$".".add_child(CG)

func _on_setting_pressed():
	var setting = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	$".".add_child(setting)

	
func _on_quit_pressed():
	get_tree().quit()

# the above code are UI related code

# the below code are menu transition code
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		$color/ColorRect.mouse_filter = 2
		# da fac is this for?
		get_tree().call_group("dialogue", "transition_done")
	if anim_name == "fade_in":
		$menu_UI.visible = false
		$color/AnimationPlayer.play("loading")
		# when completely fade in make menu invisible and play loading animation
		if self.find_child("scene_auto", true, false):
			self.find_child("scene_auto", true, false).queue_free()
		var scene:SceneAuto = scene_auto.instantiate()
		scene.game_created.connect(game_created)
		scene.back_to_menu.connect(back_to_menu)
		scene.set_process(false)
		# dont create new game if a game is already instantiated
		add_child(scene)
		scene.load_progress(progress)

		
	if anim_name == "loading":
		print("loading")

func game_created():
	$color/AnimationPlayer.play("fade_out")

func back_to_menu():
	if self.find_child("scene_auto", true, false):
		self.find_child("scene_auto", true, false).queue_free()
	$menu_UI/menuBGM.playing = true
	$menu_UI.visible = true
	$color/AnimationPlayer.play("fade_out")

func _on_load_game_progress(game_progress: ProgressData):
	print("loading")
	var game_scene:SceneAuto = self.find_child("scene_auto", true, false)
	if game_scene:
		# when loading game progress whil playing, load game progress directly
		$color/ColorRect.mouse_filter = 0
		$color/AnimationPlayer.play("fade_in")
		game_scene.load_progress(game_progress)
	else:
		_on_start_pressed()
		progress = game_progress

func _on_transition_donttouch_timeout():
	self.find_child("scene_auto", true, false).set_process(true)

# the above code are menu transition code
