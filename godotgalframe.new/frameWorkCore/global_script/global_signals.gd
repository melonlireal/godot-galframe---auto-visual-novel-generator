extends Node


signal load_game_progress(game_progress:CurrGameProgress)
signal game_created
signal start_game

signal close_ui #called when any UI is closed
signal pause_game_interaction
signal unpause_game_interaction
signal back_to_menu

signal unknown_command_error(type: String)
signal character_error(type: String)
signal background_error(type: String)
signal choice_error(type: String)
signal music_error(type: String)
signal character_effect_error(type: String)
signal background_effect_error(type: String)
signal variable_not_found_error(type: String)
signal game_call_error(type: String)

signal minigame_edit_var(variable:Variables)
signal minigame_force_load_chap(which_chap: String, which_line: int, variables: Variables)
signal minigame_force_save(which_chap: String, which_line: int, variables: Variables, which_save_slot: int)
# Called when the node enters the scene tree for the first time.
	
	
