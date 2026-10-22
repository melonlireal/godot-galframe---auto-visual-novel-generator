extends Node	

# this script store global resources so all script dont have to redeclare


# setting save stores all external settings 
# that will be adjusted by user during gameplay
var setting_save_path: String = "user://save/player_setting_save.tres"
# global_progress contains players global progress, 
# such as chapters played cg unlocked, etc
var global_progress_path: String = "user://save/global_game_progress_save.tres"
# variables store initial variables that are compiled 
var variables_path: String = "res://save/variables.tres"
# cg_all stores all cg waiting to be unlockedave/cg.tres")
var cg_all_path: String = "res://save/cg.tres"
# color_all stores color for character text and is called to color text
var color_all_path: String = "res://save/color.tres"
# script tree stores compiled txt files that contain story and commands
var script_tree_path: String = "res://save/processed_script.tres"
# asset_map stores all path for asset and their names
var asset_map_path: String = "res://save/mapper_total.tres"
# gameplay setting stores all internal settings that are toggled in gameplay_setting_compile
var gameplay_setting_path: String = "res://save/internal_setting.tres"

var quick_save_path: String = "user://save/quick_save.tres"
# 存档截图保存目录（与 .tres 存档并列）
var save_screenshot_dir: String = "user://save/"

var setting_menu_UI_path: String = "res://frameWorkCore/settings/setting_menu.tscn"

var save_load_UI_path: String = "res://frameWorkCore/load_save/save_load_UI.tscn"

var save_background_texture_path: String = "res://artResource/UI_gameplay/setting_UI/save_background.png"
var load_background_texture_path: String = "res://artResource/UI_gameplay/setting_UI/load_background.png"
