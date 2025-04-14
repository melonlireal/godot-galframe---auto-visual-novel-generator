extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	print(disect("{abc}"))
	print(disect("{ab{cd}}"))
	print(disect("{a{bc}d}e{fg}"))
	print(disect("{{{ab}}}"))
	print(disect("{a{b{c}d}}e{fg}"))
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func preprocess(words: String, formats: Array):
	var section = disect(words)
	if section ==[]:
		return words
	var processed = assemble(words, section, formats)
	return preprocess(processed, formats)

# seperate the input string by {} and return a list ordered by the
# location of {}, {} inside another {} comes later.
#abc ->[]
#{abc} -> [{abc}]
#{ab{cd}} -> [{ab{cd}}, {cd}]
#{a{bc}d}e{fg} -> [{a{bc}d}, {fg}, {bc}]
#{a{b{c}d}}e{fg} -> ["{a{b{c}d}}", "{fg}", "{b{c}d}", "{c}"]
# DO NOT USE REGREX
func disect(words: String):
	if words.find('{') == -1:
		return []
	var first_half = 0
	var second_half = 0
	var balance = 0
	var temp = "{"
	var result = []
	for character in words:
		if first_half > 0:
			temp = temp + character
		if character == '{':
			first_half += 1
			balance +=1
		elif character == '}':
			second_half +=1
			balance -=1
		if balance == 0 and first_half >0 and second_half > 0:
			# 形成一个最大的完整括号时放入数组
			result.append(temp)
			temp = "{"
			first_half = 0
			second_half = 0
	var temp2 = []
	for word in result:
		temp2.append_array(disect(str(word).substr(1, len(word) - 2)))
	result.append_array(temp2)
	return result
	
func assemble(ori_word: String, slice: Array, instruction: Array):
	var piece = slice.pop_front()
	var instruct_name = instruction.pop_front() 
	#先拿到要处理的
	pass
