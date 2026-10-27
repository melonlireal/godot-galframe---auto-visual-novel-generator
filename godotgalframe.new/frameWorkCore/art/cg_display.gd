extends PopupUI
# 查看CG中所有需要载入的CG

func ui_key() -> UIManager.UI:
	return UIManager.UI.CG_DISPLAY
var cg_all: CGS
@onready var cg_slots: GridContainer = $main/CenterContainer/GridContainer
@onready var main: TextureRect = $main
@onready var present_pic: TextureRect = $present_pic
@onready var present_vid: VideoStreamPlayer = $present_vid
@onready var return_button: TextureButton = $main/return
var cg_list: Array
var cg_cover_list: Array
# Called when the node enters the scene tree for the first time.


func _ready():
	cg_all = ResourceLoader.load(GlobalResources.cg_all_path)
	cg_list = cg_all.get_cg().duplicate()
	cg_cover_list = cg_all.get_cg_cover().duplicate()
	return_button.pressed.connect(_on_return_pressed)
	present_pic.visible = false
	present_vid.visible = false
	get_cover()
	load_unlock()
	for slot in cg_slots.get_children():
		slot.connect("view", present)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("return") or event.is_action_pressed("press")) and (present_pic.visible or present_vid.visible):
		present_pic.texture = null
		present_vid.stream = null
		main.visible = true
		present_pic.visible = false
		present_vid.visible = false
	
	
func get_cover() -> void:
	for slot:CGSlot in cg_slots.get_children():
		if cg_cover_list.is_empty():
			return
		if not slot.has_cover:
			slot.load_cover(cg_cover_list.pop_front())
			slot.has_cover = true
			slot.cg = cg_list.pop_front()
	
	
func unlock(cg_name: String) -> void:
	for slot:CGSlot in cg_slots.get_children():
		if slot.cg == cg_name:
			slot.open()
	
	
func load_unlock() -> void:
	# unlock cg from global game progress
	print("unlocking cg")
	var saved_data:GlobalGameProgress = ResourceLoader.load(GlobalResources.global_progress_path)
	for cg in saved_data.unlocked_cg:
		unlock(cg)
	
	# used to present cg
func present(CG_name: String) -> void:
	var asset_path_finder:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)
	var file_at = asset_path_finder.search_path(CG_name)
	if file_at == null:
		return
	if CG_name.ends_with(".ogv"):
		present_vid.show()
		present_vid.stream = ResourceLoader.load(file_at)
		present_vid.play()
		main.hide()
	else:
		present_pic.show()
		present_pic.texture = ResourceLoader.load(file_at)
		main.hide()

		
func _on_return_pressed() -> void:
	UIManager.close(UIManager.UI.CG_DISPLAY)
