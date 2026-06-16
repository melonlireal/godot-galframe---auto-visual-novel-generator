extends CanvasLayer

func _ready() -> void:
	self.visible = false
	GlobalSignals.unknown_command_error.connect(unknown_command_error)
	GlobalSignals.character_error.connect(character_error)
	GlobalSignals.background_error.connect(background_error)
	GlobalSignals.choice_error.connect(choice_error)
	GlobalSignals.music_error.connect(music_error)
	GlobalSignals.character_effect_error.connect(character_effect_error)
	GlobalSignals.background_effect_error.connect(background_effect_error)
	GlobalSignals.variable_not_found_error.connect(variable_not_found_error)
	GlobalSignals.game_call_error.connect(game_call_error)
	

# Called when the node enters the scene tree for the first time.
func unknown_command_error(type: String):
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
	%errorlog.text = "ERROR：unable to proceed to chapter file {0} check your spelling".format({"0": type})
	
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
	
func variable_not_found_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR: unknown variable {0}, check your spelling".format({"0": type})
	
func game_call_error(type: String):
	self.visible = true
	$Panel.visible = true
	%errorlog.text = "ERROR: unknown game scene {0}, check your spelling".format({"0": type})
