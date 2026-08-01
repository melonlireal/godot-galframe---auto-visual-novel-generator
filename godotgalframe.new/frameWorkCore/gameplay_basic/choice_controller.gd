extends CanvasLayer
class_name ChoiceController

signal chapter_changed(location: String)

var script_tree: ScriptTree

@onready var choice_box: FlowContainer = $choice_box


func choice_jump(variables: Variables) -> bool:
	var choice_list = _check_choice_condition(script_tree.get_choices(), variables)
	# TODO what if creator wish to display choices but as locked?
	if choice_list.is_empty():
		# error checking code that shouldn't be triggered
		return false
	var option_scene = preload("res://frameWorkCore/gameplay_basic/choice.tscn")
	for choice_option in choice_list:
		var ready_option: Choice = option_scene.instantiate()
		ready_option.choice_description = choice_option[0]
		ready_option.travel_chapter = choice_option[1]
		choice_box.add_child(ready_option)
		ready_option.travel_to_new_chap.connect(travel_to_new_chapter)
	if choice_list.size() == 1 and choice_list[0][2] == "true":
		# 只有一个选项且 auto jump，直接跳转
		travel_to_new_chapter(choice_list[0][1])
		return true
	return true


func _check_choice_condition(choices: Array, variables: Variables) -> Array:
	var new_choices = []
	for choice_option in choices:
		if choice_option.size() <= 3:
			# 选项没有条件
			new_choices.append(choice_option)
		else:
			if variables.var_con(choice_option[3], choice_option[4], choice_option[5]):
				new_choices.append(choice_option)
	return new_choices


func travel_to_new_chapter(location: String):
	script_tree.change_chapter(location)
	clear_choices()
	chapter_changed.emit(location)


func clear_choices():
	for child in choice_box.get_children():
		child.queue_free()
