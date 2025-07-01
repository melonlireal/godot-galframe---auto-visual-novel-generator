extends CanvasLayer
var save_path

# Called when the node enters the scene tree for the first time.
func _ready():
	load_setting()
	%windows.disabled = true
	%fullscreen.disabled = false
	$options/display._on_pressed()
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func load_setting():
	for node in $settings.get_children():
		node.load_value()
	
	
func set_default():
	pass

func _on_return_button_down():
	self.queue_free()


func _on_display_pressed():
	$settings/volumn_setting.visible = false
	$settings/game_play_setting.visible = false
	$settings/display_setting.visible = true

func _on_volumn_pressed():
	$settings/display_setting.visible = false
	$settings/game_play_setting.visible = false
	$settings/volumn_setting.visible = true


func _on_play_pressed():
	$settings/volumn_setting.visible = false
	$settings/display_setting.visible = false
	$settings/game_play_setting.visible = true
