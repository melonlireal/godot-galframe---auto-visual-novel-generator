extends Control
class_name CharacterSlot
# a character slot is in charge of storing character avatar in its desginated 
# location and apply character effect when called.

@onready var character: TextureRect = $slot/character
@onready var character_back: TextureRect = $slot/character_back
var slot_tween:Tween

# Called when the node enters the scene tree for the first time.
func _process(delta: float) -> void:
	print(character.modulate.a)

func change_avatar(avatar: String):
	var avatar_at = GlobalResources.asset_map.search_path(avatar)
	if avatar_at == null:
		self.get_tree().call_group("errorlog", "character_error", avatar)
		print("error: unknown avatar ", avatar)
		return
	character.texture = ResourceLoader.load(avatar_at)

func end_tween():
	if slot_tween != null:
		slot_tween.custom_step(9999)
		slot_tween.kill()
		
func play_character_effects(args):
	if slot_tween:
		end_tween()
	slot_tween = create_tween()
	for arg in args:
		if len(arg) == 1:
			slot_tween.set_parallel(false)
		else:
			# enable parallel when multiple animation will execute at same time
			slot_tween.set_parallel(true) 
		for actions in arg: 
			var op = Callable(self, actions[0])
			op.call(slot_tween, actions.slice(1))
		
func shake(tween:Tween, args: Array = []):
	var time = 0.2
	if len(args) > 0:
		time = args[0]
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default = offset_left
	tween.tween_property(self, "offset_left", offset_default + 100, time/4)
	tween.tween_property(self, "offset_left", offset_default, time/4)
	tween.tween_property(self, "offset_left", offset_default - 100, time/4)
	tween.tween_property(self, "offset_left", offset_default, time/4)
	
func jump(tween:Tween, args: Array = []):
	var time = 0.2
	if len(args) > 0:
		time = args[0]
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	var offset_default = offset_top
	tween.tween_property(self, "offset_top", offset_default - 200, time/2)
	tween.tween_property(self, "offset_top", offset_default, time/2)

func wait(tween:Tween, args: Array = []):
	var time = 1.0
	if len(args) > 0:
		time = args[0]
	tween.tween_interval(time)

func transit(tween: Tween, args: Array):
	character_back.modulate.a = 1
	var avatar_at = GlobalResources.asset_map.search_path(args[0])
	character_back.texture = ResourceLoader.load(avatar_at)
	tween.tween_property(character, "modulate:a", 0, 0.2)
	tween.tween_callback(func():
		character.texture = ResourceLoader.load(avatar_at)
		character.modulate.a = 1
		character_back.texture = null
	)

func dissapper(tween: Tween, args: Array):
	var time = 0.5
	if len(args) > 0:
		time = args[0]
	tween.tween_property(character, "modulate:a", 0, time)

func _on_button_pressed() -> void:
	play_character_effects([[["transit", "test1.png"]], [["transit", "test2.png"]]])
