extends CanvasLayer
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
var cg_header:CGS = ResourceLoader.load("res://save/cg.tres") 
@onready var background_display: TextureRect = $background
@onready var video_background_display: VideoStreamPlayer = $video_background

var videolist = []
	
func change_backgrounds(backgrounds: Array):
	for background in backgrounds:
		var background_name:String = background[0]
		var loop = background[1]
		var background_at = asset_map.search_path(background_name)
		if background_at == null:
			self.get_tree().call_group("errorlog", "background_error", background_name)
			return
		var global_progress:GlobalGameProgress = ResourceLoader.load(GlobalResources.global_progress_path)
		global_progress.add_cg(background_name)
		ResourceSaver.save(global_progress, GlobalResources.global_progress_path)
		if background_name.ends_with( ".ogv"):
			# identyfy ogv format (dynami background)
			if background_name in videolist:
				return
			videolist.append(background_name)
			if loop == "false":
				video_background_display.loop = false
			else:
				video_background_display.loop = true
			video_background_display.stream = ResourceLoader.load(background_at)
			video_background_display.play()
		else:
			videolist = []
			background_display.texture = ResourceLoader.load(background_at)
			video_background_display.stream = null

func clear_background():
	background_display.texture = null
	video_background_display.stream = null
	videolist = []

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
		$"..".proceed_to_next_line()
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
		$"..".proceed_to_next_line()
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
