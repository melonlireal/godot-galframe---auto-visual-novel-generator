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
@onready var scene_transition: CanvasLayer = %scene_transition
@onready var chubby_play: CanvasLayer = $chubby_play
@onready var error_log: CanvasLayer = $error_log
@onready var errorlog: Label = %errorlog
@onready var video_background: VideoStreamPlayer = $background/video_background
@onready var auto_play_timer: Timer = $auto_play_timer
@onready var speed_up_timer: Timer = $speed_up_timer


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
	video_background.finished.connect(_on_video_background_finished)
	ui.leave_game.connect(_on_leave_game)
	ui.quick_load.connect(_on_quick_load)
	ui.quick_save.connect(_on_quick_save)
	ui.start_auto_play.connect(_on_start_auto_play)
	ui.start_fast_forward.connect(_on_start_fast_forward)
	ui.start_fast_forward_to_next_choice.connect(_on_start_fast_forward_to_next_choice)
	auto_play_timer.timeout.connect(_on_auto_play_timer_timeout)
	speed_up_timer.timeout.connect(_on_speed_up_timer_timeout)
	var saved_variables:Variables = ResourceLoader.load(GlobalResources.variables_path)
	variables = saved_variables.duplicate(true)
	error_log.hide()
	review_dialogues.hide()
	errorlog.text = ""
	story_tree.connect("load_chap", load_chapter_from_story_tree)
	story_tree.update_chapter("Start.txt")
	GlobalSignals.pause_game_interaction.connect(_on_pause_game_interaction)
	GlobalSignals.unpause_game_interaction.connect(_on_unpause_game_interaction)
	GlobalSignals.ui_opened.connect(_on_ui_opened)
	GlobalSignals.ui_closed.connect(_on_ui_closed)
	GlobalSignals.play_next_line.connect(proceed_to_next_line)
	GlobalSignals.reload_setting.connect(load_setting)
	GlobalSignals.minigame_edit_var.connect(_on_var_edited)
	choice_controller.chapter_changed.connect(_on_chapter_changed)
	choice_controller.script_tree = script_tree
	load_setting()

func _on_var_edited(new_variable: Variables) -> void:
	variables = new_variable.duplicate(true)


var prev_state: GlobalType.GameState = GlobalType.GameState.DEFAULT
var pending_voice: Array[Array] = []
var pending_line: Array = []


func _on_pause_game_interaction() -> void:
	if curr_state != GlobalType.GameState.TRANSITION:
		prev_state = curr_state
	curr_state = GlobalType.GameState.TRANSITION
	dialogue_controller.pause_interaction()
	avatar.visible = false


func _on_unpause_game_interaction() -> void:
	curr_state = prev_state
	dialogue_controller.resume_interaction()
	avatar.visible = true
	if not pending_line.is_empty():
		music.change_voice(pending_voice)
		var line: Array = pending_line
		pending_voice = []
		pending_line = []
		dialogue_controller.play_line(line[0], line[1], _get_voicing_time())


func _on_ui_opened() -> void:
	prev_state = curr_state
	curr_state = GlobalType.GameState.UI_OPEN


func _on_ui_closed() -> void:
	curr_state = prev_state




func _input(event: InputEvent) -> void:
	if event.is_action_pressed("press"):
		if curr_state == GlobalType.GameState.SHOWING_CG:
			curr_state = prev_state
			ui.show()
			dialogue_controller.show()
			ui.set_press_disabled(false)
			proceed_to_next_line()
			return
		if curr_state != GlobalType.GameState.UI_OPEN:
			match curr_state:
				GlobalType.GameState.PAUSED:
					# paused by choice/minigame; press does nothing
					return
				GlobalType.GameState.TRANSITION:
					# background transition in progress; press does nothing
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
	if Input.is_action_just_pressed("auto") and curr_state != GlobalType.GameState.UI_OPEN:
		# autoplay switches game to autoplay mode
		_on_start_auto_play()


func proceed_to_next_line() -> void:
	# inchagre of continue the dialogue to next line
	if ui.is_press_disabled():
		return
	if curr_state == GlobalType.GameState.PAUSED:
		return
	avatar.finish_avatar_effects()
	var text: Dictionary = {};
	# text will be mutated each time
	# then extract character, dialogue and command
	var status: GlobalType.LineStatus = script_tree.get_line(text)
	if status == GlobalType.LineStatus.EXIT:
		_on_leave_game()
		return
	if status == GlobalType.LineStatus.CHOICE:
		dialogue_controller.show()
		ui.show()
		curr_state = GlobalType.GameState.PAUSED
		if not choice_controller.choice_jump(variables):
			curr_state = GlobalType.GameState.DEFAULT
		return
	if status == GlobalType.LineStatus.GAME:
		# creator is responsible for whether to clear current music or not
		# during minigame. as some may want music to continue playing
		curr_state = GlobalType.GameState.PAUSED
		dialogue_controller.pause_interaction()
		GlobalMinigameInteractior.set_variable(variables)
		minigame.add_game(script_tree.get_game())
		return
	# now all special condition has been considered

	music.next_line() # clear respected music bus according to setting

	# 转场中：背景/立绘/bgm 照常在黑屏下执行，voice 和台词延后到淡入结束再播
	var in_transition: bool = curr_state == GlobalType.GameState.TRANSITION
	var voice_orders: Array = text["command"].get(GlobalType.COMMAND_VOICE, [])
	if in_transition and not voice_orders.is_empty():
		text["command"].erase(GlobalType.COMMAND_VOICE)

	ui.set_press_disabled(true)
	command_execute(text["command"])
	ui.set_press_disabled(false)
	# execute the command with the dialogue
	#change text on dialogue box to respected character and dialogue
	review_dialogues.get_words(text["character"], text["dialogue"])
	if not voice_orders.is_empty():
		review_dialogues.get_voice(voice_orders[0][0])
	review_dialogues.add_line()
	# add character and dialogue into review_dialogue
	print("character ", text["character"], " is speaking script: ", text["dialogue"], "\n")
	if in_transition:
		pending_voice = voice_orders
		pending_line = [text["character"], text["dialogue"]]
		return
	# 启动打字机播放（时长由 controller 根据状态和设置计算）
	dialogue_controller.play_line(text["character"], text["dialogue"], _get_voicing_time())


func _on_chapter_changed(location: String) -> void:
	# ChoiceController 切章后的副作用：更新 story_tree 并推进下一行
	# choice_controller 已做 script_tree.change_chapter，这里只更新 story_tree
	story_tree.update_chapter(location)
	curr_state = GlobalType.GameState.DEFAULT
	proceed_to_next_line()


# minigame 结束后切章：完整切章流程（script_tree + story_tree + 推进）
func travel_to_chapter(location: String) -> void:
	story_tree.update_chapter(location)
	script_tree.change_chapter(location)
	curr_state = GlobalType.GameState.DEFAULT
	proceed_to_next_line()


func command_execute(orders: Dictionary) -> void:
	avatar.update_art_list(orders.get(GlobalType.COMMAND_CHARACTER, []))
	avatar.change_avatars(orders.get(GlobalType.COMMAND_CHARACTER, []))
	avatar.execute_avatar_effects(orders.get(GlobalType.COMMAND_EFFECT, []))

	background.change_backgrounds(orders.get(GlobalType.COMMAND_BACKGROUND, []))
	scene_transition.execute_transition(orders.get(GlobalType.COMMAND_SCENE_TRANSITION, []))

	chubby_play.process_chubby_commands(orders.get(GlobalType.COMMAND_CHUBBY, []))

	music.change_bgm(orders.get(GlobalType.COMMAND_BGM, []))
	music.change_sound_effect(orders.get(GlobalType.COMMAND_SOUND_EFFECT, []))
	music.change_voice(orders.get(GlobalType.COMMAND_VOICE, []))

	variables.perform_var_ops(orders.get(GlobalType.COMMAND_UPDATE, []))

	if orders.has(GlobalType.COMMAND_CG):
		if curr_state != GlobalType.GameState.TRANSITION and curr_state != GlobalType.GameState.SHOWING_CG:
			prev_state = curr_state
		curr_state = GlobalType.GameState.SHOWING_CG
		dialogue_controller.pause_interaction()
		avatar.clear_all_avatar()
		ui.visible = false
		dialogue_controller.visible = false
		ui.set_press_disabled(true)
		background.change_backgrounds([[orders[GlobalType.COMMAND_CG][0][0], "false"]])
		print("displaying CG\n")
	return


# 获取当前行配音时长，供 dialogue_controller 计算 AUTOPLAY 句间等待用
func _get_voicing_time() -> float:
	return music.last_voice_duration


func load_chapter_from_story_tree(chapter_name: String, variable_of_chap: Dictionary) -> void:
	UIManager.close(UIManager.UI.STORY_TREE)
	var chap:CurrGameProgress = CurrGameProgress.new()
	chap.which_file = chapter_name
	var saved_variables:Variables = ResourceLoader.load(GlobalResources.variables_path)
	chap.variables = saved_variables.duplicate(true)
	for key in variable_of_chap.keys():
		chap.variables.variables[key] = variable_of_chap[key]
	GlobalSignals.load_game_progress.emit(chap)


func load_progress(data: CurrGameProgress) -> void:
	curr_state = GlobalType.GameState.DEFAULT
	dialogue_controller.pause_interaction()
	choice_controller.clear_choices()
	print("loading progress\n")
	print("file is ", data.which_file, "\n")
	print("line is ", data.which_line, "\n")
	music.music_clear("bgm")
	music.music_clear("voice")
	music.music_clear("sound_effect")
	background.clear_background()
	avatar.clear_all_avatar()
	chubby_play.reset_chubby()
	script_tree.load_progress(data.which_file, data.which_line)
	variables = data.variables.duplicate(true)
	ui.show()
	dialogue_controller.show()
	ui.set_press_disabled(false)
	GlobalSignals.game_created.emit()


func load_setting() -> void:
	# load game setting
	print("load setting!")
	review_dialogues.visible = false
	var save:PlayerSetting = ResourceLoader.load(GlobalResources.setting_save_path)
	dialogue_controller.set_box_opacity(save.dialogue_box_transparency / 100)
	ui.apply_windows_color(save.windows_color)
	# 应用音量到 AudioServer
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(save.total_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("bgm"), linear_to_db(save.bgm_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("voice"), linear_to_db(save.voice_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear_to_db(save.sfx_volume))
# the code below are code related to buttons

func _on_quick_save() -> void:
	var progress:CurrGameProgress = CurrGameProgress.new()
	progress.which_file = script_tree.get_chapter()
	progress.which_line = script_tree.get_line_num() - 1
	progress.variables = variables.duplicate(true)
	ResourceSaver.save(progress, "user://save/quick_save.tres")


func _on_quick_load() -> void:
	var quick_save: String = "user://save/quick_save.tres"
	var find_save:CurrGameProgress = ResourceLoader.load(quick_save)
	if find_save == null:
		return
	GlobalSignals.load_game_progress.emit(find_save)


func _on_start_auto_play() -> void:
	if curr_state == GlobalType.GameState.PAUSED or curr_state == GlobalType.GameState.TRANSITION:
		return
	if curr_state == GlobalType.GameState.AUTOPLAY:
		curr_state = GlobalType.GameState.DEFAULT
		dialogue_controller.cancel_autoplay()
		return
		# cancel auto play if already autoplaying
	curr_state = GlobalType.GameState.AUTOPLAY
	proceed_to_next_line()


func _on_start_fast_forward() -> void:
	if curr_state == GlobalType.GameState.PAUSED or curr_state == GlobalType.GameState.TRANSITION:
		return
	if curr_state == GlobalType.GameState.SPEEDUP:
		curr_state = GlobalType.GameState.DEFAULT
		return
	curr_state = GlobalType.GameState.SPEEDUP
	proceed_to_next_line()
	dialogue_controller.start_speedup()


func _on_start_fast_forward_to_next_choice() -> void:
	if curr_state == GlobalType.GameState.PAUSED or curr_state == GlobalType.GameState.TRANSITION:
		return
	if !script_tree.has_nextchap():
		print("no choice found")
		return
	curr_state = GlobalType.GameState.DEFAULT
	music.music_clear("bgm")
	music.music_clear("voice")
	music.music_clear("sound_effect")
	avatar.clear_all_avatar()
	script_tree.jump_choice()
	proceed_to_next_line()


func _on_leave_game() -> void:
	GlobalSignals.back_to_menu.emit()


func _on_auto_play_timer_timeout() -> void:
	if curr_state == GlobalType.GameState.AUTOPLAY:
		# display next dialogue when time up
		proceed_to_next_line()


func _on_speed_up_timer_timeout() -> void:
	if curr_state == GlobalType.GameState.SPEEDUP:
		proceed_to_next_line()
		dialogue_controller.start_speedup()


func _on_video_background_finished() -> void:
	# this helps with dynamic background/CG
	if video_background.loop:
		# if the background is looping, we dont care in this case
		return
	# otherwise it means cg or dynamic background has ended
	# and its time for next line
	if curr_state == GlobalType.GameState.SHOWING_CG:
		curr_state = prev_state
	ui.show()
	dialogue_controller.show()
	ui.set_press_disabled(false)
	proceed_to_next_line()
