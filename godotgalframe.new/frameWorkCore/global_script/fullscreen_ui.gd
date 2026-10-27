extends CanvasLayer
class_name FullscreenUI


func ui_key() -> UIManager.UI:
	assert(false, "%s must override ui_key()" % get_script().resource_path)
	return UIManager.UI.REVIEW_DIALOGUE


func _enter_tree() -> void:
	UIManager.register(ui_key(), self)


func _exit_tree() -> void:
	UIManager.unregister(ui_key())
