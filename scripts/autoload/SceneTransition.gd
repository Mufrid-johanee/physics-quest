extends Node
## Reusable fade + scene change. Does not wipe GameState.

signal transition_started(path: String)
signal transition_finished(path: String)

@export var fade_duration: float = 0.35

var _busy: bool = false
var _layer: CanvasLayer
var _rect: ColorRect


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 100
	_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_layer)

	_rect = ColorRect.new()
	_rect.color = Color(0, 0, 0, 0)
	_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer.add_child(_rect)


func is_busy() -> bool:
	return _busy


func change_to(scene_path: String) -> void:
	if _busy:
		return
	if scene_path.is_empty():
		push_warning("SceneTransition.change_to: empty path")
		return
	_busy = true
	transition_started.emit(scene_path)
	await _fade(0.0, 1.0)
	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("SceneTransition failed (%s): %s" % [err, scene_path])
		await _fade(1.0, 0.0)
		_busy = false
		return
	await get_tree().process_frame
	await _fade(1.0, 0.0)
	_busy = false
	transition_finished.emit(scene_path)


func _fade(from_a: float, to_a: float) -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP if to_a > 0.5 else Control.MOUSE_FILTER_IGNORE
	_rect.color.a = from_a
	var tw := create_tween()
	tw.tween_property(_rect, "color:a", to_a, fade_duration)
	await tw.finished
