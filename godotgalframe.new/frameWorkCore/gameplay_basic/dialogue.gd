extends RichTextLabel
@export var play_speed_factor = 20.0/50.0
@export var on_transition = true
# used to block dialogue from playing when setting up 
@export var repeat = false
# 用来放设置里的播放演示
@export var on_auto = false
@export var narrration = false
@export var on_special_effect = false
# used to check if there is currently special effect
@export var narration_x = 332.0
@export var narration_y = 800.0
@export var speaking_x = 332.0
@export var speaking_y = 850.0
@export var voicing_time = 0.0 
# the time for voice to fully play for current 
# playng line, if no voicing the line is 0
@export var autoplay_pause_time = 1.0
# a factor set to check how long the current line should stay
# after fully displayed to player
# 切换到旁白位置
func _ready():
	if repeat:
		on_transition = false
		_start_dialogue()
	else:
		self.set_process(false)
		
func _process(delta):
	if on_special_effect:
		return
	if narrration:
		self.set_position(Vector2(narration_x, narration_y))
	elif not narrration:
		self.set_position(Vector2(speaking_x, speaking_y))
	if "speed_up" in $"../..":
		if $"../..".speed_up:
	# TODO shit code fix later
			self.visible_ratio = 1.0
	var data = ResourceLoader.load(GlobalResources.setting_save_path)
	if self.visible_ratio == 1.0:
		if repeat:
			self.visible_ratio = 0.0
		else:
			set_process(false)
	if on_auto:
		var progress_per_frame:float = ((data.auto_play_speed * delta * play_speed_factor)
		/self.get_parsed_text().length())
		var frame_per_second = 1.0/delta
		var expected_time = (1.0/progress_per_frame)/frame_per_second
		if voicing_time - expected_time > 0: 
			#if it takes more time to play voice then time to display entire dialogue
			$"../../auto_play_timer".wait_time = autoplay_pause_time + voicing_time - expected_time
		elif has_node("../../auto_play_timer"):
			$"../../auto_play_timer".wait_time = autoplay_pause_time
		self.visible_ratio += progress_per_frame
	else:
		self.visible_ratio += ((data.play_speed * delta * play_speed_factor)
		/self.get_parsed_text().length())
		
func _start_dialogue():
	if on_transition:
		on_transition = false
		return
	self.visible_ratio = 0.0
	self.set_process(true)

func start_transition():
	on_transition = true
	
func transition_done():
	_start_dialogue()
