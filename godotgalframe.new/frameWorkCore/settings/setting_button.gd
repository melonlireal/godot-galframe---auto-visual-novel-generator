extends Button
@onready var is_getting_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$focus.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _clear():
	if is_getting_pressed:
		is_getting_pressed = false
		return
	self.disabled = false
	$focus.visible = false
	
func _on_pressed():
	is_getting_pressed = true
	get_tree().call_group("button", "_clear")
	self.disabled = true
	$focus.visible = true
