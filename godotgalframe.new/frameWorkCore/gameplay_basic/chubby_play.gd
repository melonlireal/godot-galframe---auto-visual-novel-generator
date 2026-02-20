extends CanvasLayer

var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.

func reset_chubby():
	$back.texture = null
	$front.texture = null
	$back.modulate.a = 1.0
	$front.modulate.a = 0.0

func swap(next_slide: String):
	var transit_front = get_tree().create_tween().bind_node($front)
	var transit_back = get_tree().create_tween().bind_node($back)
	$front.modulate.a = 0.0
	if next_slide == "clear":
		$front.texture = null
		transit_back.tween_property($back, "modulate:a", 0, 0.2)
		await transit_back.finished
		$back.texture = null
		return
	var next_slide_at = asset_map.search_path(next_slide)
	if next_slide_at == null:
		self.get_tree().call_group("errorlog", "background_error", next_slide)
		return
	$front.texture = ResourceLoader.load(next_slide_at)
	# for some reason after this step back texture is set back to null again
	transit_front.tween_property($front, "modulate:a", 1, 0.2)
	await transit_front.finished
	$back.texture = $front.texture
	$front.texture = null
	return
