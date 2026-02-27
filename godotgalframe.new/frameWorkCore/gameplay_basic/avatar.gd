extends CanvasLayer
var avatar_cleared = false
var avatar_list = []

#func _ready():
	#$"..".update_art_list.connect(update_art_list)
	#$"..".clear_all_avatar.connect(clear_all_avatar)
	#pass
	
func update_art_list(orders: Array):
	avatar_list = []
	for order in orders:
		if order[0] == "character" and order[1] != "clear":
			avatar_list.append(str(order[2] + order[3]))
	return
	
func change_avatar(avatar: String, position = "mid", slot: = "character", transition = "false"):
	print("changing avatar\n")
	if avatar == "clear":
		print("clearing all avatar\n")
		clear_all_avatar()
		return
	# 这个用来自动清理人物画像, 如果想做出某个台词下所有立绘消失的效果就用这个
	avatar_clear()
	var avatar_at = GlobalResources.asset_map.search_path(avatar)
	if avatar_at == null:
		self.get_tree().call_group("errorlog", "character_error", avatar)
		print("error: unknown avatar ", avatar)
		return
	print(position)
	print(slot)
	var which_slot:TextureRect = %avatar.find_child(position).find_child(slot)
	#这个会自动清除
	if which_slot.texture != null and which_slot.texture.resource_path.get_file() == avatar:
		# if its the same avatar, do nothing
		return
	if transition == "false" or $"..".speed_up:
		which_slot.texture = ResourceLoader.load(avatar_at)
	else:
		#WARNING
		#this STUPID PIECE OF SHIT will NOT work when the avatar size is too big
		%avatar.find_child(position + "back").find_child(slot).texture = ResourceLoader.load(avatar_at)
		avatar_list.append(position + "back" + slot)
		# place the new avatar "behind" the current avatar
		var transit = get_tree().create_tween().bind_node(which_slot)
		transit.tween_property(which_slot, "modulate:a", 0, 0.2)
		await transit.finished
		which_slot.texture = ResourceLoader.load(avatar_at)
		which_slot.modulate.a = 1
		%avatar.find_child(position + "back").find_child(slot).texture = null

func clear_all_avatar():
	print("clear all avatar")
	avatar_list = []
	for child in %avatar.get_children():
		for box in child.get_children():
			if box.texture != null:
				box.texture = null
	return
				
func avatar_clear():
	# clear all avatar that are not going to be "replaced" by next line of commands
	print("avatar list is ", avatar_list, "\n")
	for child in %avatar.get_children():
		for box in child.get_children():
			if box.texture != null and str(child.name)+str(box.name) not in avatar_list:
				print(str(child.name)+str(box.name), " not in avatar list\n")
				box.texture = null
	return


func animations(which_pos):
	pass
