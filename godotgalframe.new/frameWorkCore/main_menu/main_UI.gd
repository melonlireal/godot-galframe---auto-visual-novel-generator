extends CanvasLayer
signal on_button
signal out_button
var play_speed = 0.1
var setting_save = "user://save/save_total.tres"
# Called when the node enters the scene tree for the first time.
func _ready():
	%function_name.text = ""
	for nodes in $Control/VBoxContainer.get_children():
		nodes.mouse_exited.connect(_mouse_leave)
	$Control/volumn_slider.visible = false
	$Control/volumn_slider.editable = false
	var saved_data = ResourceLoader.load(setting_save)
	$Control/volumn_slider.value = saved_data.total_volumn
		
func _mouse_leave():
	%function_name.text = ""
	emit_signal("out_button")

func reach_button():
	emit_signal("on_button")
	
func _on_save_mouse_entered():
	%function_name.text = "保存"
	reach_button()

func _on_load_mouse_entered():
	%function_name.text = "加载"
	reach_button()
	
func _on_quicksave_mouse_entered():
	%function_name.text = "快速保存"
	reach_button()
	
func _on_quickload_mouse_entered():
	%function_name.text = "快速加载"
	reach_button()
	
func _on_setting_mouse_entered():
	%function_name.text = "设置"
	reach_button()
	
func _on_volumn_mouse_entered():
	%function_name.text = "音量"
	reach_button()
	
func _on_back_to_last_choice_mouse_entered():
	%function_name.text = "展示剧情树"
	reach_button()


func _on_back_by_one_script_mouse_entered():
	%function_name.text = "历史记录"
	reach_button()
	
func _on_auto_mouse_entered():
	%function_name.text = "自动播放"
	reach_button()
	
func _on_forward_speed_mouse_entered():
	%function_name.text = "快进"
	reach_button()
	
func _on_forward_to_next_choice_mouse_entered():
	%function_name.text = "快进到下一选项"
	reach_button()
	
func _on_visible_mouse_entered():
	%function_name.text = "隐藏对话框"
	reach_button()

func _on_leave_mouse_entered():
	%function_name.text = "回到主菜单"
	reach_button()


func _on_volumn_pressed():
	if $Control/volumn_slider.visible:
		$Control/volumn_slider.visible = false
		$Control/volumn_slider.editable = false
		return
	$Control/volumn_slider.visible = true
	$Control/volumn_slider.editable = true




func _on_volumn_slider_value_changed(value):
	var saved_data = ResourceLoader.load(setting_save)
	saved_data.voice_volumn = value
	var bus = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus, linear_to_db(value))
	ResourceSaver.save(saved_data, setting_save)
