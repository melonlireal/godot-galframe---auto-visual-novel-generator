extends CanvasLayer
var avatar_cleared = false
var avatar_list = []
	
func update_art_list(orders: Array):
	avatar_list = []
	for order in orders:
		if order[0] != "clear":
			avatar_list.append(str(order[1]))
	return
	
func execute_avatar_effects(effect_commands: Array):
	for effect_command:Array in effect_commands:
		var slot = effect_command[0]
		var effects = effect_command.slice(1)
		var which_slot:CharacterSlot = self.find_child(slot)
		which_slot.play_character_effects(effects)
	pass
	
func change_avatars(avatar_commands: Array):
	for avatar_command in avatar_commands:
		var avatar_name = avatar_command[0]
		var avatar_location = avatar_command[1]
		# used to clear all avatar
		if avatar_name == "clear":
			print("clearing all avatar\n")
			clear_all_avatar()
			return
		avatar_clear()
		var which_slot:CharacterSlot = self.find_child(avatar_location)
		which_slot.change_avatar(avatar_name)

func clear_all_avatar():
	print("clear all avatar")
	avatar_list = []
	for child:CharacterSlot in %avatar.get_children():
		child.clear_avatar()
	return
				
func avatar_clear():
	# clear all avatar that are not going to be "replaced" by next line of commands
	print("avatar list is ", avatar_list, "\n")
	for child:CharacterSlot in %avatar.get_children():
		if child.name not in avatar_list:
			print(str(child.name), " not in avatar list\n")
			child.clear_avatar()
	return
