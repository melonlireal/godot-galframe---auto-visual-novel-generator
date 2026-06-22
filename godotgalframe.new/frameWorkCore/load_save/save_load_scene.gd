extends CanvasLayer
class_name SaveLoad

@export var display_save = true
# 创建时根据这个切换贴图和效果
var save_UI = "res://artResource/UI_gameplay/setting_UI/save_background.png"
var load_UI = "res://artResource/UI_gameplay/setting_UI/load_background.png"

var temp_save = {}


func _ready():
	if display_save:
		$TextureRect.texture = ResourceLoader.load(save_UI)
		for slot in $TextureRect/GridContainer.get_children():
			slot.for_load = false
	else :
		$TextureRect.texture = ResourceLoader.load(load_UI)
		for slot in $TextureRect/GridContainer.get_children():
			slot.for_load = true
	for slot:SaveLoadSlot in $TextureRect/GridContainer.get_children():
		#slot.for_load = false
		slot.saving.connect(save_in_slot)
		slot.loading.connect(load_from_slot)
		slot.mouse_exited.connect(clear_display)
		slot.mouse_entered.connect(windows_display)

		
		
	#self.get_parent().connect("load_game", load_game)
	
func clear_display():
	$TextureRect/display.texture = null
	# 在鼠标离开保存槽位时清除放大窗口的图片
	
func windows_display(slot: int):
	$TextureRect/display.texture = $TextureRect/GridContainer.get_child(slot).get_image()
	# 在大窗口上展示保存截图
	
func get_temp_save_data(image: Image, curr_chap: String, curr_line: int, vars: Variables):
	temp_save = {"image": image, "curr_chap": curr_chap, "curr_line": curr_line, "vars": vars}
	# 收到游戏界面截图

func save_in_slot(slot: int):
	$TextureRect/GridContainer.get_child(slot).display(temp_save["image"])
	var progress:CurrGameProgress = CurrGameProgress.new()
	progress.which_file = temp_save["curr_chap"]
	progress.which_line = temp_save["curr_line"] - 1
	progress.variables = temp_save["vars"].duplicate(true)
	ResourceSaver.save(progress, "user://save/" + str(slot) + ".tres")
	
func load_from_slot(progress: CurrGameProgress):
	GlobalSignals.close_ui.emit()
	GlobalSignals.load_game_progress.emit(progress)
	self.queue_free()
	
func _on_return_pressed():
	GlobalSignals.close_ui.emit()
	self.queue_free()
