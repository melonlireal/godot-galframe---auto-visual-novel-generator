extends CanvasLayer
class_name PopupUI


# 子类必须覆写此函数，返回对应的 UIManager.UI 枚举值
func ui_key() -> UIManager.UI:
	assert(false, "%s must override ui_key()" % get_script().resource_path)
	return UIManager.UI.SAVE_LOAD
