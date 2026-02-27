extends CanvasLayer
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
var cg_header:CGS = ResourceLoader.load("res://save/cg.tres") 
var videolist = []
var on_transition = false



func do_transition():
	pass

func change_background(background: String, loop = "true", _effect = ""):
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


# the following functions are hard coded transitions
# WARNING a new background command must be placed after a transition command
#
func fadeout():
		$"../UI".visible = false
		$"../dialogue".visible = false
		%dialogue.set_process(false)
		$"..".can_press = false
		%avatar.clear_all_avatar()
		%avatar.visible = false;
		$"../effects/effect_assets/black".visible = true
		$"..".speed_up = false
		var transit = get_tree().create_tween().bind_node($"../effects/effect_assets/black")
		transit.tween_property($"../effects/effect_assets/black", "color:a", 1, 0.5)
		await transit.finished
		%avatar.visible = true
		$"..".proceed()
		var transit2 = get_tree().create_tween().bind_node($"../effects/effect_assets/black")
		transit2.tween_property($"../effects/effect_assets/black", "color:a", 0, 1)
		await transit2.finished
		$"../UI".visible = true
		$"../dialogue".visible = true
		$"..".can_press = true
		%dialogue.set_process(true)
		$"../effects/effect_assets/black".visible = false

func flash():
		print("flash")
		$"../UI".visible = false
		$"../dialogue".visible = false
		%dialogue.set_process(false)
		$"..".can_press = false
		%avatar.clear_all_avatar()
		$"../effects/effect_assets/white".visible = true
		$"..".speed_up = false
		var transit = get_tree().create_tween().bind_node($"../effects/effect_assets/white")
		transit.tween_property($"../effects/effect_assets/white", "color:a", 1, 0.5)
		await transit.finished
		$"..".proceed()
		var transit2 = get_tree().create_tween().bind_node($"../effects/effect_assets/white")
		transit2.tween_property($"../effects/effect_assets/white", "color:a", 0, 0.5)
		await transit2.finished
		$"../UI".visible = true
		$"../dialogue".visible = true
		$"..".can_press = true
		%dialogue.set_process(true)
		$"../effects/effect_assets/white".visible = false

func shake():
	pass
