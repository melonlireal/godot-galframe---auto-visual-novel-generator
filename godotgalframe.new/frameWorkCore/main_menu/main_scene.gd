extends Node2D
var scene_auto = preload("res://frameWorkCore/gameplay_basic/scene_auto.tscn")
var save = Gamedata.new()
var save_path = "user://save/"
var save_name = "save_total.tres"
#var game_exists = false
var which_files = "Start.txt"
var which_lines = 1
var which_var = ResourceLoader.load("res://save/variables.tres")
# 这两个变量用来保证scene_auto 一定会收到加载的指令

func _ready():
	print("main scene log start\n")
	# when start game, create default setting if no setting file exists
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	if save_name in DirAccess.get_files_at(save_path):
		save = ResourceLoader.load(save_path + save_name)
	elif save_name not in DirAccess.get_files_at(save_path):
		var default_setting = Gamedata.new()
		print("initial play speed is ", default_setting.play_speed, "\n")
		ResourceSaver.save(default_setting, save_path + save_name)
	
		
# 接受主界面UI和游戏界面UI输入
# the code here are no longer a pile of shit
# hopefully I think the same after a year

func _on_start_pressed():
	which_files = "Start.txt"
	which_lines = 1
	$color/AnimationPlayer.play("fade_in")
	# when start game screen will fade and load game before fading out
	$color/ColorRect.mouse_filter = 0
	$menu_UI/menuBGM.playing = false
	
func game_created():
	$color/AnimationPlayer.play("fade_out")
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
		if not self.find_child("scene_auto", true, false):
			var scene = scene_auto.instantiate()
			scene.set_process(false)
			# 如果是在已经有游戏的情况下加载，不在创建游戏
			add_child(scene)
		print(which_files)
		print(which_lines)
		self.get_tree().call_group("game_play", "load_progress", which_files, which_lines, which_var)
	if anim_name == "loading":
		print("loading")

func back_menu():
	if self.find_child("scene_auto", true, false):
		self.find_child("scene_auto", true, false).queue_free()
	$menu_UI/menuBGM.playing = true
	$menu_UI.visible = true
	$color/AnimationPlayer.play("fade_out")

func load_game(which_file: String, which_line: int, vars: Variables):
	print("loading")
	if self.find_child("scene_auto", true, false):
		# 在正在游玩的状态下读档时， 切换读取菜单至游戏且加载游戏进度
		$color/ColorRect.mouse_filter = 0
		$color/AnimationPlayer.play("fade_in")
		self.get_tree().call_group("game_play", "load_progress", which_file, which_line, vars)
	else:
		_on_start_pressed()
		which_files = which_file
		which_lines = which_line
		which_var = vars

func _on_transition_donttouch_timeout():
	self.find_child("scene_auto", true, false).set_process(true)

# the above code are menu transition code
