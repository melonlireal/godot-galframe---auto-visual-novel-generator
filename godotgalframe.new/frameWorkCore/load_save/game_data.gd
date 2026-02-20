extends Resource
class_name Gamedata
# this is the save data for game settings that 
# can be changed by player
@export var play_speed = 50
@export var auto_play_speed = 50
@export var red = 140
@export var green = 140
@export var blue = 140
@export var alpha = 70
@export var windows_color = Color(float(red)/255.0,float(green)/255.0,float(blue)/255.0,alpha/100.0)
@export var total_volumn = 1.0
@export var bgm_volumn = 1.0
@export var voice_volumn = 1.0
@export var sfx_volumn = 1.0
@export var dialogue_box_transparency = 100.0
@export var unlocked_cg = []

@export var saved_game = {"quick_save": null, "0": null, "1": null, "2": null, "3": null, 
"4": null, "5":null, "6":null, "7":null, "8": null, "9": null, "10": null, "11": null, "12": null, 
"13":null, "14":null, "15":null, "16":null, "17":null, "18":null, "19":null}
# saved_game 可能用不上 先留着
	
# WARNING ALL CODES HERE ARE SHIT

func reset_all():
	play_speed = 20
	auto_play_speed = 20
	red = 140
	green = 140
	blue = 140
	alpha = 70
	windows_color = Color(float(red)/255.0,float(green)/255.0,float(blue)/255.0,alpha/100.0)
	total_volumn = 1.0
	bgm_volumn = 1.0
	voice_volumn = 1.0
	sfx_volumn = 1.0
	dialogue_box_transparency = 100.0
	unlocked_cg = []
	
	
func reset_setting_display():
	windows_color = Color(140.0,140.0,140.0,200)

#func reset_setting():
	#play_speed = 50
	
func save_play_speed(speed: float):
	play_speed = speed
	
func save_auto_play_speed(speed: float):
	auto_play_speed = speed
	
func change_red(progress: float):
	red = progress
	windows_color = Color(red/255.0,green/255.0,blue/255.0,alpha/100.0)
	
func change_blue(progress: float):
	blue = progress
	windows_color = Color(red/255.0,green/255.0,blue/255.0,alpha/100.0)
	
func change_green(progress: float):
	green = progress
	windows_color = Color(red/255.0,green/255.0,blue/255.0,alpha/100.0)

func change_alpha(progress: float):
	alpha = progress
	windows_color = Color(red/255.0,green/255.0,blue/255.0,alpha/100.0)
	
func print_all():
	print(play_speed)
	print(auto_play_speed)
	print(red)
	print(green)
	print(blue)
	print(alpha)
	print(total_volumn)
	print(bgm_volumn)
	print(voice_volumn)
	print(sfx_volumn)
	print(dialogue_box_transparency)
	print(unlocked_cg)

	
	
	
