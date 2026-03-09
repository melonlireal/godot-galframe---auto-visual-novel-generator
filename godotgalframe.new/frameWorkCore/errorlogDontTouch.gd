extends CanvasLayer

func _ready() -> void:
	self.visible = false
	

# Called when the node enters the scene tree for the first time.
func unknown_command(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：incorrect command {0} check your spelling".format({"0": type})
	
func character_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：unknown character avatar {0} check your spelling and file type (.jpg, .png)".format({"0": type})
	
func background_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：unknown background {0} check your spelling and file type (.jpg, .png)".format({"0": type})
	
func choice_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：unable to proceed to txt file {0} check your spelling".format({"0": type})
	
func music_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：unknown music {0} check your spelling".format({"0": type})
	
func character_effect_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：unknwon character effect {0} check your spelling".format({"0": type})
	
func background_effect_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR：unknown background effect {0} check your spelling".format({"0": type})
	
func variable_not_found(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR: unknown variable {0}, check your spelling".format({"0": type})
	
#func cg_header_error(type: String):
	#pass
	#
#func color_header_error(type: String):
	#pass
	#
#func variable_header_error(type: String):
	#pass
	#
#func game_call_error(type: String):
	#pass
