extends CanvasLayer

@onready var effect_black: ColorRect = $effect_assets/black
@onready var effect_white: ColorRect = $effect_assets/white


func execute_transition(transitions: Array) -> void:
	for t in transitions:
		var effect_name: String = t[0]
		if self.has_method(effect_name):
			Callable(self, effect_name).call()
			return


func fadeout() -> void:
	GlobalSignals.pause_game_interaction.emit()
	var transit = create_tween()
	transit.tween_property(effect_black, "color:a", 1, 0.5)
	await transit.finished
	GlobalSignals.play_next_line.emit()
	var transit2 = create_tween()
	transit2.tween_property(effect_black, "color:a", 0, 1)
	await transit2.finished
	GlobalSignals.unpause_game_interaction.emit()


func flash() -> void:
	GlobalSignals.pause_game_interaction.emit()
	var transit = get_tree().create_tween().bind_node(effect_white)
	transit.tween_property(effect_white, "color:a", 1, 0.5)
	await transit.finished
	GlobalSignals.play_next_line.emit()
	var transit2 = get_tree().create_tween().bind_node(effect_white)
	transit2.tween_property(effect_white, "color:a", 0, 0.5)
	await transit2.finished
	GlobalSignals.unpause_game_interaction.emit()
