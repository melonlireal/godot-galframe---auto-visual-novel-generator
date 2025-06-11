extends TextureButton
@export var cg = ""
@export var lock = true
@export var has_cover = false
signal view
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func load_cover(cover: String):
	var file_at = quick_search(cover)
	if file_at == null:
		print("not here!")
		# TODO fix in error overhaul
		return
	print(file_at)
	$font_display.texture = ResourceLoader.load(file_at)
	
func open():
	lock = false
	$layer.visible = false

func store_CG(CG_name: String):
	var cg = CG_name

func quick_search(filename: String):
	var map = ResourceLoader.load("res://save/mapper_total.tres")
	return map.search_path(filename)


func _on_pressed():
	if has_cover and not lock:
		emit_signal("view", cg)
