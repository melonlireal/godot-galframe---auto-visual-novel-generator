extends Node


enum UI {
	# GAMEPLAY 层（常驻，随游戏一直在场景树里）
	MAIN_UI,
	DIALOGUE,
	CHOICE,
	# FULLSCREEN 层（常驻，打开时隐藏 GAMEPLAY 层）
	REVIEW_DIALOGUE,
	STORY_TREE,
	# POPUP 层（动态实例化，关闭时销毁）
	SAVE_LOAD,
	SETTING,
	CG_DISPLAY,
}

# POPUP 层的场景路径，其余 UI 是常驻节点，通过 register 注册
const UI_SCENE := {
	UI.SAVE_LOAD:   "res://frameWorkCore/load_save/save_load_UI.tscn",
	UI.SETTING:     "res://frameWorkCore/settings/setting_menu.tscn",
	UI.CG_DISPLAY:  "res://frameWorkCore/art/cg_display.tscn",
}

# 常驻节点注册表：key → 节点引用
var _registry: Dictionary = {}

var _popup_stack: Array[PopupUI] = []
var _hidden_gameplay: Array[GameplayUI] = []
# TODO: popup 临时挂载在 main_scene/UI 节点下，需要更合理的方案
var _popup_root: Node = null


func set_popup_root(node: Node) -> void:
	_popup_root = node


# ── 注册 / 注销 ───────────────────────────────────────────────
# 常驻 UI 节点在 _enter_tree() 里调用，传入对应的枚举 key

func register(key: UI, node: CanvasLayer) -> void:
	_registry[key] = node


func unregister(key: UI) -> void:
	_registry.erase(key)


# ── 统一开关 API ──────────────────────────────────────────────

func open(key: UI, params: Dictionary = {}) -> void:
	# POPUP 层：动态实例化
	if UI_SCENE.has(key):
		assert(_popup_root != null, "UIManager: popup_root is not set")
		var instance: PopupUI = load(UI_SCENE[key]).instantiate()
		for k in params:
			instance.set(k, params[k])
		_popup_root.add_child(instance)
		_popup_stack.push_back(instance)
		GlobalSignals.ui_opened.emit()
		return
	# GAMEPLAY / FULLSCREEN 层：常驻节点
	var node: CanvasLayer = _registry.get(key)
	if node == null:
		push_error("UIManager.open: key %s not registered" % UI.keys()[key])
		return
	if node is FullscreenUI:
		_hidden_gameplay.clear()
		for k in _registry:
			var n: CanvasLayer = _registry[k]
			if n is GameplayUI and n.visible:
				_hidden_gameplay.append(n)
				n.hide()
		node.show()
		GlobalSignals.ui_opened.emit()
	else:
		node.show()


func close(key: UI) -> void:
	# POPUP 层：从栈里找到对应 key 的节点关闭
	if UI_SCENE.has(key):
		for i in range(_popup_stack.size() - 1, -1, -1):
			var node: PopupUI = _popup_stack[i]
			if is_instance_valid(node) and node.ui_key() == key:
				_popup_stack.remove_at(i)
				node.queue_free()
				break
		if _popup_stack.is_empty():
			GlobalSignals.ui_closed.emit()
		return
	# GAMEPLAY / FULLSCREEN 层：常驻节点
	var node: CanvasLayer = _registry.get(key)
	if node == null:
		push_error("UIManager.close: key %s not registered" % UI.keys()[key])
		return
	if node is FullscreenUI:
		node.hide()
		for n in _hidden_gameplay:
			if is_instance_valid(n):
				n.show()
		_hidden_gameplay.clear()
		GlobalSignals.ui_closed.emit()
	else:
		node.hide()


func is_open(key: UI) -> bool:
	if UI_SCENE.has(key):
		return not _popup_stack.is_empty() and _popup_stack.back() != null
	var node: CanvasLayer = _registry.get(key)
	if node == null:
		return false
	return node.visible


func hide_gameplay() -> void:
	for k in _registry:
		var n: CanvasLayer = _registry[k]
		if n is GameplayUI and n.visible:
			n.hide()


func show_gameplay() -> void:
	for k in _registry:
		var n: CanvasLayer = _registry[k]
		if n is GameplayUI:
			n.show()
