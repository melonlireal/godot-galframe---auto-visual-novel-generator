extends CanvasLayer
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
var videolist = []
var on_transition = false
var last_transition = ""
signal proceed
# when changing back ground will check whether last back ground command is transition
# and execute the respected fadeout effect

func _ready():
	$"..".change_background.connect(change_background)
	pass

func do_transition():
	pass

func change_background(background: String, loop = "true", effect = ""):
	print("changing background\n")
	self.get_tree().call_group("CG", "unlock", background)
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
