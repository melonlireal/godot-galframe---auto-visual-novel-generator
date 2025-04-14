extends RichTextLabel
@export var play_speed_factor = 20.0/50.0
@onready var initialization = true
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
		initialization = false
		_start_dialogue()
	else:
		self.set_process(false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if narrration:
		self.set_position(Vector2(narration_x, narration_y))
	elif not narrration:
		self.set_position(Vector2(speaking_x, speaking_y))
		
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
	if initialization:
		initialization = false
		return
	self.set_process(true)
