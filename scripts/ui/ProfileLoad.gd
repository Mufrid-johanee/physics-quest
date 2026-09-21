extends Control
## Lists saved profiles for Load Game.

const MAIN_MENU_PATH := "res://scenes/ui/MainMenu.tscn"

@onready var list_box: VBoxContainer = $Center/Panel/Margin/VBox/Scroll/List
@onready var empty_label: Label = $Center/Panel/Margin/VBox/EmptyLabel


func _ready() -> void:
	$Center/Panel/Margin/VBox/BackButton.pressed.connect(_on_back)
	_populate()


func _save_manager() -> Node:
	return get_tree().root.get_node("SaveManager")


func _populate() -> void:
	for child in list_box.get_children():
		child.queue_free()
	var profiles: Array = _save_manager().list_profiles()
	empty_label.visible = profiles.is_empty()
	if profiles.is_empty():
		empty_label.text = "No saved profiles found."
		return
	for entry in profiles:
		var pname := str(entry.get("profile_name", ""))
		var summary := str(entry.get("progress_summary", ""))
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(0, 44)
		btn.text = "%s  —  %s" % [pname, summary]
		btn.pressed.connect(_on_profile_pressed.bind(pname))
		list_box.add_child(btn)


func _on_profile_pressed(profile_name: String) -> void:
	_save_manager().load_profile_and_continue(profile_name)


func _on_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
