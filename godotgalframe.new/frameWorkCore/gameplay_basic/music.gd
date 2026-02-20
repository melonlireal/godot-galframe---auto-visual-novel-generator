extends Node
var bgmlist = []
var sound_effect_list = []
var gameplay_setting:GameplaySetting = ResourceLoader.load("res://save/internal_setting.tres")
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
@export var auto_clear_bgm = gameplay_setting.get_setting("auto_clear_bgm")
@export var auto_clear_sound_effect = gameplay_setting.get_setting("auto_clear_sound_effect")
@export var auto_clear_voice = gameplay_setting.get_setting("auto_clear_voice")

	
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
		
func change_music(type: String, which: String):
	if which == "clear":
		music_clear(type)
		return
	if type == "bgm" and which in bgmlist:
		print("music already playing!\n")
		return
		# 如果当前某个BGM已经在播放，则不再重复播放
	if type == "sound_effect" and which in sound_effect_list:
		print("sound effect already playing!\n")
		return
	print("changing music\n")
		
	if type == "bgm":
		print("appending bgm to list\n")
		# 将bgm添加到播放缓存中
		bgmlist.append(which)
		print("new bgm list is ", bgmlist, "\n")
	if type == "sound_effect":
		print("appending sound effect to list\n")
		sound_effect_list.append(which)
		print("new sound effect list is ", sound_effect_list, "\n")
	if type == "voice":
		$"../review_dialogues".get_voice(which)
		# TODO SHIT CODE FIX ASAP
		var voice_at = asset_map.search_path(which) 
		var voice:AudioStream = ResourceLoader.load(voice_at)
		var voice_duration = voice.get_length()
		%dialogue.voicing_time = voice_duration
	for slot in self.find_child(type).get_children():
		if slot.stream == null:
			var music_at = asset_map.search_path(which)
			if music_at != null:
				slot.stream = ResourceLoader.load(music_at)
				slot.playing = true
			else:
				self.get_tree().call_group("errorlog", "music_error", which)
			return
	self.get_tree().call_group("errorlog", "music_error", which)
	
	
func music_clear(type: String):
	print("music cleared")
	if type == "bgm":
		bgmlist = []
	if type == "sound_effect":
		sound_effect_list = []
	for slot in self.find_child(type).get_children():
		slot.playing = false
		slot.stream = null
