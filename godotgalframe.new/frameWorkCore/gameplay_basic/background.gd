extends CanvasLayer
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
var cg_header:Header = ResourceLoader.load("res://save/header.tres") 
var videolist = []
var on_transition = false


func _ready():
	$"..".change_background.connect(change_background)
	pass

func do_transition():
	pass

func change_background(background: String, loop = "true", effect = ""):
	if self.has_method(background):
		var transition = Callable(self, background)
		transition.call()
		return
	print("changing background\n")
	self.get_tree().call_group("CG", "unlock", background)
	cg_header.check_unlock(background) 
	var background_at = asset_map.search_path(background)
	if background_at == null:
		self.get_tree().call_group("errorlog", "background_error", background)
		return
	if background.substr(len(background)-4, -1) == ".ogv":
		if background in videolist:
			return
		# 识别是否是ogv格式
		videolist.append(background)
		if loop == "false":
			$viedo_background.loop = false
		else:
			$viedo_background.loop = true
		$viedo_background.stream = ResourceLoader.load(background_at)
		$viedo_background.play()
	else:
		videolist = []
		$background.texture = ResourceLoader.load(background_at)
		$viedo_background.stream = null

func fadeout():
		$"../UI".visible = false
		$"../dialogue".visible = false
		%dialogue.set_process(false)
		$"..".can_press = false
		%avatar.clear_all_avatar()
		var transit = get_tree().create_tween().bind_node($background)
		transit.tween_property($background, "modulate:a", 0, 0.5)
		await transit.finished
		$"..".proceed()
		var transit2 = get_tree().create_tween().bind_node($background)
		transit2.tween_property($background, "modulate:a", 1, 1)
		await transit2.finished
		$"../UI".visible = true
		$"../dialogue".visible = true
		$"..".can_press = true
		%dialogue.set_process(true)
