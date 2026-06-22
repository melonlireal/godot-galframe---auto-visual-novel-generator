extends TextureButton
@export var character = ""
@export var dialogue = ""
@export var voice = ""
var voice_at = ""
signal play_voice
var asset_map:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$character.text = character
	$dialogue.text = dialogue
	voice_at = asset_map.search_path(voice)
	pass 
	
func _on_pressed():
	print("pressed")
	emit_signal("play_voice", voice_at)
