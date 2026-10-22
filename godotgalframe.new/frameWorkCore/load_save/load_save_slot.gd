class_name SaveLoadSlot
extends TextureRect
var has_save: bool = false
@export var for_load: bool = true
signal ruSure # in memory of CSC108H5 2023 November 23rd incident
# 如果要覆盖存档的话先确认一下
signal saving(slot: int)
signal loading(progress: CurrGameProgress)
signal hovered(slot: int)

@onready var save_display: TextureRect = $save_display
@onready var button: Button = $Button


func _ready():
	button.button_down.connect(_on_button_button_down)
	button.mouse_entered.connect(_on_button_mouse_entered)
	button.mouse_exited.connect(_on_button_mouse_exited)
	var load_file = str(self.get_index()) + ".tres"
	if load_file in DirAccess.get_files_at("user://save/"):
		load_pic()

func display(pics: Image) -> void:
	pics.save_png(GlobalResources.save_screenshot_dir + str(self.get_index()) + ".png")
	save_display.texture = ImageTexture.create_from_image(pics)
	# 将截图保存且放置在小窗口上显示

func load_pic() -> void:
	var find_pic_at = GlobalResources.save_screenshot_dir + str(self.get_index()) + ".png"
	var image = Image.load_from_file(find_pic_at)
	var textures = ImageTexture.create_from_image(image)
	save_display.texture = textures
	# I get this as a solution in godot forum and rn I have no idea why it works

func _save() -> void:
	if save_display.texture != null:
		emit_signal("ruSure")
	# 如果要覆盖存档的话先确认一下，这个功能先不做，懒
	self.saving.emit(self.get_index())

func _load() -> void:
	if save_display.texture != null:
		# 只有在有存档的状态下才会加载
		var save_path: String = "user://save/" + str(self.get_index()) + ".tres"
		var find_save:CurrGameProgress = ResourceLoader.load(save_path)
		loading.emit(find_save)


func _confirm() -> void:
	pass
	# 慢慢更

func get_image() -> Texture2D:
	return save_display.texture
	
func _on_button_button_down() -> void:
	if for_load:
		_load()
	else:
		_save()


func _on_button_mouse_entered() -> void:
	hovered.emit(self.get_index())


func _on_button_mouse_exited() -> void:
	mouse_exited.emit()
