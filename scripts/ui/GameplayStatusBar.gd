extends Control
## Shared top-right BADGES button for normal zone gameplay (not mini-games).

const BADGE_SCREEN_PATH := "res://scenes/ui/BadgeScreen.tscn"

@onready var _badges_button: Button = $BadgesButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_badges_button.pressed.connect(_on_badges_pressed)


func _on_badges_pressed() -> void:
	var scene := get_tree().current_scene
	if scene != null and not scene.scene_file_path.is_empty():
		BadgeScreen.return_scene_path = scene.scene_file_path
	_go_scene(BADGE_SCREEN_PATH)


func _go_scene(path: String) -> void:
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(path)
