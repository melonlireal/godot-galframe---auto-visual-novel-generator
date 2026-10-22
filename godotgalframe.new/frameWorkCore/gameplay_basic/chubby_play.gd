extends CanvasLayer

@onready var back: TextureRect = $back
@onready var front: TextureRect = $front

# Called when the node enters the scene tree for the first time.

func reset_chubby():
	back.texture = null
	front.texture = null
	back.modulate.a = 1.0
	front.modulate.a = 0.0
	
func process_chubby_commands(chubby_commands:Array):
	for chubby_command in chubby_commands:
		await swap(chubby_command[0])

func swap(next_slide: String):
	var transit_front = get_tree().create_tween().bind_node(front)
	var transit_back = get_tree().create_tween().bind_node(back)
	front.modulate.a = 0.0
	if next_slide == GlobalType.COMMAND_CLEAR:
		front.texture = null
		transit_back.tween_property(back, "modulate:a", 0, 0.2)
		await transit_back.finished
		back.texture = null
		back.modulate.a = 1.0
		return
	var asset_path_finder:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)
	var next_slide_at = asset_path_finder.search_path(next_slide)
	if next_slide_at == null:
		GlobalSignals.background_error.emit(next_slide)
		return
	var global_progress:GlobalGameProgress = ResourceLoader.load(GlobalResources.global_progress_path)
	global_progress.add_cg(next_slide)
	ResourceSaver.save(global_progress, GlobalResources.global_progress_path)
	front.texture = ResourceLoader.load(next_slide_at)
	transit_front.tween_property(front, "modulate:a", 1, 0.2)
	await transit_front.finished
	back.texture = front.texture
	front.texture = null
	return
