extends CanvasLayer
var asset_map: AssetPath
var cg_header: CGS
@onready var background_display: TextureRect = $background
@onready var video_background_display: VideoStreamPlayer = $video_background



var videolist: Array[String] = []
	
func _ready() -> void:
	asset_map = ResourceLoader.load(GlobalResources.asset_map_path)
	cg_header = ResourceLoader.load(GlobalResources.cg_all_path)

func change_backgrounds(backgrounds: Array) -> void:
	for background in backgrounds:
		var background_name:String = background[0]
		var loop: String = background[1]
		var background_at = asset_map.search_path(background_name)
		if background_at == null:
			GlobalSignals.background_error.emit(background_name)
			return
		var global_progress:GlobalGameProgress = ResourceLoader.load(GlobalResources.global_progress_path)
		global_progress.add_cg(background_name)
		ResourceSaver.save(global_progress, GlobalResources.global_progress_path)
		if background_name.ends_with( ".ogv"):
			# identyfy ogv format (dynami background)
			if loop == "false":
				video_background_display.loop = false
			else:
				if background_name in videolist:
					return
				videolist.append(background_name)
				video_background_display.loop = true
			video_background_display.stream = ResourceLoader.load(background_at)
			video_background_display.play()
		else:
			videolist = []
			background_display.texture = ResourceLoader.load(background_at)
			video_background_display.stream = null

func clear_background() -> void:
	background_display.texture = null
	video_background_display.stream = null
	videolist = []
