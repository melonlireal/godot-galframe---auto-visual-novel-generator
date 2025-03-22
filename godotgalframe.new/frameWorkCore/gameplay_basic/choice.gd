extends TextureButton

signal travel_to(loaction: String)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _on_pressed():
	emit_signal("travel_to", $going_to.text)
