extends Control
class_name CharacterSlot
# a character slot is in charge of storing character avatar in its designated 
# location and apply character effect when called.

@onready var character: TextureRect = $slot/character
@onready var character_back: TextureRect = $slot/character_back
var tween_list: Array[Tween] = []
var _asset_path_finder: AssetPath

func _ready():
	_asset_path_finder = ResourceLoader.load(GlobalResources.asset_map_path)

func change_avatar(avatar: String) -> void:
	var avatar_at: String = _asset_path_finder.search_path(avatar)
	if avatar_at == null:
		self.get_tree().call_group("errorlog", "character_error", avatar)
		print("error: unknown avatar ", avatar)
		return
	character.texture = ResourceLoader.load(avatar_at)
	
func clear_avatar() -> void:
	character.texture = null
	character_back.texture = null



func play_character_effects(steps: Array) -> void:
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


func finish_running_effects() -> void:
	for tween:Tween in tween_list:
		if tween.is_valid():
			tween.custom_step(9999)
	tween_list.clear()


func _run_action(action: Array) -> void:
	var method: String = action[0]
	var args: Array = action.slice(1)
	var tween: Tween = create_tween()
	tween_list.append(tween)
	var op = Callable(self, method)
	await op.call(tween, args)
	tween_list.erase(tween)
	
	
func shake(tween:Tween, args: Array = []) -> void:
	var time: float = 0.2
	if len(args) > 0:
		time = float(args[0])
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default: float = offset_left
	tween.tween_property(self, "offset_left", offset_default + 30, time/4)
	tween.tween_property(self, "offset_left", offset_default, time/4)
	tween.tween_property(self, "offset_left", offset_default - 30, time/4)
	tween.tween_property(self, "offset_left", offset_default, time/4)
	await tween.finished
	
	
func jump(tween:Tween, args: Array = []) -> void:
	var time: float = 0.2
	if len(args) > 0:
		time = float(args[0])
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default: float = offset_top
	tween.tween_property(self, "offset_top", offset_default - 10, time/2)
	tween.tween_property(self, "offset_top", offset_default, time/2)
	await tween.finished
	

func nod(tween:Tween, args: Array = []) -> void:
	var time: float = 0.2
	if len(args) > 0:
		time = float(args[0])
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default: float = offset_top
	tween.tween_property(self, "offset_top", offset_default + 10, time/2)
	tween.tween_property(self, "offset_top", offset_default, time/2)
	await tween.finished
	
		
func tiltleft(tween:Tween, args: Array = []) -> void:
	var time: float = 0.5
	if len(args) > 0:
		time = float(args[0])
	var offset_default: float = rotation_degrees
	tween.tween_property(self, "rotation_degrees", offset_default + 1.0, time/2)
	tween.tween_property(self, "rotation_degrees", offset_default, time/2)
	await tween.finished
	

func tiltright(tween:Tween, args: Array = []) -> void:
	var time: float = 0.5
	if len(args) > 0:
		time = float(args[0])
	var offset_default: float = rotation_degrees
	tween.tween_property(self, "rotation_degrees", offset_default - 1.0, time/2)
	tween.tween_property(self, "rotation_degrees", offset_default, time/2)
	await tween.finished
	
	
func wait(tween:Tween, args: Array = []) -> void:
	var time: float = 1.0
	if len(args) > 0:
		time = float(args[0])
	tween.tween_interval(time)
	await tween.finished
	
	
func transit(tween: Tween, args: Array) -> void:
	character.modulate.a = 1
	var avatar_at: String = _asset_path_finder.search_path(args[0])
	if not avatar_at:
		self.get_tree().call_group("errorlog", "character_error", args[0])
		return
	var avatar_texture: Texture2D = ResourceLoader.load(avatar_at)
	character_back.texture = avatar_texture
	tween.tween_property(character, "modulate:a", 0, 0.2)
	tween.tween_callback(func():
		character.texture = avatar_texture
		character.modulate.a = 1
		character_back.texture = null
	)
	await tween.finished


func disappear(tween: Tween, args: Array) -> void:
	var time: float = 0.5
	if len(args) > 0:
		time = float(args[0])
	tween.tween_property(character, "modulate:a", 0, time)
	await tween.finished
	character.texture = null
	character.modulate.a = 1

func appear(tween:Tween, args: Array) -> void:
	character.modulate.a = 0
	var avatar_at: String = _asset_path_finder.search_path(args[0])
	character.texture = ResourceLoader.load(avatar_at)
	tween.tween_property(character, "modulate:a", 1, 0.2)
	await tween.finished


#func _on_button_pressed() -> void:
	##print("pressed")
	#play_character_effects([
		#[["transit", "midieshouerweixiao.png"], ["jump", 0.2]],
		#[["wait", 1.0]],
		#[["transit", "midieshouershengqi.png"]],
		#[["wait", 1.0]],
		#[["jump", 0.2]],
		#[["dissappear"]]
		#])
