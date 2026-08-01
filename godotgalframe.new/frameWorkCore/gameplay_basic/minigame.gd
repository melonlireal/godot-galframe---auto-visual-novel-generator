extends CanvasLayer

@onready var avatar: CanvasLayer = %avatar
@onready var dialogue_controller: DialogueController = $"../dialogue_controller"
@onready var ui: CanvasLayer = $"../UI"
@onready var background: CanvasLayer = %background


func add_game(game_name: String):
	var path = "res://frameWorkCore/mini_games/" + game_name + ".tscn"
	var game = load(path)
	var loaded_game = game.instantiate()
	avatar.clear_all_avatar()
	dialogue_controller.visible = false
	ui.visible = false
	background.visible = false
	get_parent().add_child(loaded_game)
	loaded_game.end_game.connect(end_game)


func end_game(next_chap: String):
	# will remove ALL mini_game
	# and continue dialogue from the given chapter
	# this is NOT INCHARGE of saving mini game progress
	dialogue_controller.visible = true
	ui.visible = true
	background.visible = true
	for child in self.get_children():
		child.queue_free()
	get_parent().travel_to_chapter(next_chap)
	pass
