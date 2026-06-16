extends CanvasLayer
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
var cg_header:CGS = ResourceLoader.load("res://save/cg.tres") 
@onready var background_display: TextureRect = $background
@onready var video_background_display: VideoStreamPlayer = $video_background
@onready var effect_black: ColorRect = $"../effects/effect_assets/black"
@onready var effect_white: ColorRect = $"../effects/effect_assets/white"



var videolist = []
	
func change_backgrounds(backgrounds: Array):
	for background in backgrounds:
		var background_name:String = background[0]
		if self.has_method(background_name):
			var op = Callable(self, background_name)
			op.call()
			return
		var loop = background[1]
		var background_at = asset_map.search_path(background_name)
		if background_at == null:
			GlobalSignals.background_error.emit(background_name)
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
		GlobalSignals.pause_game_interaction.emit()
		var transit = create_tween()
		transit.tween_property(effect_black, "color:a", 1, 0.5)
		await transit.finished
		$"..".proceed_to_next_line()
		var transit2 = create_tween()
		transit2.tween_property(effect_black, "color:a", 0, 1)
		await transit2.finished
		GlobalSignals.unpause_game_interaction.emit()

func flash():
		GlobalSignals.pause_game_interaction.emit()
		var transit = get_tree().create_tween().bind_node(effect_white)
		transit.tween_property(effect_white, "color:a", 1, 0.5)
		await transit.finished
		$"..".proceed_to_next_line()
		var transit2 = get_tree().create_tween().bind_node(effect_white)
		transit2.tween_property(effect_white, "color:a", 0, 0.5)
		await transit2.finished
		GlobalSignals.unpause_game_interaction.emit()

func shake():
	pass
