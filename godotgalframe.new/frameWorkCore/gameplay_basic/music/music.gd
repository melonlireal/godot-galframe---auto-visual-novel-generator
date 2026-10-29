extends Node
var bgmlist: Array[String] = []
var gameplay_setting: GameplaySetting = ResourceLoader.load(GlobalResources.gameplay_setting_path)
var auto_clear_bgm: bool = gameplay_setting.get_setting("auto_clear_bgm")
var auto_clear_sound_effect: bool = gameplay_setting.get_setting("auto_clear_sound_effect")
var auto_clear_voice: bool = gameplay_setting.get_setting("auto_clear_voice")

var _asset_path_finder: AssetPath


# 最近一次 change_voice 设置的配音时长（秒）；供 controller 计算 AUTOPLAY 句间等待用
var last_voice_duration: float = 0.0


func _ready():
	_asset_path_finder = ResourceLoader.load(GlobalResources.asset_map_path)
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
func next_line() -> void:
	if auto_clear_bgm:
		music_clear("bgm")
	if auto_clear_sound_effect:
		music_clear("sound_effect")
	if auto_clear_voice:
		music_clear("voice")
		
		
func change_bgm(bgm_commands: Array) -> void:
	for bgm_command in bgm_commands:
		var which_bgm: String = bgm_command[0]
		if which_bgm == GlobalType.COMMAND_CLEAR:
			music_clear("bgm")
			continue
		if which_bgm in bgmlist:
			print("music already playing!\n")
			continue
		bgmlist.append(which_bgm)
		add_music_to_slot("bgm", which_bgm)
	
	
func change_sound_effect(sound_effect_commands: Array) -> void:
	for sound_effect_command in sound_effect_commands:
		var which_sound_effect: String = sound_effect_command[0]
		if which_sound_effect == GlobalType.COMMAND_CLEAR:
			music_clear("sound_effect")
			continue
		add_music_to_slot("sound_effect", which_sound_effect)


func change_voice(voice_commands: Array) -> void:
	for voice_command in voice_commands:
		var which_voice: String = voice_command[0]
		if which_voice == GlobalType.COMMAND_CLEAR:
			last_voice_duration = 0.0
			music_clear("voice")
			continue
		var voice_at = _asset_path_finder.search_path(which_voice)
		if not voice_at:
			GlobalSignals.music_error.emit(which_voice)
			return
		var voice: AudioStream = ResourceLoader.load(voice_at)
		last_voice_duration = voice.get_length()
		# 直接将已加载的 stream 放入空槽，避免 add_music_to_slot 再次 load
		for slot in self.find_child("voice").get_children():
			if slot.stream == null:
				slot.stream = voice
				slot.playing = true
				return
		GlobalSignals.music_error.emit(which_voice)
	
	
func add_music_to_slot(type: String, which: String) -> void:
	for slot in self.find_child(type).get_children():
		if slot.stream == null:
			var music_at = _asset_path_finder.search_path(which)
			if music_at != null:
				slot.stream = ResourceLoader.load(music_at)
				slot.playing = true
			else:
				GlobalSignals.music_error.emit(which)
			return
	GlobalSignals.music_error.emit(which)
	

func music_clear(type: String) -> void:
	print("music cleared")
	if type == "bgm":
		bgmlist = []
	for slot in self.find_child(type).get_children():
		slot.playing = false
		slot.stream = null
