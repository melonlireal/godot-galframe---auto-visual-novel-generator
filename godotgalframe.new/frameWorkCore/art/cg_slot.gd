extends TextureButton
class_name CGSlot
@export var cg: String = ""
@export var lock: bool = true
@export var has_cover: bool = false
signal view
@onready var font_display: TextureRect = $font_display
@onready var layer: ColorRect = $layer
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(_on_pressed)


func load_cover(cover: String) -> void:
	var asset_path_finder:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)
	var file_at = asset_path_finder.search_path(cover)
	if file_at == null:
		print("not here!")
		# TODO fix in error overhaul
		return
	print(file_at)
	font_display.texture = ResourceLoader.load(file_at)
	
func open() -> void:
	lock = false
	layer.visible = false

func store_CG(CG_name: String) -> void:
	cg = CG_name

func _on_pressed() -> void:
	if has_cover and not lock:
		emit_signal("view", cg)
