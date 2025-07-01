extends CanvasLayer


# Called when the node enters the scene tree for the first time.

func add_game(game_name: String):
	var path = "res://frameWorkCore/mini_games/" + game_name + ".tscn"
	var game = load(path)
	var loaded_game = game.instantiate()
	$"../music".music_clear("bgm")
	$"../music".music_clear("sound_effect")
	$"../music".music_clear("voice")
	%avatar.clear_all_avatar()
	$"../dialogue".visible = false
	$"../UI".visible = false
	%background.visible = false
	$".".add_child(loaded_game)
	loaded_game.end_game.connect(end_game)


func end_game(next_chap: String):
	# will remove ALL mini_game 
	# and continue dialogue from the given chapter  
	# this is NOT INCHARGE of saving mini game progress
	$"../dialogue".visible = true
	$"../UI".visible = true
	%background.visible = true
	for child in self.get_children():
		child.queue_free()
	$"..".travel(next_chap)
	pass
