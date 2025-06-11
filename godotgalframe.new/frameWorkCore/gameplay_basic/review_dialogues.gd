extends CanvasLayer

@export var dialogues = []
@export var limit = 50
@export var narrator = "[color=434444]旁白[/color]"
var default_factor = 864
# this is the current difference between the max value to scroll and the 
# max value of v scroll bar
# subtract this when assigning container to bottom
var  curr_limit = 0
var line = {"character":"", "dialogue":"", "voice":""}
# Called when the node enters the scene tree for the first time.


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
	#print(line,"\n")
	#print("curr maxval is ", $ScrollContainer.get_v_scroll_bar().max_value, "\n")
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
	dialogues.append(script)
	line = {"character":"", "dialogue":"", "voice":""}
	var maxval = $ScrollContainer.get_v_scroll_bar().max_value
	#print("new maxval is ", $ScrollContainer.get_v_scroll_bar().max_value, "\n")
	$ScrollContainer.scroll_vertical = maxval - default_factor
	pass
	
func pop_line():
	dialogues.pop_front()
	
func play_voice(voice_at: String):
	$voice.stream = ResourceLoader.load(voice_at)
	$voice.playing = true
	pass
