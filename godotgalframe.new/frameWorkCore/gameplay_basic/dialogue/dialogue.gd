extends RichTextLabel

signal dialogue_play_finished

var _duration: float = 0.0
var _elapsed: float = 0.0
var _playing: bool = false


func _ready():
	self.set_process(false)


func _process(delta):
	if not _playing:
		return
	_elapsed += delta
	if _duration <= 0.0 or _elapsed >= _duration:
		visible_ratio = 1.0
		_playing = false
		set_process(false)
		dialogue_play_finished.emit()
	else:
		visible_ratio = _elapsed / _duration


func play_dialogue(dialogue: String, duration: float):
	self.text = dialogue
	visible_ratio = 0.0
	_elapsed = 0.0
	_duration = duration
	_playing = true
	set_process(true)


func show_full():
	if not _playing:
		return
	visible_ratio = 1.0
	_playing = false
	set_process(false)
	dialogue_play_finished.emit()


func is_playing() -> bool:
	return _playing
