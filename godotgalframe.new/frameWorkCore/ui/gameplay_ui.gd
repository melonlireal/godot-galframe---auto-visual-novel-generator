extends CanvasLayer
class_name GameplayUI


# 子类必须覆写此函数，返回对应的 UIManager.UI 枚举值
func ui_key() -> UIManager.UI:
	assert(false, "%s must override ui_key()" % get_script().resource_path)
	return UIManager.UI.MAIN_UI


func _enter_tree() -> void:
	UIManager.register(ui_key(), self)


func _exit_tree() -> void:
	UIManager.unregister(ui_key())
