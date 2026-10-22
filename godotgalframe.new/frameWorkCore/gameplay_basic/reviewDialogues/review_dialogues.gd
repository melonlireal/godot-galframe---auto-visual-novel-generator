extends CanvasLayer
class_name ReviewDialogues
var gameplay_setting:GameplaySetting = ResourceLoader.load(GlobalResources.gameplay_setting_path)
var limit = gameplay_setting.get_setting("limit")
var narrator = gameplay_setting.get_setting("narrator")

var line = {"character":"", "dialogue":"", "voice":""}
# Called when the node enters the scene tree for the first time.
signal close

@onready var line_container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var voice_player: AudioStreamPlayer = $voice
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var close_button: TextureButton = $close

func _ready():
	close_button.pressed.connect(_on_close_pressed)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("return"):
		close.emit()

func get_words(character: String, dialogue: String):
	if character == "":
		line["character"] = narrator
	else:
		line["character"] = character
	line["dialogue"] = dialogue

func get_voice(voice: String):
	line["voice"] = voice
	# this is because voice and dialogue gets processed seperately in initial design

func add_line():
	if line["character"] == narrator and line["dialogue"] == "" and line["voice"] == "":
		return
	var container = line_container
	if container.get_child_count() >= limit:
		container.get_child(0).queue_free()
	var compound = preload("res://frameWorkCore/gameplay_basic/reviewDialogues/line_review.tscn")
	var script = compound.instantiate()
	script.character = line["character"]
	script.dialogue = line["dialogue"]
	script.voice = line["voice"]
	script.connect("play_voice", play_voice)
	container.add_child(script)
	line = {"character":"", "dialogue":"", "voice":""}

	
func play_voice(voice_at: String):
	voice_player.stream = ResourceLoader.load(voice_at)
	voice_player.playing = true
	pass

func jump_to_buttom():
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	

func _on_close_pressed() -> void:
	close.emit()
