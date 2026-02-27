extends Node	

# this script store global resources so all script dont have to redeclare


# setting save stores all external settings 
# that will be adjusted by user during gameplay
var setting_save_path = "user://save/player_setting_save.tres"
# global_progress contains players global progress, 
# such as chapters played cg unlocked, etc
var global_progress_path = "user://save/global_game_progress_save.tres"

# the resources below are all read only, they SHOULD NOT be written again
# variables store initial variables that are compiled 
var variables: Variables = ResourceLoader.load("res://save/variables.tres")
# cg_all stores all cg waiting to be unlockedave/cg.tres")
var cg_all:CGS  = ResourceLoader.load("res://save/cg.tres")
# color_all stores color for character text and is called to color text
var color_all:Colors = ResourceLoader.load("res://save/color.tres")
# script tree stores compiled txt files that contain story and commands
var script_tree:ScriptTree = ResourceLoader.load("res://save/processed_script.tres")
# asset_map stores all path for asset and their names
var asset_map:AssetPath = ResourceLoader.load("res://save/mapper_total.tres")
# gameplay setting stores all internal settings that are toggled in gameplay_setting_compile
var gameplay_setting:GameplaySetting = ResourceLoader.load("res://save/internal_setting.tres")
