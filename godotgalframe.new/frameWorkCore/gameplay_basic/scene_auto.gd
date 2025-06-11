extends CanvasLayer
@onready var choice_reach = false
@onready var auto_play = false
# 自动播放状态，在这个状态下点击不会触发台词展现和下一条台词的效果
@export var speed_up = false
# 快进状态，在这个状态下点击不会触发台词展现和下一条台词的效果
@onready var UI_visible = true
# 对话框隐藏的话不会继续播放
@export var can_press = true
# 这个不要动，是用来在加载游戏时暂停操作的
@onready var start_time = true #确保proceed只在需要的时候开始记时
# 在选项出现的情况下停止 proceed继续读取txt文档
var save_path = "user://save/save_total.tres"
var leave = false
# 用于暂时储存快进和自动播放的状态，以便在CG展示结束后继续
var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
# 文案/命令的存储
var variables: Variables = ResourceLoader.load("res://save/variables.tres")
# store variables
signal change_avatar
signal change_background
signal change_music
signal clear_all_avatar
signal update_art_list

func _ready():
	$"DO NOT TOUCH/Panel".visible = false
	$review_dialogues.visible = false
	%dialogue.text = ""
	%character.text = ""
	%dialogue.visible_ratio = 0.0
	%errorlog.text = ""
	$UI.connect("on_button", _on_button)
	$UI.connect("out_button", _out_button)
	set_bus()
	load_setting()
	self.get_tree().call_group("main", "game_created")
	# 告诉main游戏已经创建完毕
	
func set_bus():
	# 将所有音频设置到对应的管线
	for bgm in self.find_child("music").find_child("bgm").get_children():
		bgm.set_bus("bgm")
	for voice in self.find_child("music").find_child("voice").get_children():
		voice.set_bus("voice")
	for sfx in self.find_child("music").find_child("sound_effect").get_children():
		sfx.set_bus("sound_effect")
		

func _process(_delta):
	if Input.is_action_just_pressed("press") and check_in_game():
		$dialogue.visible = true
		$UI.visible = true
		$choice.visible = true
		if auto_play:
			auto_play = false
			return
		if speed_up:
			speed_up = false
			return
		if not UI_visible:
			UI_visible = true
			return
		# 如果在自动播放状态下不能通过点击调整台词
		# UI隐藏状态也不行
		# 通过点击取消UI隐藏和自动播放状态
		# 在CG展示模式下直接锁死
		if %dialogue.visible_ratio != 1.0:
			%dialogue.visible_ratio = 1.0
			# 双击显示全部台词
		else:
			# 如果当前台词已经播放完，进下一句台词
			if not choice_reach:
				%dialogue.visible_ratio = 0.0 
			proceed()
	if Input.is_action_just_pressed("auto") and check_in_game():
		_on_auto_pressed()
	if Input.is_action_just_pressed("return"):
		$review_dialogues.visible = false
		can_press = true
		$dialogue.visible = true
		$UI.visible = true
		pass
	if auto_play and %dialogue.visible_ratio == 1.0 and start_time:
		start_time = false
		$auto_play_timer.start()
		# 如果处于自动播放状态，且台词已播放至结尾。那么开始跳到下一台词的倒计时
# 展示台词和角色名

func check_in_game() -> bool:
	return !$review_dialogues.visible and can_press
	
# continue the dialogue
func proceed():
	if choice_reach:
		return
	# text will be mutated each time 
	# then extract character, dialogue and command
	var text = {};
	var status = script_tree.get_line(text)
	if status == "exit":
		print("exit")
		leave = true
		_on_leave_pressed()
		return
	if status == "choice reach":
		print("choice is reached\n")
		$dialogue.visible = true
		$UI.visible = true
		%dialogue.visible_ratio = 1.0
		choice_reach = true
		choice_jump()
		return
	else:
		if speed_up:
			%dialogue.visible_ratio = 1.0
		else:
			%dialogue.visible_ratio = 0.0
		# when play in speed mode there shouldn't be typewritte effect
		if text["character"] == "":
			$dialogue/dialogue_box.visible = false
			$dialogue/narration_box.visible = true
			%dialogue.narrration = true
		else:
			$dialogue/dialogue_box.visible = true
			$dialogue/narration_box.visible = false
			%dialogue.narrration = false
			# 粗略的根据是否为旁白切换对话框格式
		command_execute(text["command"])
		%character.text = text["character"]
		%dialogue.text = text["dialogue"]
		$review_dialogues.get_words(text["character"], text["dialogue"])
		$review_dialogues.add_line()
		print("character ", text["character"], " is speaking script: ", text["dialogue"], "\n")
		self.get_tree().call_group("dialogue", "_start_dialogue")
# 读取命令并执行	

func choice_jump():
	var choice_list = check_choice_condition(script_tree.get_choices())
	if choice_list == []:
		choice_reach = false
		return "fail"
	var option = preload("res://frameWorkCore/gameplay_basic/choice.tscn")
	for choice in choice_list:
		var ready_option = option.instantiate()
		%choice_box.add_child(ready_option)
		var choice_text = ready_option.get_node("center").get_node("choice_text")
		var going_to = ready_option.get_node("going_to")
		choice_text.text = choice[0]
		going_to.text = choice[1]
		ready_option.connect("travel_to", travel)
	if len(choice_list) == 1:
		# if only one option and auto jump is true
		# jump
		if choice_list[0][2] == "true":
			travel(choice_list[0][1])
			return "fail"
			# shit code, only purpose is to prevent jump to choice
			# from ending the game
	return "suceed"
# 读取选项并跳转
		
func check_choice_condition(choices: Array):
	var new_choices = []
	for choice in choices:
		if len(choice) <= 3:
			new_choices.append(choice)
		else:
			if variables.var_con(choice[3], choice[4], choice[5]):
				new_choices.append(choice)
	return new_choices
	
func travel(location: String):
	# triggered when a choice is clicked
	script_tree.change_chapter(location)
	# need to update error checker, will update in error system overhaul
	for child in %choice_box.get_children():
		%choice_box.remove_child(child)
	%dialogue.visible_ratio = 0
	# clean all the displayed choice box and reset dialogue
	choice_reach = false
	proceed()
		
# TODO O(2n) complexity, need to try to fix in future
func command_execute(orders: Array):
	self.update_art_list.emit(orders)
	# find art list lterate the command to find all slot that will be overwrite
	# these slot does not need to be cleared
	# this feature helps with avatar transition and potentialy many feature
	for order in orders:
		var which_order = order[0]
		print("curr order is", which_order, "\n")
		match which_order:
			"character":
				self.change_avatar.emit(order[1], order[2], order[3], order[4])
			"background":
				self.change_background.emit(order[1], order[2])
			"bgm", "sound_effect", "voice":
				self.change_music.emit(which_order, order[1])
			"CG":
				auto_play = false
				speed_up = false
				self.clear_all_avatar.emit()
				# since cg is displayed independently
				# all avatar are expected to be cleared
				# will I fix this in future? idk
				$UI.visible = false
				$dialogue.visible = false
				can_press = false
				self.change_background.emit(order[1], "false")
				print("displaying CG\n")
			"update":
				variables.var_op(order[1], order[2], order[3])
			_:
				print("unknown commad ", which_order, "\n")
				self.get_tree().call_group("errorlog", "unknown_command", which_order)
	return
		
func _on_save_pressed():
	var temp_screen = get_viewport().get_texture().get_image()
	#提前截图游戏画面
	get_tree().call_group("main", "display_save")
	get_tree().call_group("save", "get_temp_save_data", temp_screen, 
		script_tree.get_chapter(), script_tree.get_line_num(), variables)
	#先把游戏画面送过去再说，可以不存档
	for canvas in self.get_children():
		if canvas is CanvasLayer:
			canvas.visible = false
	self.set_process(false)
	
func _on_load_pressed():
	get_tree().call_group("main", "display_load")
	for canvas in self.get_children():
		if canvas is CanvasLayer:
			canvas.visible = false
	self.set_process(false)
	
func _on_quicksave_pressed():
	var progress = progress_data.new()
	progress.which_file = script_tree.get_chapter()
	progress.which_line = script_tree.get_line_num()
	ResourceSaver.save(progress, "user://save/quick_save.tres")
	ResourceSaver.save(variables,"user://save/quick_save_var.tres")
	
func _on_quickload_pressed():
	var quick_save = "user://save/quick_save.tres"
	var quick_save_var = "user://save/quick_save_var.tres"
	var find_quick_save_var: Variables  = ResourceLoader.load(quick_save_var)
	var find_save = ResourceLoader.load(quick_save)
	if find_save == null:
		return
	print(find_save)
	self.load_progress(find_save.which_file, find_save.which_line, find_quick_save_var)

func _on_setting_pressed():
	get_tree().call_group("main", "display_setting")
	for canvas in self.get_children():
		if canvas is CanvasLayer:
			canvas.visible = false
	self.set_process(false)
	
func _on_review_pressed():
	$review_dialogues.visible = true
	$dialogue.visible = false
	$UI.visible = false
	pass # Replace with function body.
	# 还没做
		
func _on_show_tree_pressed():
	pass # Replace with function body.
	# 还没做
		
func _on_auto_pressed():
	if auto_play:
		%dialogue.on_auto = false
		auto_play = false
		return
		# 如果已经在自动播放则取消自动播放
	speed_up = false
	auto_play = true
	%dialogue.on_auto = true
	proceed()
	
func _on_forward_speed_pressed():
	if speed_up:
		speed_up = false
		return
	auto_play = false
	speed_up = true
	proceed()
	$speed_up_timer.start()
	
func _on_forward_to_next_choice_pressed():
	if choice_reach:
		return
	$music.music_clear("bgm")
	$music.music_clear("voice")
	$music.music_clear("sound_effect")
	var choice_list = script_tree.get_choices()
	if choice_list == []:
		print("no choice found")
		return
	script_tree.jump_choice()
	proceed()
	
func _on_visible_pressed():
	if $dialogue.visible and $UI.visible and $choice.visible:
		$dialogue.visible = false
		$UI.visible = false
		$choice.visible = false
		UI_visible = false
		auto_play = false
	else:
		$dialogue.visible = true
		$UI.visible = true
		$choice.visible = true
		# 这段可能不用, 但留着保险
	
func _on_leave_pressed():
	get_tree().call_group("main", "back_menu")
	
func load_progress(which_file: String, which_line: int, vars: Variables):
	speed_up = false
	auto_play = false
	choice_reach = false
	%dialogue.on_transition = true
	for child in %choice_box.get_children():
		%choice_box.remove_child(child)
	# reset all ingame setting including removing choices
	print("loading progress\n")
	print("file is ", which_file, "\n")
	print("line is ", which_line, "\n")
	emit_signal("music_clear", "bgm")
	emit_signal("music_clear", "voice")
	emit_signal("music_clear", "sound_effect")
	emit_signal("clear_all_avatar")
	script_tree.load_progress(which_file, which_line - 1)
	variables.load_var(vars.variables)
	# script tree acc give the line after its current progress
	proceed()
	self.get_tree().call_group("main", "game_created")
	# 第二次告诉main游戏已经创建，这代表即将播放动画fade_out
	%dialogue.on_transition = false
	
func load_setting():
	print("load setting!")
	$review_dialogues.visible = false
	# hard code shit, fix later
	var save = ResourceLoader.load(save_path)
	print(save.dialogue_box_transparency)
	$dialogue/dialogue_box.modulate.a = save.dialogue_box_transparency / 100
	$dialogue/narration_box.modulate.a = save.dialogue_box_transparency / 100
	$UI/Control/ColorRect.color = save.windows_color	
# no need to care for the rest it is what it is

func _on_button():
	print("on button\n")
	can_press = false
	
func _out_button():
	can_press = true

func _on_auto_play_timer_timeout():
	print("auto play timeout\n")
	start_time = true
	if auto_play:
		# 倒计时结束开始展示下一条台词
		proceed()

func _on_speed_up_timer_timeout():
	print("speed up timeout\n")
	if speed_up:
		proceed()
		$speed_up_timer.start()
		
func _on_viedo_background_finished():
	if $background/viedo_background.loop:
		# 如果处于循环状态，说明正在展示动态背景，那么不管
		return
	# 不然就说明CG展示结束了，下一行台词了该
	$UI.visible = true
	$dialogue.visible = true
	can_press = true
	proceed()
