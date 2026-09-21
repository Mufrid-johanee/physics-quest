extends Control
## Main menu using ornate panel art (res://asset/sprites/load game screen.png).
## Painted NEW/LOAD/SAVE/QUIT regions use transparent hotspot Buttons.

const PROFILE_CREATE_PATH := "res://scenes/ui/ProfileCreate.tscn"
const PROFILE_LOAD_PATH := "res://scenes/ui/ProfileLoad.tscn"


func _ready() -> void:
	$Center/PanelRoot/NewGameHotspot.pressed.connect(_on_new_game)
	$Center/PanelRoot/LoadGameHotspot.pressed.connect(_on_load_game)
	$Center/PanelRoot/SaveGameHotspot.pressed.connect(_on_save_game)
	$Center/PanelRoot/QuitGameHotspot.pressed.connect(_on_quit)


func _save_manager() -> Node:
	return get_tree().root.get_node("SaveManager")


func _on_new_game() -> void:
	get_tree().change_scene_to_file(PROFILE_CREATE_PATH)


func _on_load_game() -> void:
	get_tree().change_scene_to_file(PROFILE_LOAD_PATH)


func _on_save_game() -> void:
	## In-menu: tip only. Actual save is S in-game after a checkpoint.
	_save_manager().show_toast("Use S in-game after a progression checkpoint to save.")


func _on_quit() -> void:
	get_tree().quit()
