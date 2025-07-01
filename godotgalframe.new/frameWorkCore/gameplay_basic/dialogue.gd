extends RichTextLabel
@export var play_speed_factor = 20.0/50.0
@export var on_transition = true
# used to block dialogue from playing when setting up 
@export var repeat = false
# 用来放设置里的播放演示
@export var on_auto = false
@export var narrration = false
@export var narration_x = 332.0
@export var narration_y = 800.0
@export var speaking_x = 332.0
@export var speaking_y = 850.0
# 切换到旁白位置
# Called when the node enters the scene tree for the first time.
func _ready():
	if repeat:
		on_transition = false
		_start_dialogue()
	else:
		self.set_process(false)
		
func _process(delta):
	if narrration:
		self.set_position(Vector2(narration_x, narration_y))
	elif not narrration:
		self.set_position(Vector2(speaking_x, speaking_y))
	if "speed_up" in $"../..":
		if $"../..".speed_up:
	# shit code fix later
			self.visible_ratio = 1.0
	var data = ResourceLoader.load("user://save/save_total.tres")
	if self.visible_ratio == 1.0:
		if repeat:
			self.visible_ratio = 0.0
		else:
			set_process(false)
	if on_auto:
		self.visible_ratio += ((data.auto_play_speed * delta * play_speed_factor)
		/self.get_parsed_text().length())
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
