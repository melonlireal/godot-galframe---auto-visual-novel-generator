extends CanvasLayer
class_name SceneAuto

# press_action_disabled 已移至 main_UI（ui.is_press_disabled() / ui.set_press_disabled()）

@onready var dialogue_controller: DialogueController = $dialogue_controller
@onready var ui: CanvasLayer = $UI
@onready var avatar: CanvasLayer = $avatar
@onready var choice_controller: ChoiceController = $ChoiceController
@onready var review_dialogues: ReviewDialogues = $review_dialogues
@onready var story_tree: StoryTree = $story_tree
@onready var minigame: CanvasLayer = $minigame
@onready var music: Node = %music
@onready var background: CanvasLayer = %background
@onready var chubby_play: CanvasLayer = $chubby_play
@onready var error_log: CanvasLayer = $error_log
@onready var errorlog: Label = %errorlog
@onready var video_background: VideoStreamPlayer = $background/video_background


var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
# where dialogue and command are stored

# store inital variable to temporary variables used for this game
var variables: Variables = Variables.new()

var curr_state: GlobalType.GameState:
	get:
		return dialogue_controller.get_state()
	set(value):
		dialogue_controller.set_state(value)

func _ready():
	var saved_variables:Variables = ResourceLoader.load(GlobalResources.variables_path)
	variables = saved_variables.duplicate(true)
	error_log.hide()
	review_dialogues.hide()
	errorlog.text = ""
	story_tree.connect("load_chap", load_chapter_from_story_tree)
	story_tree.update_chapter("Start.txt")
	GlobalSignals.close_ui.connect(_on_ui_closed)
	GlobalSignals.pause_game_interaction.connect(_on_pause_game_interaction)
	GlobalSignals.unpause_game_interaction.connect(_on_unpause_game_interaction)
	GlobalSignals.minigame_edit_var.connect(_on_var_edited)
	choice_controller.chapter_changed.connect(_on_chapter_changed)
	choice_controller.script_tree = script_tree
	load_setting()
	GlobalSignals.game_created.emit()
	# tell main scene game is created

func _on_var_edited(new_variable: Variables):
	variables = new_variable.duplicate(true)


func _on_ui_closed():
	curr_state = GlobalType.GameState.DEFAULT


func _on_pause_game_interaction():
	curr_state = GlobalType.GameState.PAUSED
	dialogue_controller.pause_interaction()
	ui.hide()
	dialogue_controller.hide()
	avatar.visible = false


func _on_unpause_game_interaction():
	curr_state = GlobalType.GameState.DEFAULT
	dialogue_controller.resume_interaction()
	ui.show()
	dialogue_controller.show()
	avatar.visible = true




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("press") and check_in_game():
		match curr_state:
			GlobalType.GameState.PAUSED:
				# paused by background transition or similar; press does nothing
				return
			GlobalType.GameState.AUTOPLAY:
				# press stops autoplay but does not advance to next line
				curr_state = GlobalType.GameState.DEFAULT
				dialogue_controller.cancel_autoplay()
				return
			GlobalType.GameState.SPEEDUP:
				# press stops speedup but does not advance to next line
				curr_state = GlobalType.GameState.DEFAULT
				dialogue_controller.stop_speedup()
				return
			GlobalType.GameState.DEFAULT:
				dialogue_controller.show()
				ui.visible = true
				choice_controller.visible = true
				if not ui.is_ui_visible():
					# redisplay hidden UI
					ui.set_ui_visible(true)
					return
				if dialogue_controller.is_playing():
					# show full dialogue if current dialogue isn't full
					dialogue_controller.show_full()
				else:
					# otherwise forward to next dialogue
					proceed_to_next_line()
	if Input.is_action_just_pressed("auto") and check_in_game():
		# autoplay switches game to autoplay mode
		_on_start_auto_play()


func check_in_game() -> bool:
	# check if the current game should continue to next line when be clicked
	# game should onlt proceed to next line when no UI component
	# is blocking the game window
	if review_dialogues.visible:
		return false
	if story_tree.visible:
		return false
	if minigame.get_children() != []:
		return false
	return !ui.is_press_disabled()


func proceed_to_next_line():
	# inchagre of continue the dialogue to next line
	if ui.is_press_disabled():
		return
	if curr_state == GlobalType.GameState.PAUSED:
		return
	avatar.finish_avatar_effects()
	var text = {};
	# text will be mutated each time
	# then extract character, dialogue and command
	var status = script_tree.get_line(text) # status check special condition
	if status == "exit":
		_on_leave_game()
		# if exit, exit
		return
	if status == "choice reach":
		dialogue_controller.show()
		ui.show()
		curr_state = GlobalType.GameState.PAUSED
		if not choice_controller.choice_jump(variables):
			curr_state = GlobalType.GameState.DEFAULT
		# if choice reached, display choice
		return
	if status == "game":
		# creator is responsible for whether to clear current music or not
		# during minigame. as some may want music to continue playing
		curr_state = GlobalType.GameState.PAUSED
		dialogue_controller.pause_interaction()
		GlobalMinigameInteractior.set_variable(variables)
		minigame.add_game(script_tree.get_game())
		return
	# now all special condition has been considered

	music.next_line() # clear respected music bus according to setting

	ui.set_press_disabled(true)
	command_execute(text["command"])
	ui.set_press_disabled(false)
	# execute the command with dialogue
	#change text on dialogue box to respected character and dialogue
	review_dialogues.get_words(text["character"], text["dialogue"])
	review_dialogues.add_line()
	# add character and dialogue into review_dialogue
	print("character ", text["character"], " is speaking script: ", text["dialogue"], "\n")
	# 启动打字机播放（时长由 controller 根据状态和设置计算）
	dialogue_controller.play_line(text["character"], text["dialogue"], _get_voicing_time())


func _on_chapter_changed(location: String):
	# ChoiceController 切章后的副作用：更新 story_tree 并推进下一行
	# choice_controller 已做 script_tree.change_chapter，这里只更新 story_tree
	story_tree.update_chapter(location)
	curr_state = GlobalType.GameState.DEFAULT
	proceed_to_next_line()


# minigame 结束后切章：完整切章流程（script_tree + story_tree + 推进）
func travel_to_chapter(location: String):
	story_tree.update_chapter(location)
	script_tree.change_chapter(location)
	curr_state = GlobalType.GameState.DEFAULT
	proceed_to_next_line()


func command_execute(orders: Dictionary):
	avatar.update_art_list(orders.get("character", []))
	avatar.change_avatars(orders.get("character", []))
	avatar.execute_avatar_effects(orders.get("effect", []))
	
	background.change_backgrounds(orders.get("background", []))

	chubby_play.process_chubby_commands(orders.get("chubby", []))

	music.change_bgm(orders.get("bgm", []))
	music.change_sound_effect(orders.get("sound_effect", []))
	music.change_voice(orders.get("voice", []))
	
	variables.perform_var_ops(orders.get("update", []))
		
	if orders.has("CG"):
		curr_state = GlobalType.GameState.DEFAULT
		dialogue_controller.pause_interaction()
		avatar.clear_all_avatar()
		ui.visible = false
		dialogue_controller.visible = false
		ui.set_press_disabled(true)
		background.change_backgrounds(orders["CG"][0][0], "false")
		print("displaying CG\n")
	return


# 获取当前行配音时长，供 dialogue_controller 计算 AUTOPLAY 句间等待用
func _get_voicing_time() -> float:
	return music.last_voice_duration


func load_chapter_from_story_tree(chapter_name: String, variable_of_chap: Dictionary):
	story_tree.hide()
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
	curr_state = GlobalType.GameState.DEFAULT
	dialogue_controller.pause_interaction()
	choice_controller.clear_choices()
	# reset all ingame setting including removing choices
	print("loading progress\n")
	print("file is ", data.which_file, "\n")
	print("line is ", data.which_line, "\n")
	music.music_clear("bgm")
	music.music_clear("voice")
	music.music_clear("sound_effect")
	background.clear_background()
	avatar.clear_all_avatar()
	choice_controller.clear_choices()
	chubby_play.reset_chubby()
	script_tree.load_progress(data.which_file, data.which_line)
	variables = data.variables.duplicate(true)
	# script tree acc give the line after its current progress
	ui.show()
	dialogue_controller.show()
	GlobalSignals.game_created.emit()

	# tell main game has been created and play animation fade_out


func load_setting():
	# load game setting
	print("load setting!")
	review_dialogues.visible = false
	var save:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	dialogue_controller.set_box_opacity(save.dialogue_box_transparency / 100)
	ui.apply_windows_color(save.windows_color)
	# 应用音量到 AudioServer
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(save.total_volumn))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"), linear_to_db(save.bgm_volumn))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("voice"), linear_to_db(save.voice_volumn))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear_to_db(save.sfx_volumn))
# the code below are code related to buttons

func _on_quick_save():
	var progress:CurrGameProgress = CurrGameProgress.new()
	progress.which_file = script_tree.get_chapter()
	progress.which_line = script_tree.get_line_num() - 1
	progress.variables = variables.duplicate(true)
	ResourceSaver.save(progress, "user://save/quick_save.tres")


func _on_quick_load():
	var quick_save = "user://save/quick_save.tres"
	var find_save:CurrGameProgress = ResourceLoader.load(quick_save)
	if find_save == null:
		return
	GlobalSignals.load_game_progress.emit(find_save)


func _on_start_auto_play():
	if curr_state == GlobalType.GameState.AUTOPLAY:
		curr_state = GlobalType.GameState.DEFAULT
		dialogue_controller.cancel_autoplay()
		return
		# cancel auto play if already autoplaying
	curr_state = GlobalType.GameState.AUTOPLAY
	proceed_to_next_line()


func _on_start_fast_forward():
	if curr_state == GlobalType.GameState.SPEEDUP:
		curr_state = GlobalType.GameState.DEFAULT
		return
	curr_state = GlobalType.GameState.SPEEDUP
	proceed_to_next_line()
	dialogue_controller.start_speedup()


func _on_start_fast_forward_to_next_choice():
	if curr_state == GlobalType.GameState.PAUSED:
		return
	if !script_tree.has_nextchap():
		print("no choice found")
		return
	music.music_clear("bgm")
	music.music_clear("voice")
	music.music_clear("sound_effect")
	avatar.clear_all_avatar()
	script_tree.jump_choice()
	proceed_to_next_line()


func _on_leave_game():
	GlobalSignals.back_to_menu.emit()


func _on_auto_play_timer_timeout():
	if curr_state == GlobalType.GameState.AUTOPLAY:
		# display next dialogue when time up
		proceed_to_next_line()


func _on_speed_up_timer_timeout():
	if curr_state == GlobalType.GameState.SPEEDUP:
		proceed_to_next_line()
		dialogue_controller.start_speedup()


func _on_video_background_finished():
	# this helps with dynamic background/CG
	if video_background.loop:
		# if the background is looping, we dont care in this case
		return
	# otherwise it means cg or dynamic background has ended 
	# and its time for next line
	ui.show()
	dialogue_controller.show()
	ui.set_press_disabled(false)
	proceed_to_next_line()
