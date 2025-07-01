extends CanvasLayer
signal swap
var cg_header = "res://save/header.tres"
var cg_all:Header = ResourceLoader.load(cg_header)
# 查看CG中所有需要载入的CG
var save_path = "user://save/save_total.tres"
var cg_list = cg_all.get_cg()
var cg_cover_list = cg_all.get_cg_cover()
# Called when the node enters the scene tree for the first time.


func _ready():
	$present_pic.visible = false
	$present_vid.visible = false
	get_cover()
	load_unlock()
	for slot in $main/CenterContainer/GridContainer.get_children():
		slot.connect("view", present)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(_delta):
	if (Input.is_action_just_pressed("return") or Input.is_action_just_pressed("press")) and ($present_pic.visible or $present_vid.visible):
		$present_pic.texture = null
		$present_vid.stream = null
		$main.visible = true
		$present_pic.visible = false
		$present_vid.visible = false
	
	
func get_cover():
	for slot in $main/CenterContainer/GridContainer.get_children():
		if cg_cover_list.is_empty():
			return
		if not slot.has_cover:
			slot.load_cover(cg_cover_list.pop_front())
			slot.has_cover = true
			slot.cg = cg_list.pop_front()
	
	
func unlock(cg_name: String):
	for slot in $main/CenterContainer/GridContainer.get_children():
		if slot.cg == cg_name:
			slot.open()
	
	
func load_unlock():
	# 从存档中解锁CG
	print("unlocking cg")
	var saved_data = ResourceLoader.load(save_path)
	print(saved_data.unlocked_cg)
	for cg in saved_data.unlocked_cg:
		unlock(cg)
	
	# used to present cg
func present(CG_name: String):
	print("presenting")
	var file_at = quick_search(CG_name)
	if file_at == null:
		print("not here!")
		return
	if CG_name.substr(len(CG_name)-4, -1) == ".ogv":
		print("present vid")
		$present_vid.visible = true
		$present_vid.stream = ResourceLoader.load(file_at)
		$present_vid.play()
		$main.visible = false
	else:
		print("present pic")
		$present_pic.visible = true
		$present_pic.texture = ResourceLoader.load(file_at)
		$main.visible = false

func quick_search(filename: String):
	var map = ResourceLoader.load("res://save/mapper_total.tres")
	return map.search_path(filename)
		
func _on_return_pressed():
	self.queue_free()
