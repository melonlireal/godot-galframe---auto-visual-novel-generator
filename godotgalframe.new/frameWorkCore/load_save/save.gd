extends CanvasLayer
signal swap
signal change_image
@export var display_save = true
# 看不懂了，嘻嘻。能用就行
var save_UI = "res://artResource/UI_gameplay/setting_UI/save_background.png"
var load_UI = "res://artResource/UI_gameplay/setting_UI/load_background.png"
var save_load_switch = true
# 不会一直切换背景然后尼玛卡住不动
var line: int
var file: String
var temp_save = {}

func _ready():
	for slot in $TextureRect/GridContainer.get_children():
		slot.for_load = false
		slot.saving.connect(save_in_slot)
		slot.mouse_exited.connect(clear_display)
		slot.mouse_in.connect(windows_display)
	
func _process(_delta):
	if display_save:
		if save_load_switch:
			return
		$TextureRect.texture = ResourceLoader.load(save_UI)
		for slot in $TextureRect/GridContainer.get_children():
			slot.for_load = false
		save_load_switch = true
	else :
		if not save_load_switch:
			return
		$TextureRect.texture = ResourceLoader.load(load_UI)
		for slot in $TextureRect/GridContainer.get_children():
			slot.for_load = true
		save_load_switch = false
		
func clear_display():
	$TextureRect/display.texture = null
	# 在鼠标离开保存槽位时清除放大窗口的图片
	
func windows_display(slot: int):
	$TextureRect/display.texture = $TextureRect/GridContainer.get_child(slot).get_image()
	# 在大窗口上展示保存截图
	
func get_temp_save_data(image: Image, curr_chap: String, curr_line: int):
	temp_save = {"image": image, "curr_chap": curr_chap, "curr_line": curr_line}
	# 收到游戏界面截图

func save_in_slot(slot: int):
	# 先把图片放在对应的槽位上
	$TextureRect/GridContainer.get_child(slot).display(temp_save["image"])
	# 因为图片在打开界面时，已经准备好了，不会担心没有的问题
	#self.get_tree().call_group("game_play", "get_progress", slot)
	# 把槽位数据传过去，待会跟着行数和章节名传回来
	# 我知道这很抽象， 但怎么优化我不道啊
	# 我是傻逼⬆byd就不能一起传吗
	var progress = progress_data.new()
	progress.which_file = temp_save["curr_chap"]
	progress.which_line = temp_save["curr_line"]
	ResourceSaver.save(progress, "user://save/" + str(slot) + ".tres")
	
#func save_progress(which_chapter: String, what_slot: int, which_line: int):
	#var progress = progress_data.new()
	#progress.which_file = which_chapter
	#progress.which_line = which_line
	#ResourceSaver.save(progress, "user://save/" + str(what_slot) + ".tres")

func _on_return_pressed():
	self.visible = false
	emit_signal("swap")
