extends CanvasLayer
var avatar_cleared: bool = false
var avatar_list: Array[String] = []
	
func update_art_list(orders: Array) -> void:
	avatar_list = []
	for order in orders:
		if order[0] != GlobalType.COMMAND_CLEAR:
			avatar_list.append(str(order[1]))
	return
	
func execute_avatar_effects(effect_commands: Array) -> void:
	for effect_command:Array in effect_commands:
		var slot: String = effect_command[0]
		var effects: Array = effect_command.slice(1)
		var which_slot:CharacterSlot = self.find_child(slot)
		which_slot.play_character_effects(effects)


func finish_avatar_effects() -> void:
	for child:CharacterSlot in self.get_children():
		child.finish_running_effects()
	
func change_avatars(avatar_commands: Array) -> void:
	for avatar_command in avatar_commands:
		var avatar_name: String = avatar_command[0]
		var avatar_location: String = avatar_command[1]
		# used to clear all avatar
		if avatar_name == GlobalType.COMMAND_CLEAR:
			clear_all_avatar()
			return
		avatar_clear()
		var which_slot:CharacterSlot = self.find_child(avatar_location)
		which_slot.change_avatar(avatar_name)

func clear_all_avatar() -> void:
	print("clear all avatar")
	avatar_list = []
	for child:CharacterSlot in self.get_children():
		child.clear_avatar()
	return
				
func avatar_clear() -> void:
	# clear all avatar that are not going to be "replaced" by next line of commands
	print("avatar list is ", avatar_list, "\n")
	for child:CharacterSlot in self.get_children():
		if child.name not in avatar_list:
			print(str(child.name), " not in avatar list\n")
			child.clear_avatar()
	return
