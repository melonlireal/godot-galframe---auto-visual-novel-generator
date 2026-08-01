extends CanvasLayer
class_name DialogueController

@export var narration_pos: Vector2 = Vector2(332.0, 800.0)
@export var dialogue_pos: Vector2 = Vector2(332.0, 850.0)
@export var play_speed_factor: float = 20.0 / 50.0
@export var autoplay_pause_time: float = 1.0

@onready var narration_box: TextureRect = $narration_box
@onready var dialogue_box: TextureRect = $dialogue_box
@onready var character: RichTextLabel = $character_name
@onready var dialogue_diaplayer: RichTextLabel = $dialogue_diaplayer

@onready var _setting = ResourceLoader.load(GlobalResources.setting_save_path)
@onready var auto_play_timer: Timer = $"../auto_play_timer"
@onready var speed_up_timer: Timer = $"../speed_up_timer"

var curr_state: GlobalType.GameState = GlobalType.GameState.DEFAULT
var _voicing_time: float = 0.0


func _ready():
	dialogue_diaplayer.dialogue_play_finished.connect(_on_dialogue_playback_finished)


func set_state(state: GlobalType.GameState):
	curr_state = state


func get_state() -> GlobalType.GameState:
	return curr_state


func set_voicing_time(time: float):
	_voicing_time = time


func play_line(character_name: String, text: String, voicing_time: float):
	_voicing_time = voicing_time
	self.character.text = character_name
	# 切换对话框样式和位置
	if character_name == "":
		narration_box.show()
		dialogue_box.hide()
		dialogue_diaplayer.set_position(narration_pos)
		dialogue_diaplayer.play_dialogue(text, _calculate_duration(text))
	else:
		narration_box.hide()
		dialogue_box.show()
		dialogue_diaplayer.set_position(dialogue_pos)
		dialogue_diaplayer.play_dialogue(text, _calculate_duration(text))


# 立即完整显示当前文本（点击补全）
func show_full():
	dialogue_diaplayer.show_full()


func is_playing() -> bool:
	return dialogue_diaplayer.is_playing()


# 设置对话框/旁白框透明度（0~1）
func set_box_opacity(opacity: float):
	narration_box.modulate.a = opacity
	dialogue_box.modulate.a = opacity


func cancel_autoplay():
	auto_play_timer.stop()


func pause_interaction():
	auto_play_timer.stop()
	speed_up_timer.stop()


func resume_interaction():
	if curr_state == GlobalType.GameState.AUTOPLAY and not dialogue_diaplayer.is_playing():
		auto_play_timer.start()


func start_speedup():
	speed_up_timer.start()


func stop_speedup():
	speed_up_timer.stop()


func _calculate_duration(text: String) -> float:
	var text_len = text.length()
	if text_len == 0:
		return 0.0
	match curr_state:
		GlobalType.GameState.SPEEDUP:
			return 0.0
		GlobalType.GameState.AUTOPLAY:
			var text_dur = text_len / (_setting.auto_play_speed * play_speed_factor)
			return max(text_dur, _voicing_time)
		_:
			return text_len / (_setting.play_speed * play_speed_factor)


func _on_dialogue_playback_finished():
	if curr_state == GlobalType.GameState.AUTOPLAY:
		# 句间等待 = 固定 pause + 配音比文本多出的时间（已包含在 duration 里）
		# duration = max(text_dur, voicing_time)，所以 pause 就是固定值
		auto_play_timer.wait_time = autoplay_pause_time
		auto_play_timer.start()
