extends CanvasLayer

var limit = GlobalResources.gameplay_setting.get_setting("limit")
var narrator = GlobalResources.gameplay_setting.get_setting("narrator")

var default_factor = 864
# this is the current difference between the max value to scroll and the 
# max value of v scroll bar
# subtract this when assigning container to bottom
var  curr_limit = 0
var line = {"character":"", "dialogue":"", "voice":""}
# Called when the node enters the scene tree for the first time.
signal close

func _input(event: InputEvent) -> void:
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
	curr_limit += 1
	if curr_limit > limit:
		pop_line()
	var compound = preload("res://frameWorkCore/gameplay_basic/line_review.tscn")
	var script = compound.instantiate()
	script.character = line["character"]
	script.dialogue = line["dialogue"]
	script.voice = line["voice"]
	script.connect("play_voice", play_voice)
	$ScrollContainer/VBoxContainer.add_child(script)
	line = {"character":"", "dialogue":"", "voice":""}

	
func pop_line():
	$ScrollContainer/VBoxContainer.get_child(0).queue_free()
	
func play_voice(voice_at: String):
	$voice.stream = ResourceLoader.load(voice_at)
	$voice.playing = true
	pass
	
func jump_to_buttom():
	await get_tree().process_frame
	$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value

func _on_close_pressed() -> void:
	close.emit()
