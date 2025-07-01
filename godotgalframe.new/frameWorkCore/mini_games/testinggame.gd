extends Node2D
var times = 0
signal end_game
@export var next_chap = "proceed.txt"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Label.text = "0"


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_button_pressed() -> void:
	times += 1
	if times >= 10:
		end_game.emit(next_chap)
	$CanvasLayer/Label.text = str(times)
	
