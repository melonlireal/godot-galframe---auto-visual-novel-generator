extends TextureButton
@export var character = ""
@export var dialogue = ""
@export var voice = ""
var voice_at = ""
signal play_voice
var asset_map:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)
@onready var character_label: RichTextLabel = $character
@onready var dialogue_label: RichTextLabel = $dialogue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	character_label.text = character
	dialogue_label.text = dialogue
	voice_at = asset_map.search_path(voice)
	pass 
	
func _on_pressed():
	print("pressed")
	if voice_at:
		emit_signal("play_voice", voice_at)
