extends CanvasLayer
signal swap
var cg = "res://artResource/background/cg.txt"
var cg_all = FileAccess.open(cg, FileAccess.READ)
# 查看CG中所有需要载入的CG
var save_path = "user://save/save_total.tres"
var start_location = "res://artResource/background/"
var cg_list = []
var cg_cover_list = []
# Called when the node enters the scene tree for the first time.


func _ready():
	$present_pic.visible = false
	$present_vid.visible = false
	while not cg_all.eof_reached():
		var temp = cg_all.get_line()
		if temp != "":
			# 如果有可解锁CG再解锁CG
			var line = Array(temp.rsplit(" "))
			cg_list.append(line.pop_front())
			cg_cover_list.append(line.pop_front())
			print((cg_list))
			print(cg_cover_list)
	get_cover()
	for slot in $main/CenterContainer/GridContainer.get_children():
		slot.connect("view", present)


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(_delta):
	if Input.is_action_just_pressed("return") and ($present_pic.visible or $present_vid.visible):
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
			var save_file = ResourceLoader.load(save_path)
			if cg_name not in save_file.unlocked_cg:
				print("add new cg")
				save_file.unlocked_cg.append(cg_name)
				ResourceSaver.save(save_file, save_path)
	
	
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
	self.visible = false
	emit_signal("swap")
