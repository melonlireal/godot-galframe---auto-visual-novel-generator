extends CanvasLayer
class_name SceneAuto
@onready var choice_reach = false

@export var auto_play = false
# indicate that the game is in autoplay state
# clicking will stop autoplay and will not display next line

@export var speed_up = false
# indicate that the game is in speed up state
# clicking will stop autoplay and will not display next line

@onready var UI_visible = true
# when UI including dialogue box is not visible
# clicking will redisplay and will not play text

@export var can_press = true
# can press is used to pause player input press
# when necessary

#TODO this shit I forgot its purpose
@onready var start_time = true 
# 确保proceed只在需要的时候开始记时
# 在选项出现的情况下停止 proceed继续读取txt文档

var save_path = "user://save/save_total.tres"
var UI_switched = false
# prevent the bug of "extra click" after switching UI
# set as true when ever player opens another UI window during game

var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
# where dialogue and command are stored

# store inital variable to temporary variables used for this game
var variables: Variables = Variables.new()





func _ready():
	variables.set_all_var(GlobalResources.variables.get_all_var())
	$"DO NOT TOUCH/Panel".visible = false
	$review_dialogues.visible = false
	%dialogue.text = ""
	%character.text = ""
	%dialogue.visible_ratio = 0.0
	%errorlog.text = ""
	$UI.connect("on_button", _on_button)
	$UI.connect("out_button", _out_button)
	$review_dialogues.connect("close", quit_review)
	set_bus()
	load_setting()
	var setting = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	$".".add_child(setting, true)
	setting.queue_free()
	#add setting and dialogue review once to load values
	#TODO this is a temporary solution
	
	self.get_tree().call_group("main", "game_created")
	# tell main game is created


func set_bus():
	# set all audio to respective bus
	for bgm in self.find_child("music").find_child("bgm").get_children():
		bgm.set_bus("bgm")
	for voice in self.find_child("music").find_child("voice").get_children():
		voice.set_bus("voice")
	for sfx in self.find_child("music").find_child("sound_effect").get_children():
		sfx.set_bus("sound_effect")


func _process(_delta):
	if auto_play and %dialogue.visible_ratio == 1.0 and start_time:
		start_time = false
		$auto_play_timer.start()
		# TODO surely logic in here can be moved else where
		# if dialogue has reached its end during autoplay state
		# start time which proceed to next line after timeout


func _input(event: InputEvent) -> void:
	var status = check_in_game()
	if event.is_action_pressed("press") and check_in_game():
		# press advance dialogue to next line or stop the current state
		$dialogue.visible = true
		$UI.visible = true
		$choice.visible = true
		if auto_play or speed_up or not UI_visible or choice_reach:
			# check if there is any state that blocks dialogue from playing
			auto_play = false
			speed_up = false
			UI_visible = true
			# if there is, shut down the state and dont advance
			return
		if %dialogue.visible_ratio != 1.0:
			%dialogue.visible_ratio = 1.0
			# show full dialogue if current dialogue isn't full
			# this enable feature of double clicking to show full dialogue
		else:
			%dialogue.visible_ratio = 0.0 
			# other wise forward to next dialogue
			proceed()
	if Input.is_action_just_pressed("auto") and check_in_game():
		# autoplay switches game to autoplay mode
		_on_auto_pressed()


func check_in_game() -> bool:
	# check if the current game should continue to next line when be clicked
	# game should onlt proceed to next line when no UI component
	# is blocking the game window
	if UI_switched:
		# prevent the bug of "extra click" after switching UI
		UI_switched = false
		return false
	if $review_dialogues.visible:
		return false
	if  self.find_child("save_load") != null:
		return false
	if self.find_child("setting_menu") != null:
		return false
	if $minigame.get_children() != []:
		return false
	if  $minigame.get_children() != []:
		return false
	return can_press


func proceed():
	# inchagre of continue the dialogue to next line
	if choice_reach:
		return
	var text = {};
	# text will be mutated each time 
	# then extract character, dialogue and command
	var status = script_tree.get_line(text) # status check special condition
	if status == "exit":
		_on_leave_pressed()
		# if exit, exit
		return
	if status == "choice reach":
		$dialogue.visible = true
		$UI.visible = true
		%dialogue.visible_ratio = 1.0
		choice_reach = true
		choice_jump()
		# if choice reached, display choice
		return
	if status == "game":
		# creator is responsible for whether to clear current music or not 
		# during minigame. as some may want music to continue playing
		speed_up = false
		auto_play = false
		$minigame.add_game(script_tree.get_game())	
		return
	# now all special condition has been considered
	
	$music.next_line() # clear respected music bus according to setting
	
	if speed_up:
		# when play in speed mode there shouldn't be typewritte effect
		%dialogue.visible_ratio = 1.0
	else:
		%dialogue.visible_ratio = 0.0
		
	if text["character"] == "":
		# creator may want to switch dialogue box style when its narration
		# instead of character speaking
		# this check by whether character has a name or not
		$dialogue/dialogue_box.visible = false
		$dialogue/narration_box.visible = true
		%dialogue.narrration = true
	else:
		$dialogue/dialogue_box.visible = true
		$dialogue/narration_box.visible = false
		%dialogue.narrration = false

	command_execute(text["command"]) 
	# execute the command with dialogue
	
	%character.text = text["character"]
	%dialogue.text = text["dialogue"]
	#change text on dialogue box to respected character and dialogue
	
	$review_dialogues.get_words(text["character"], text["dialogue"])
	$review_dialogues.add_line()
	# add character and dialogue into review_dialogue
	
	print("character ", text["character"], " is speaking script: ", text["dialogue"], "\n")
	#self.get_tree().call_group("dialogue", "_start_dialogue")
	# start playing dialogue
	%dialogue._start_dialogue() #TODO why dont I just do this?


func choice_jump():
	# used when choice is reached
	# displace choice accoring to condition or directly jump to next txt
	var choice_list = check_choice_condition(script_tree.get_choices())
	# first eliminate all choice that does not satisfy condition
	# TODO what if creator wish to display choices but as locked?
	if choice_list == []:
		# error checking code that shouldn't be triggered
		choice_reach = false
		return "fail"
	var option = preload("res://frameWorkCore/gameplay_basic/choice.tscn")
	
	for choice in choice_list:
		# instantiate and add all choices in choice list to game
		var ready_option = option.instantiate()
		%choice_box.add_child(ready_option)
		
		# TODO, these feels like shit code
		var choice_text = ready_option.get_node("center").get_node("choice_text")
		var going_to = ready_option.get_node("going_to")
		choice_text.text = choice[0]
		going_to.text = choice[1]
		ready_option.connect("travel_to", travel)
		# TODO, these feels like shit code
		
	if len(choice_list) == 1:
		# if only one option and auto jump is true， jump
		if choice_list[0][2] == "true":
			travel(choice_list[0][1])
			return "fail"
			# shit code, only purpose is to prevent jump to choice
			# from ending the game
	return "suceed"


func check_choice_condition(choices: Array):
	# filter out choice that dont satisfy condition
	var new_choices = []
	for choice in choices:
		if len(choice) <= 3:
			# if choice dont even have a condition
			new_choices.append(choice)
		else:
			if variables.var_con(choice[3], choice[4], choice[5]):
				new_choices.append(choice)
	return new_choices


func travel(location: String):
	# triggered when a choice is clicked
	script_tree.change_chapter(location)
	# TODO need to update error checker, will update in error system overhaul
	for child in %choice_box.get_children():
		# since choice is already made, remove all displayed choices
		%choice_box.remove_child(child)
		
	%dialogue.visible_ratio = 0 
	choice_reach = false
	proceed()
	# reset dialogue and start line


func command_execute(orders: Array):
	# TODO O(2n) complexity, need to try to fix in future
	%avatar.update_art_list(orders)
	# iterate the command to find all avatar slot that will be overwrite
	# these slot does not need to be cleared
	# this feature helps with avatar transition and potentialy many feature
	for order in orders:
		# iterate through orders and execure respective command
		var which_order = order[0]
		print("curr order is", which_order, "\n")
		match which_order:
			"character":
				%avatar.change_avatar(order[1], order[2], order[3], order[4])
			"background":
				%background.change_background(order[1], order[2])
			"bgm", "sound_effect", "voice":
				$music.change_music(which_order, order[1])
			"CG":
				# since cg is displayed full screen
				# all avatar are expected to be cleared
				# it should also make all UI invisible 
				# and visible after finishing displaying
				auto_play = false
				speed_up = false
				%avatar.clear_all_avatar()
				$UI.visible = false
				$dialogue.visible = false
				can_press = false
				%background.change_background(order[1], "false")
				print("displaying CG\n")
			"update":
				# update variable creater implemented
				variables.var_op(order[1], order[2], order[3])
			"chubby":
				# start a chubby play
				$chubby_play.swap(order[1])
			_:
				# currentlu, unknown command will trigger an error
				print("unknown commad ", which_order, "\n")
				self.get_tree().call_group("errorlog", "unknown_command", which_order)
	return


func load_progress(data: ProgressData):
	# load game progress into the game
	speed_up = false
	auto_play = false
	choice_reach = false
	%dialogue.on_transition = true
	for child in %choice_box.get_children():
		%choice_box.remove_child(child)
	# reset all ingame setting including removing choices
	print("loading progress\n")
	print("file is ", data.which_file, "\n")
	print("line is ", data.which_line, "\n")
	%music.music_clear("bgm")
	%music.music_clear("voice")
	%music.music_clear("sound_effect")
	%avatar.clear_all_avatar()
	$chubby_play.reset_chubby()
	script_tree.load_progress(data.which_file, data.which_line - 1)
	variables.set_all_var(data.variables)
	# script tree acc give the line after its current progress
	proceed()
	self.get_tree().call_group("main", "game_created")
	# tell main game has been created and play animation fade_out
	# TODO change that part to tween
	%dialogue.on_transition = false


func load_setting():
	# load game setting
	# TODO feels like shit code
	print("load setting!")
	$review_dialogues.visible = false
	# hard code shit, fix later
	var save = ResourceLoader.load(GlobalResources.setting_save_path)
	$dialogue/dialogue_box.modulate.a = save.dialogue_box_transparency / 100
	$dialogue/narration_box.modulate.a = save.dialogue_box_transparency / 100
	$UI/Control/ColorRect.color = save.windows_color	
# the code below are code related to buttons

func _on_save_pressed():
	var temp_screen = get_viewport().get_texture().get_image()
	# take a screenshot of current scene
	var saver:SaveLoad = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	saver.display_save = true
	saver.get_temp_save_data(temp_screen, script_tree.get_chapter(), script_tree.get_line_num(), variables)
	self.add_child(saver)
	saver.set_owner(self)
	UI_switched = true


func _on_load_pressed():
	var loader = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	loader.display_save = false
	self.add_child(loader)
	loader.set_owner(self)
	UI_switched = true


func _on_quicksave_pressed():
	# TODO, maybe make first save slot for quick save only?
	var progress:ProgressData = ProgressData.new()
	progress.which_file = script_tree.get_chapter()
	progress.which_line = script_tree.get_line_num()
	progress.variables = variables.get_all_var()
	ResourceSaver.save(progress, "user://save/quick_save.tres")


func _on_quickload_pressed():
	var quick_save = "user://save/quick_save.tres"
	var find_save:ProgressData = ResourceLoader.load(quick_save)
	if find_save == null:
		return
	print(find_save)
	self.load_progress(find_save)


func _on_setting_pressed():
	var setting = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	self.add_child(setting, true)
	setting.set_owner(self)
	UI_switched = true
	return


func _on_review_pressed():
	$review_dialogues.visible = true
	$review_dialogues.jump_to_buttom()
	$dialogue.visible = false
	$UI.visible = false
	return


func quit_review():
	$review_dialogues.visible = false
	can_press = true
	$dialogue.visible = true
	$UI.visible = true


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
	if !script_tree.has_nextchap():
		print("no choice found")
		return
	%music.music_clear("bgm")
	%music.music_clear("voice")
	%music.music_clear("sound_effect")
	%avatar.clear_all_avatar()
	script_tree.jump_choice()
	proceed()


func _on_visible_pressed():
	if $dialogue.visible and $UI.visible and $choice.visible:
		$dialogue.visible = false
		$UI.visible = false
		$choice.visible = false
		UI_visible = false
		auto_play = false


func _on_leave_pressed():
	get_tree().call_group("main", "back_menu")


func _on_button():
	print("on button\n")
	can_press = false

func _out_button():
	print("out button\n")
	can_press = true

# these 2 function prevents press action been triggered when pressing UI button


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
	# this helps with dynamic background/CG
	if $background/viedo_background.loop:
		# only dynamic bacnground will loop, we dont care in this case
		return
	# otherwise it means cg has ended and its time for next line
	$UI.visible = true
	$dialogue.visible = true
	can_press = true
	proceed()
