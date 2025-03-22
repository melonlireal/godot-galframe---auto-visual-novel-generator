extends RichTextLabel
var play_speed = 20.0
@onready var initialization = true
@export var repeat = false
# 用来放设置里的播放演示
@export var on_auto = false
@export var narrration = false
@export var x = 332.0
@export var y = 800.0
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
		self.set_position(Vector2(x, y))
	elif not narrration:
		self.set_position(Vector2(332.0, 842.0))
		
	var data = ResourceLoader.load("user://save/save_total.tres")
	if self.visible_ratio == 1.0:
		if repeat:
			self.visible_ratio = 0.0
		else:
			set_process(false)
	if on_auto:
		self.visible_ratio += (data.auto_play_speed * delta)/self.text.length()
	else:
		self.visible_ratio += (data.play_speed * delta)/self.text.length()
		
func _start_dialogue():
	if initialization:
		initialization = false
		return
	self.set_process(true)
