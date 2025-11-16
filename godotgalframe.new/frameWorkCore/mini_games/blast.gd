extends Node2D
@onready var order = []
signal end_game
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if %rune1.disabled and %rune2.disabled and %rune3.disabled:
		if order == [1,2,3]:
			print("success")
			end_game.emit("success.txt")
		else:
			order = []
			%rune1.disabled = false
			%rune2.disabled = false
			%rune3.disabled = false


func _on_rune_2_pressed() -> void:
	print("press 2")
	%rune2.disabled = true
	order.append(2)


func _on_rune_1_pressed() -> void:
	print("press 1")
	%rune1.disabled = true
	order.append(1)


func _on_rune_3_pressed() -> void:
	print("press 3")
	%rune3.disabled = true
	order.append(3)


func _on_timer_timeout() -> void:
	end_game.emit("fail.txt")
