extends CanvasLayer
class_name SceneAuto

@onready var UI_visible = true
# when UI including dialogue box is not visible
# clicking will redisplay and will not play text

@export var press_action_disabled = false
# press action are actions that will proceed dialogue to next line
# when true, player cannot proceed to next line with press action

# anti-reentry lock for auto_play_timer: converts the per-frame
# "visible_ratio == 1.0" level signal into a single edge trigger so
# the timer is only started once per line during AUTOPLAY
@onready var start_time = true

@onready var dialogue_UI: CanvasLayer = $dialogue
@onready var narration_box: TextureRect = $dialogue/narration_box
@onready var dialogue_box: TextureRect = $dialogue/dialogue_box
@onready var ui: CanvasLayer = $UI

var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
# where dialogue and command are stored

# store inital variable to temporary variables used for this game
var variables: Variables = Variables.new()

enum GameState{
	DEFAULT,
	AUTOPLAY,
	SPEEDUP,
	PAUSED
}

var curr_state:GameState = GameState.DEFAULT

func _ready():
	var saved_variables:Variables = ResourceLoader.load(GlobalResources.variables_path)
	variables = saved_variables.duplicate(true)
	$error_log.hide()
	$review_dialogues.hide()
	%dialogue.text = ""
	%character.text = ""
	%dialogue.visible_ratio = 0.0
	%errorlog.text = ""
	$review_dialogues.connect("close", _on_quit_review_dialogue)
	$story_tree.connect("close", _on_quit_story_tree)
	$story_tree.connect("load_chap", load_chapter_from_story_tree)
	$story_tree.update_chapter("Start.txt")
	GlobalSignals.close_ui.connect(_on_ui_closed)
	GlobalSignals.pause_game_interaction.connect(_on_pause_game_interaction)
	GlobalSignals.unpause_game_interaction.connect(_on_unpause_game_interaction)
	GlobalSignals.minigame_edit_var.connect(_on_var_edited)
	set_bus()
	load_setting()
	var setting = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	$".".add_child(setting, true)
	setting.queue_free()
	#add setting once to load values
	#TODO this is a temporary solution
	GlobalSignals.game_created.emit()
	# tell main scene game is created

func _on_var_edited(new_variable: Variables):
	variables = new_variable.duplicate(true)

func set_bus():
	# set all audio to respective bus
	for bgm in self.find_child("music").find_child("bgm").get_children():
		bgm.set_bus("bgm")
	for voice in self.find_child("music").find_child("voice").get_children():
		voice.set_bus("voice")
	for sfx in self.find_child("music").find_child("sound_effect").get_children():
		sfx.set_bus("sound_effect")

	
func _on_ui_closed():
	curr_state = GameState.DEFAULT


func _on_ui_opened():
	curr_state = GameState.PAUSED


func _on_pause_game_interaction():
	curr_state = GameState.PAUSED
	$auto_play_timer.stop()
	$speed_up_timer.stop()
	start_time = true
	%dialogue.on_auto = false
	ui.hide()
	dialogue_UI.hide()
	%dialogue.set_process(false)
	%avatar.visible = false

	
func _on_unpause_game_interaction():
	curr_state = GameState.DEFAULT
	%dialogue.set_process(true)
	ui.show()
	dialogue_UI.show()
	%avatar.visible = true


func _process(_delta):
	if curr_state == GameState.AUTOPLAY and %dialogue.visible_ratio == 1.0 and start_time:
		start_time = false
		$auto_play_timer.start()
		# TODO surely logic in here can be moved else where
		# if dialogue has reached its end during autoplay state
		# start time which proceed to next line after timeout


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("press") and check_in_game():
		match curr_state:
			GameState.PAUSED:
				# paused by background transition or similar; press does nothing
				return
			GameState.AUTOPLAY:
				# press stops autoplay but does not advance to next line
				curr_state = GameState.DEFAULT
				%dialogue.on_auto = false
				$auto_play_timer.stop()
				start_time = true
				return
			GameState.SPEEDUP:
				# press stops speedup but does not advance to next line
				curr_state = GameState.DEFAULT
				$speed_up_timer.stop()
				return
			GameState.DEFAULT:
				$dialogue.visible = true
				$UI.visible = true
				$choice.visible = true
				if not UI_visible:
					# redisplay hidden UI
					UI_visible = true
					return
				if %dialogue.visible_ratio != 1.0:
					# show full dialogue if current dialogue isn't full
					%dialogue.visible_ratio = 1.0
				else:
					# otherwise forward to next dialogue
					%dialogue.visible_ratio = 0.0
					proceed_to_next_line()
	if Input.is_action_just_pressed("auto") and check_in_game():
		# autoplay switches game to autoplay mode
		_on_start_auto_play()


func check_in_game() -> bool:
	# check if the current game should continue to next line when be clicked
	# game should onlt proceed to next line when no UI component
	# is blocking the game window
	if $review_dialogues.visible:
		return false
	if $story_tree.visible:
		return false
	if  self.find_child("save_load") != null:
		return false
	if self.find_child("setting_menu") != null:
		return false
	if $minigame.get_children() != []:
		return false
	if  $minigame.get_children() != []:
		return false
	return !press_action_disabled


func proceed_to_next_line():
	# inchagre of continue the dialogue to next line
	if press_action_disabled:
		return
	if curr_state == GameState.PAUSED:
		return
	%avatar.finish_avatar_effects()
	var text = {};
	# text will be mutated each time 
	# then extract character, dialogue and command
	var status = script_tree.get_line(text) # status check special condition
	if status == "exit":
		_on_leave_game()
		# if exit, exit
		return
	if status == "choice reach":
		$dialogue.show()
		$UI.show()
		%dialogue.visible_ratio = 1.0
		curr_state = GameState.PAUSED
		choice_jump()
		# if choice reached, display choice
		return
	if status == "game":
		# creator is responsible for whether to clear current music or not 
		# during minigame. as some may want music to continue playing
		curr_state = GameState.PAUSED
		$auto_play_timer.stop()
		$speed_up_timer.stop()
		start_time = true
		%dialogue.on_auto = false
		GlobalMinigameInteractior.set_variable(variables)
		$minigame.add_game(script_tree.get_game())	
		return
	# now all special condition has been considered
	
	$music.next_line() # clear respected music bus according to setting
	
	if curr_state == GameState.SPEEDUP:
		# when play in speed mode there shouldn't be typewritte effect
		%dialogue.visible_ratio = 1.0
	else:
		%dialogue.visible_ratio = 0.0
		
	if text["character"] == "":
		# creator may want to switch dialogue box style when its narration
		# instead of character speaking
		# this check by whether character has a name or not
		narration_box.show()
		dialogue_box.hide()
		%dialogue.on_narration()
	else:
		narration_box.hide()
		dialogue_box.show()
		%dialogue.on_dialogue()
	press_action_disabled = true
	command_execute(text["command"]) 
	press_action_disabled = false
	# execute the command with dialogue
	%character.text = text["character"]
	%dialogue.text = text["dialogue"]
	#change text on dialogue box to respected character and dialogue
	$review_dialogues.get_words(text["character"], text["dialogue"])
	$review_dialogues.add_line()
	# add character and dialogue into review_dialogue
	print("character ", text["character"], " is speaking script: ", text["dialogue"], "\n")
	%dialogue.start_dialogue()


func choice_jump():
	# used when choice is reached
	# displace choice accoring to condition or directly jump to next txt
	var choice_list = check_choice_condition(script_tree.get_choices())
	# first eliminate all choice that does not satisfy condition
	# TODO what if creator wish to display choices but as locked?
	if choice_list == []:
		# error checking code that shouldn't be triggered
		curr_state = GameState.DEFAULT
		return "fail"
	var option = preload("res://frameWorkCore/gameplay_basic/choice.tscn")
	
	for choice in choice_list:
		# instantiate and add all choices in choice list to game
		var ready_option:Choice = option.instantiate()
		ready_option.choice_description = choice[0]
		ready_option.travel_chapter = choice[1]
		%choice_box.add_child(ready_option)
		ready_option.travel_to_new_chap.connect(travel_to_new_chapter)
		
	if len(choice_list) == 1:
		# if only one option and auto jump is true， jump
		if choice_list[0][2] == "true":
			travel_to_new_chapter(choice_list[0][1])
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


func travel_to_new_chapter(location: String):
	# triggered when a choice is clicked
	$story_tree.update_chapter(location)
	script_tree.change_chapter(location)
	# TODO need to update error checker, will update in error system overhaul
	for child in %choice_box.get_children():
		# since choice is already made, remove all displayed choices
		%choice_box.remove_child(child)
		
	%dialogue.visible_ratio = 0
	curr_state = GameState.DEFAULT
	proceed_to_next_line()
	# reset dialogue and start line


func command_execute(orders: Dictionary):
	%avatar.update_art_list(orders.get("character", []))
	%avatar.change_avatars(orders.get("character", []))
	%avatar.execute_avatar_effects(orders.get("effect", []))
	
	%background.change_backgrounds(orders.get("background", []))
	
	$chubby_play.process_chubby_commands(orders.get("chubby", []))
	
	%music.change_bgm(orders.get("bgm", []))
	%music.change_sound_effect(orders.get("sound_effect", []))
	%music.change_voice(orders.get("voice", []))
	
	variables.perform_var_ops(orders.get("update", []))
		
	if orders.has("CG"):
		curr_state = GameState.DEFAULT
		$auto_play_timer.stop()
		$speed_up_timer.stop()
		start_time = true
		%dialogue.on_auto = false
		%avatar.clear_all_avatar()
		$UI.visible = false
		$dialogue.visible = false
		press_action_disabled = true
		%background.change_backgrounds(orders["CG"][0][0], "false")
		print("displaying CG\n")
	return
	
	
func load_chapter_from_story_tree(chapter_name: String, variable_of_chap: Dictionary):
	$story_tree.hide()
	var chap:CurrGameProgress = CurrGameProgress.new()
	chap.which_file = chapter_name
	var saved_variables:Variables = ResourceLoader.load(GlobalResources.variables_path)
	chap.variables = saved_variables.duplicate(true)
	for key in variable_of_chap.keys():
		chap.variables.variables[key] = variable_of_chap[key]
	GlobalSignals.load_game_progress.emit(chap)
	pass


func load_progress(data: CurrGameProgress):
	# load game progress into the game
	curr_state = GameState.DEFAULT
	$auto_play_timer.stop()
	$speed_up_timer.stop()
	start_time = true
	%dialogue.on_auto = false
	for child in %choice_box.get_children():
		%choice_box.remove_child(child)
	# reset all ingame setting including removing choices
	print("loading progress\n")
	print("file is ", data.which_file, "\n")
	print("line is ", data.which_line, "\n")
	%music.music_clear("bgm")
	%music.music_clear("voice")
	%music.music_clear("sound_effect")
	%background.clear_background()
	%avatar.clear_all_avatar()
	$chubby_play.reset_chubby()
	script_tree.load_progress(data.which_file, data.which_line)
	variables = data.variables.duplicate(true)
	# script tree acc give the line after its current progress
	$UI.show()
	$dialogue.show()
	GlobalSignals.game_created.emit()
	
	# tell main game has been created and play animation fade_out


func load_setting():
	# load game setting
	# TODO feels like shit code
	print("load setting!")
	$review_dialogues.visible = false
	# hard code shit, fix later
	var save:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	$dialogue/dialogue_box.modulate.a = save.dialogue_box_transparency / 100
	$dialogue/narration_box.modulate.a = save.dialogue_box_transparency / 100
	$UI/Control/ColorRect.color = save.windows_color	
# the code below are code related to buttons

func _on_show_save():
	curr_state = GameState.PAUSED
	var temp_screen = get_viewport().get_texture().get_image()
	# take a screenshot of current scene
	var saver:SaveLoad = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	saver.display_save = true
	saver.get_temp_save_data(temp_screen, script_tree.get_chapter(), script_tree.get_line_num(), variables)
	add_sibling(saver)


func _on_show_load():
	curr_state = GameState.PAUSED
	var loader:SaveLoad = preload("res://frameWorkCore/load_save/save_load_UI.tscn").instantiate()
	loader.display_save = false
	add_sibling(loader)


func _on_quick_save():
	var progress:CurrGameProgress = CurrGameProgress.new()
	progress.which_file = script_tree.get_chapter()
	progress.which_line = script_tree.get_line_num() - 1
	progress.variables = variables.get_all_var()
	ResourceSaver.save(progress, "user://save/quick_save.tres")


func _on_quick_load():
	var quick_save = "user://save/quick_save.tres"
	var find_save:CurrGameProgress = ResourceLoader.load(quick_save)
	if find_save == null:
		return
	GlobalSignals.load_game_progress.emit(find_save)


func _on_show_setting():
	curr_state = GameState.PAUSED
	var setting:SettingMenu = preload("res://frameWorkCore/settings/setting_menu.tscn").instantiate()
	self.add_child(setting, true)
	setting.set_owner(self)
	setting.reload_setting.connect(load_setting)
	return


func _on_show_review_dialogue():
	curr_state = GameState.PAUSED
	$review_dialogues.jump_to_buttom()
	$review_dialogues.show()
	$dialogue.hide()
	$UI.hide()
	return


func _on_quit_review_dialogue():
	$review_dialogues.hide()
	press_action_disabled = false
	curr_state = GameState.DEFAULT
	$dialogue.show()
	$UI.show()


func _on_show_story_tree():
	curr_state = GameState.PAUSED
	$story_tree.show()
	$dialogue.hide()
	$UI.hide()
	return


func _on_quit_story_tree():
	$story_tree.hide()
	press_action_disabled = false
	curr_state = GameState.DEFAULT
	$dialogue.show()
	$UI.show()


func _on_start_auto_play():
	if curr_state == GameState.AUTOPLAY:
		curr_state = GameState.DEFAULT
		%dialogue.on_auto = false
		return
		# cancel auto play if already autoplaying
	curr_state = GameState.AUTOPLAY
	%dialogue.on_auto = true
	proceed_to_next_line()


func _on_start_fast_forward():
	if curr_state == GameState.SPEEDUP:
		curr_state = GameState.DEFAULT
		return
	curr_state = GameState.SPEEDUP
	proceed_to_next_line()
	$speed_up_timer.start()


func _on_start_fast_forward_to_next_choice():
	if curr_state == GameState.PAUSED:
		return
	if !script_tree.has_nextchap():
		print("no choice found")
		return
	%music.music_clear("bgm")
	%music.music_clear("voice")
	%music.music_clear("sound_effect")
	%avatar.clear_all_avatar()
	script_tree.jump_choice()
	proceed_to_next_line()


func _on_hide_UI():
	if $dialogue.visible and $UI.visible and $choice.visible:
		$dialogue.hide()
		$UI.hide()
		$choice.hide()
		UI_visible = false
		curr_state = GameState.DEFAULT
		$auto_play_timer.stop()
		$speed_up_timer.stop()
		start_time = true
		%dialogue.on_auto = false


func _on_leave_game():
	GlobalSignals.back_to_menu.emit()


func _on_button():
	press_action_disabled = true
	

func _out_button():
	press_action_disabled = false

# these 2 function prevents press action been triggered when pressing UI button
func _on_auto_play_timer_timeout():
	start_time = true
	if curr_state == GameState.AUTOPLAY:
		# display next dialogue when time up
		proceed_to_next_line()


func _on_speed_up_timer_timeout():
	if curr_state == GameState.SPEEDUP:
		proceed_to_next_line()
		$speed_up_timer.start()


func _on_video_background_finished():
	# this helps with dynamic background/CG
	if $background/video_background.loop:
		# if the background is looping, we dont care in this case
		return
	# otherwise it means cg or dynamic background has ended 
	# and its time for next line
	$UI.show()
	$dialogue.show()
	press_action_disabled = false
	proceed_to_next_line()
