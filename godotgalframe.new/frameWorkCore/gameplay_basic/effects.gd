extends CanvasLayer


# Called when the node enters the scene tree for the first time

# the following functions are for transitions
# WARNING a new background command must be placed after a transition command

func fadeout():
		$"../UI".visible = false
		$"../dialogue".visible = false
		%dialogue.set_process(false)
		$"..".can_press = false
		%avatar.clear_all_avatar()
		%avatar.visible = false;
		$effect_assets/black.visible = true
		$"..".speed_up = false
		var transit = get_tree().create_tween().bind_node($effect_assets/blac)
		transit.tween_property($effect_assets/black, "modulate:a", 1, 0.5)
		await transit.finished
		%avatar.visible = true
		$"..".proceed()
		var transit2 = get_tree().create_tween().bind_node($effect_assets/blac)
		transit2.tween_property($effect_assets/black, "modulate:a", 0, 1)
		await transit2.finished
		$"../UI".visible = true
		$"../dialogue".visible = true
		$"..".can_press = true
		%dialogue.set_process(true)
		$effect_assets/black.visible = false

func flash():
		$"../UI".visible = false
		$"../dialogue".visible = false
		%dialogue.set_process(false)
		$"..".can_press = false
		%avatar.clear_all_avatar()
		$effect_assets/white.visible = true
		$"..".speed_up = false
		var transit = get_tree().create_tween().bind_node($effect_assets/white)
		transit.tween_property($effect_assets/white, "modulate:a", 1, 0.5)
		await transit.finished
		$"..".proceed()
		var transit2 = get_tree().create_tween().bind_node($effect_assets/white)
		transit2.tween_property($effect_assets/white, "modulate:a", 0, 1)
		await transit2.finished
		$"../UI".visible = true
		$"../dialogue".visible = true
		$"..".can_press = true
		%dialogue.set_process(true)
		$effect_assets/white.visible = false
