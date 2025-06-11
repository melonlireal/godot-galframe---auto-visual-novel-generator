extends CanvasLayer

func _ready() -> void:
	self.visible = false
	

# Called when the node enters the scene tree for the first time.
func unknown_command(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未知命令{0}请确保拼写正确".format({"0": type})
	
func character_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未知角色立绘{0}请确保拼写和文件类型(jpg, png)正确".format({"0": type})
	
func background_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未知背景{0}请确保拼写和文件类型(jpg, png)正确".format({"0": type})
	
func choice_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：选项无法前往对应的txt文件{0}请确保拼写正确".format({"0": type})
	
func music_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未知音乐{0}请确保拼写和文件类型正确".format({"0": type})
	
func character_effect_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未知角色效果{0}请确保拼写正确".format({"0": type})
	
func background_effect_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未知背景效果{0}请确保拼写正确".format({"0": type})
	
func variable_not_found(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "错误：未找到对应变量{0}请确保拼写正确".format({"0": type})
	
func cg_header_error(type: String):
	pass
	
func color_header_error(type: String):
	pass
	
func variable_header_error(type: String):
	pass
	
func game_call_error(type: String):
	pass
