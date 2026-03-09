extends Control
class_name CharacterSlot
# a character slot is in charge of storing character avatar in its designated 
# location and apply character effect when called.

@onready var character: TextureRect = $slot/character
@onready var character_back: TextureRect = $slot/character_back
var tween_list = []


func change_avatar(avatar: String):
	var avatar_at = GlobalResources.asset_map.search_path(avatar)
	if avatar_at == null:
		self.get_tree().call_group("errorlog", "character_error", avatar)
		print("error: unknown avatar ", avatar)
		return
	character.texture = ResourceLoader.load(avatar_at)
	
func clear_avatar():
	character.texture = null
	character_back.texture = null



func play_character_effects(steps):
	for tween:Tween in tween_list:
		tween.custom_step(9999)
		tween.kill()
	await _run_steps(steps)


func _run_steps(steps):
	for step in steps:
		# sequential step
		if step.size() == 1:
			await _run_action(step[0])
		# parallel step
		else:
			for action in step:
				call_deferred("_run_action", action)
			# wait one frame so they start together
			await get_tree().process_frame


func _run_action(action):
	var method = action[0]
	var args = action.slice(1)
	var tween = create_tween()
	tween_list.append(tween)
	var op = Callable(self, method)
	await op.call(tween, args)
	
	
func shake(tween:Tween, args: Array = []):
	var time = 0.2
	if len(args) > 0:
		time = int(args[0])
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default = offset_left
	tween.tween_property(self, "offset_left", offset_default + 100, time/4)
	tween.tween_property(self, "offset_left", offset_default, time/4)
	tween.tween_property(self, "offset_left", offset_default - 100, time/4)
	tween.tween_property(self, "offset_left", offset_default, time/4)
	await tween.finished
	
	
func jump(tween:Tween, args: Array = []):
	print("jump is played")
	var time = 0.2
	if len(args) > 0:
		time = int(args[0])
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default = offset_top
	tween.tween_property(self, "offset_top", offset_default - 200, time/2)
	tween.tween_property(self, "offset_top", offset_default, time/2)
	await tween.finished
	
	
func wait(tween:Tween, args: Array = []):
	var time = 1.0
	if len(args) > 0:
		time = int(args[0])
	tween.tween_interval(time)
	await tween.finished
	
	
func transit(tween: Tween, args: Array):
	character.modulate.a = 1
	var avatar_at = GlobalResources.asset_map.search_path(args[0])
	if not avatar_at:
		self.get_tree().call_group("errorlog", "character_error", args[0])
		return
	character_back.texture = ResourceLoader.load(avatar_at)
	tween.tween_property(character, "modulate:a", 0, 0.2)
	tween.tween_callback(func():
		character.texture = ResourceLoader.load(avatar_at)
		character.modulate.a = 1
		character_back.texture = null
	)
	await tween.finished


func dissappear(tween: Tween, args: Array):
	var time = 0.5
	if len(args) > 0:
		time = int(args[0])
	tween.tween_property(character, "modulate:a", 0, time)
	await tween.finished
	character.texture = null
	character.modulate.a = 1

func appear(tween:Tween, args: Array):
	character.modulate.a = 1
	var avatar_at = GlobalResources.asset_map.search_path(args[0])
	character.texture = ResourceLoader.load(avatar_at)
	tween.tween_property(character, "modulate:a", 1, 0.2)
	await tween.finished

#func _on_button_pressed() -> void:
	#print("pressed")
	#play_character_effects([
		#[["transit", "catxilinidleblush.png"], ["jump", 0.2]],
		#[["wait", 1.0]],
		#[["transit", "catxilinidleganga.png"]],
		#[["wait", 1.0]],
		#[["dissappear"]]
		#])
