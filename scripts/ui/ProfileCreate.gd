extends Control
## Profile name entry for New Game.

const MAIN_MENU_PATH := "res://scenes/ui/MainMenu.tscn"

@onready var name_edit: LineEdit = $Center/Panel/Margin/VBox/NameEdit
@onready var status_label: Label = $Center/Panel/Margin/VBox/StatusLabel
@onready var overwrite_box: HBoxContainer = $Center/Panel/Margin/VBox/OverwriteBox


func _ready() -> void:
	status_label.visible = false
	overwrite_box.visible = false
	$Center/Panel/Margin/VBox/CreateButton.pressed.connect(_on_create)
	$Center/Panel/Margin/VBox/BackButton.pressed.connect(_on_back)
	$Center/Panel/Margin/VBox/OverwriteBox/YesButton.pressed.connect(_on_overwrite_yes)
	$Center/Panel/Margin/VBox/OverwriteBox/NoButton.pressed.connect(_on_overwrite_no)
	name_edit.grab_focus()


func _save_manager() -> Node:
	return get_tree().root.get_node("SaveManager")


func _on_create() -> void:
	var pname := name_edit.text.strip_edges()
	if pname.is_empty():
		_show_status("Enter a profile name.")
		return
	if _save_manager().profile_exists(pname):
		_show_status("A profile with this name already exists. Overwrite it?")
		overwrite_box.visible = true
		return
	_start(pname, false)


func _on_overwrite_yes() -> void:
	var pname := name_edit.text.strip_edges()
	_start(pname, true)


func _on_overwrite_no() -> void:
	overwrite_box.visible = false
	status_label.visible = false
	name_edit.grab_focus()


func _start(pname: String, overwrite: bool) -> void:
	overwrite_box.visible = false
	var sm: Node = _save_manager()
	if not sm.create_new_profile(pname, overwrite):
		_show_status("Could not create profile.")
		return
	SceneTransition.change_to(sm.SCHOOL_PATH)


func _on_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)


func _show_status(text: String) -> void:
	status_label.text = text
	status_label.visible = true
