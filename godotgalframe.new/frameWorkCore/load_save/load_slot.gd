extends TextureRect
@onready var has_save = false
@export var for_load = true
var pic: Image
signal ruSure # in memory of CSC108H5 2023 November 23rd incident
# 如果要覆盖存档的话先确认一下
signal saving
signal loading
signal mouse_in

func _ready():
	var load_file = str(self.get_index()) + ".tres"
	if load_file in DirAccess.get_files_at("user://save/"):
		load_pic()



func display(pics: Image):
	pics.save_png("user://"+str(self.get_index()) + ".png")
	$save_display.texture = ImageTexture.create_from_image(pics)
	emit_signal("mouse_in", self.get_index())
	# 将截图保存且放置在小窗口上显示

func load_pic():
	var find_pic_at = "user://"+str(self.get_index()) + ".png"
	var image = Image.load_from_file(find_pic_at)
	var textures = ImageTexture.create_from_image(image)
	$save_display.texture = textures
	# I get this as a solution in godot forum and rn I have no idea why it works
	
func _save():
	if $save_display.texture != null:
		emit_signal("ruSure")
	# 如果要覆盖存档的话先确认一下
	# 这个功能先不做，懒
	emit_signal("saving", self.get_index())
	# 史山链的开启（悲）
	
func _load():
	if $save_display.texture != null:
		# 只有在有存档的状态下才会加载
		var save_path = "user://save/" + str(self.get_index()) + ".tres"
		var vars:Variables = ResourceLoader.load("user://save/" + str(self.get_index()) + "var.tres")
		var find_save = ResourceLoader.load(save_path)
		self.get_tree().call_group("main", "load_game", find_save.which_file, find_save.which_line, vars)
	
	
func _confirm():
	pass
	# 慢慢更

func get_image():
	return $save_display.texture
	
func _on_button_button_down():
	if for_load:
		_load()
	elif not for_load:
		_save()


func _on_button_mouse_entered():
	emit_signal("mouse_in", self.get_index())
