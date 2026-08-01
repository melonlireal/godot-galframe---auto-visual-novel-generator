extends Node
var bgmlist = []
var gameplay_setting = ResourceLoader.load(GlobalResources.gameplay_setting_path)
var auto_clear_bgm = gameplay_setting.get_setting("auto_clear_bgm")
var auto_clear_sound_effect = gameplay_setting.get_setting("auto_clear_sound_effect")
var auto_clear_voice = gameplay_setting.get_setting("auto_clear_voice")

# 最近一次 change_voice 设置的配音时长（秒）；供 controller 计算 AUTOPLAY 句间等待用
var last_voice_duration: float = 0.0


func _ready():
	# 把各音乐总线节点指到对应 bus 上
	for bgm in $bgm.get_children():
		bgm.set_bus("bgm")
	for voice in $voice.get_children():
		voice.set_bus("voice")
	for sfx in $sound_effect.get_children():
		sfx.set_bus("sfx")


	
#TODO implement a feature that allows user to choose whether only
# clear bgm/sound_effect/music when there is a new one
# or always clear it each line
func next_line():
	if auto_clear_bgm:
		music_clear("bgm")
	if auto_clear_sound_effect:
		music_clear("sound_effect")
	if auto_clear_voice:
		music_clear("voice")
		
		
func change_bgm(bgm_commands: Array):
	for bgm_command in bgm_commands:
		var which_bgm = bgm_command[0]
		if which_bgm == "clear":
			music_clear("bgm")
			continue
		if which_bgm in bgmlist:
			print("music already playing!\n")
			return
		bgmlist.append(which_bgm)
		add_music_to_slot("bgm", which_bgm)
	
	
func change_sound_effect(sound_effect_commands: Array):
	for sound_effect_command in sound_effect_commands:
		var which_sound_effect = sound_effect_command[0]
		if which_sound_effect == "clear":
			music_clear("sound_effect")
			continue
		add_music_to_slot("sound_effect", which_sound_effect)


func change_voice(voice_commands: Array):
	for voice_command in voice_commands:
		var which_voice = voice_command[0]
		if which_voice == "clear":
			last_voice_duration = 0.0
			music_clear("voice")
			continue
		var asset_path_finder:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)
		var voice_at = asset_path_finder.search_path(which_voice)
		if not voice_at:
			GlobalSignals.music_error.emit(which_voice)
			return
		var voice:AudioStream = ResourceLoader.load(voice_at)
		last_voice_duration = voice.get_length()
		add_music_to_slot("voice", which_voice)
	
	
func add_music_to_slot(type: String, which: String):
	for slot in self.find_child(type).get_children():
		if slot.stream == null:
			var asset_path_finder:AssetPath = ResourceLoader.load(GlobalResources.asset_map_path)
			var music_at = asset_path_finder.search_path(which)
			if music_at != null:
				slot.stream = ResourceLoader.load(music_at)
				slot.playing = true
			else:
				GlobalSignals.music_error.emit(which)
			return
	GlobalSignals.music_error.emit(which)
	

func music_clear(type: String):
	print("music cleared")
	if type == "bgm":
		bgmlist = []
	for slot in self.find_child(type).get_children():
		slot.playing = false
		slot.stream = null
