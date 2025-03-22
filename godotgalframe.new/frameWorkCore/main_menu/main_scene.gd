extends Node2D
var scene_auto = preload("res://frameWorkCore/gameplay_basic/scene_auto.tscn")
signal done
var save = Gamedata.new()
var save_path = "user://save/"
var save_name = "save_total.tres"
var game_exists = false
var double_lock_I = false
var double_lock_II = false
var which_files = "Start.txt"
var which_lines = 1
# 这两个变量用来保证scene_auto 一定会收到加载的指令

func _ready():
	custom_rand_cover()
	if not DirAccess.dir_exists_absolute(save_path):
		DirAccess.make_dir_absolute(save_path)
	if save_name in DirAccess.get_files_at(save_path):
		load_data_volumn()
	elif save_name not in DirAccess.get_files_at(save_path):
		var default_setting = Gamedata.new()
		ResourceSaver.save(default_setting, save_path + save_name)
	$setting_menu.load_setting()
	$setting_menu.visible = false
	$setting_menu.set_process(false)
	$save.visible = false
	$setting_menu.connect("swap", menu_swap)
	$save.connect("swap", menu_swap)
	$CG_display.connect("swap", menu_swap)
	$CG_display.load_unlock()
	
func load_data_volumn():
	save = ResourceLoader.load(save_path + save_name)

# 这里的所有代码都是史山，但是我懒得修
func custom_rand_cover():
	var which_cover = RandomNumberGenerator.new()
	which_cover.randomize()
	var random = which_cover.randi_range(0,100)
	if random <= 50:
		$menu_UI/VideoStreamPlayer.stream = null
		$menu_UI/TextureRect.texture = ResourceLoader.load("res://artResource/background/yuexiqfront.png")
	elif random > 50:
		$menu_UI/TextureRect.texture = null
		$menu_UI/VideoStreamPlayer.stream = ResourceLoader.load("res://artResource/background/G.ogv")
		$menu_UI/VideoStreamPlayer.play()
# 接受主界面UI和游戏界面UI输入

func _on_start_pressed():
	if not game_exists:
		which_files = "Start.txt"
		which_lines = 1
	$color/AnimationPlayer.play("fade_in")
	$color/ColorRect.mouse_filter = 0
	$menu_UI/menuBGM.playing = false
	
func game_created():
	# 当游戏被创建时激活，如果游戏在加载状态等待加载完毕后的信号再激活
	if game_exists:
		# 已经存在游戏的情况下不播放动画
		game_exists = false
		return
	$color/AnimationPlayer.play("fade_out")
	
	
func _on_load_pressed():
	$save.visible = true
	$save.display_save = false
	$menu_UI.visible = false

func _on_cg_pressed():
	$CG_display.visible = true
	$menu_UI.visible = false


func _on_setting_pressed():
	$setting_menu.visible = true
	$setting_menu.set_process(true)
	$menu_UI.visible = false


func display_setting():
	$setting_menu.visible = true
	
	
func display_save():
	$save.display_save = true
	$save.visible = true
	
func display_load():
	$save.display_save = false
	$save.visible = true
	
	
func _on_quit_pressed():
	get_tree().quit()

# 结束

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_out":
		$color/ColorRect.mouse_filter = 2
		get_tree().call_group("game_play", "_transition_done")
	if anim_name == "fade_in":
		print("finish fade in")
		$menu_UI.visible = false
		$color/AnimationPlayer.play("loading")
		print($color/AnimationPlayer.current_animation)
		var scene = scene_auto.instantiate()
		scene.set_process(false)
		if not self.find_child("scene_auto", true, false):
			# 如果是在已经有游戏的情况下加载，不在创建游戏
			add_child(scene)
		print(which_files)
		print(which_lines)
		self.get_tree().call_group("game_play", "load_progress", which_files, which_lines)
	if anim_name == "loading":
		print("loading")


func menu_swap():
	if self.find_child("scene_auto", true, false):
		self.get_tree().call_group("game_play", "load_setting")
		for scene in self.find_child("scene_auto", true,false).get_children():
			if scene is CanvasLayer:
				scene.visible = true
		$transition_DONTTOUCH.start()
		# 捏麻转场景转的太快了把在设置界面的点击当操作了， 被迫史山
		# 如果已经开始游戏， 切换菜单时不展示主界面
	else:
		self.find_child("menu_UI").visible = true


func back_menu():
	if self.find_child("scene_auto", true, false):
		self.find_child("scene_auto", true, false).queue_free()
	$menu_UI/menuBGM.playing = true
	$menu_UI.visible = true
	$color/AnimationPlayer.play("fade_out")


func load_game(which_file: String, which_line: int):
	print("loading")
	if self.find_child("scene_auto", true, false):
		# 在正在游玩的状态下读档时， 切换读取菜单至游戏且加载游戏进度
		$color/ColorRect.mouse_filter = 0
		$save.visible = false
		$color/AnimationPlayer.play("fade_in")
		menu_swap()
		self.get_tree().call_group("game_play", "load_progress", which_file, which_line)
	else:
		game_exists = true
		menu_swap()
		$save.visible = false
		_on_start_pressed()
		which_files = which_file
		which_lines = which_line
		#var scene = scene_auto.instantiate()
		#scene.set_process(false)
		#if not self.find_child("scene_auto", true, false):
			# 如果是在已经有游戏的情况下加载，不在创建游戏
			#add_child(scene)
			# 这串代码是纯纯的史山，比加载游戏还要史山。因为如果现在不创建的话
			# 下面的代码就找不到游戏
			# 然而正常情况是在转场时创建，所以还得担心会不会创两个出来的问题
			# 修好了，爽！
		#self.get_tree().call_group("game_play", "load_progress", which_file, which_line)

func _on_transition_donttouch_timeout():
	self.find_child("scene_auto", true, false).set_process(true)


