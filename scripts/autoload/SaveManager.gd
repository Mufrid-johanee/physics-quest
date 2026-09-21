extends Node
## Profile-based save/load under user://. Manual S-key save only (no autosave).
## Does not rewrite scene-authored NPC/environment transforms.

const SAVE_VERSION := 1
const PROFILES_DIR := "user://profiles"
const INDEX_PATH := "user://profiles/index.json"
const SCHOOL_PATH := "res://scenes/school/SchoolOpening.tscn"
const MAIN_MENU_PATH := "res://scenes/ui/MainMenu.tscn"

var active_profile_name: String = ""
var _pending_player_position: Vector2 = Vector2.ZERO
var _has_pending_player_position: bool = false
var _toast_layer: CanvasLayer
var _toast_label: Label
var _toast_timer: Timer


func _ready() -> void:
	_ensure_profiles_dir()
	_build_toast()
	if not SceneTransition.transition_finished.is_connected(_on_scene_transition_finished):
		SceneTransition.transition_finished.connect(_on_scene_transition_finished)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		# Ignore save while on menu / profile screens.
		var scene := get_tree().current_scene
		if scene and str(scene.scene_file_path).begins_with("res://scenes/ui/"):
			return
		request_manual_save()
		get_viewport().set_input_as_handled()


func _ensure_profiles_dir() -> void:
	var abs_dir := ProjectSettings.globalize_path(PROFILES_DIR)
	if not DirAccess.dir_exists_absolute(abs_dir):
		DirAccess.make_dir_recursive_absolute(abs_dir)


func _build_toast() -> void:
	_toast_layer = CanvasLayer.new()
	_toast_layer.layer = 120
	_toast_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_toast_layer)
	_toast_label = Label.new()
	_toast_label.visible = false
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.anchor_left = 0.5
	_toast_label.anchor_right = 0.5
	_toast_label.anchor_top = 0.0
	_toast_label.anchor_bottom = 0.0
	_toast_label.offset_left = -280.0
	_toast_label.offset_right = 280.0
	_toast_label.offset_top = 24.0
	_toast_label.offset_bottom = 64.0
	_toast_label.add_theme_font_size_override("font_size", 18)
	_toast_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.85, 1))
	_toast_layer.add_child(_toast_label)
	_toast_timer = Timer.new()
	_toast_timer.one_shot = true
	_toast_timer.wait_time = 2.0
	_toast_timer.timeout.connect(_hide_toast)
	add_child(_toast_timer)


func show_toast(text: String, duration: float = 2.0) -> void:
	if _toast_label == null:
		return
	_toast_label.text = text
	_toast_label.visible = true
	_toast_timer.stop()
	_toast_timer.wait_time = duration
	_toast_timer.start()


func _hide_toast() -> void:
	if _toast_label:
		_toast_label.visible = false


func sanitize_profile_id(profile_name: String) -> String:
	var cleaned := profile_name.strip_edges()
	var out := ""
	for i in cleaned.length():
		var ch := cleaned[i]
		var code := ch.unicode_at(0)
		var ok := (
			(code >= 48 and code <= 57)
			or (code >= 65 and code <= 90)
			or (code >= 97 and code <= 122)
			or ch == " "
			or ch == "-"
			or ch == "_"
		)
		if ok:
			out += ch
	out = out.strip_edges().replace(" ", "_")
	while out.contains("__"):
		out = out.replace("__", "_")
	if out.is_empty():
		out = "player"
	return out.to_lower()


func profile_path(profile_name: String) -> String:
	return "%s/%s.json" % [PROFILES_DIR, sanitize_profile_id(profile_name)]


func profile_exists(profile_name: String) -> bool:
	return FileAccess.file_exists(profile_path(profile_name))


func list_profiles() -> Array[Dictionary]:
	_ensure_profiles_dir()
	var result: Array[Dictionary] = []
	var index := _read_index()
	var names: Array = index.get("profiles", [])
	for entry in names:
		var pname := str(entry)
		if pname.is_empty():
			continue
		var data := load_profile_dict(pname)
		var summary := "Saved"
		if not data.is_empty():
			summary = str(data.get("progress_summary", "Saved"))
		result.append({
			"profile_name": pname,
			"progress_summary": summary,
			"current_scene": str(data.get("current_scene", "")),
		})
	return result


func _read_index() -> Dictionary:
	if not FileAccess.file_exists(INDEX_PATH):
		return {"version": SAVE_VERSION, "profiles": []}
	var f := FileAccess.open(INDEX_PATH, FileAccess.READ)
	if f == null:
		return {"version": SAVE_VERSION, "profiles": []}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"version": SAVE_VERSION, "profiles": []}
	return parsed as Dictionary


func _write_index(names: Array) -> void:
	_ensure_profiles_dir()
	var payload := {"version": SAVE_VERSION, "profiles": names}
	var f := FileAccess.open(INDEX_PATH, FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: cannot write index")
		return
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()


func _register_profile_name(profile_name: String) -> void:
	var index := _read_index()
	var names: Array = index.get("profiles", [])
	if not names.has(profile_name):
		names.append(profile_name)
		_write_index(names)


func _unregister_profile_name(profile_name: String) -> void:
	var index := _read_index()
	var names: Array = index.get("profiles", [])
	names.erase(profile_name)
	_write_index(names)


func load_profile_dict(profile_name: String) -> Dictionary:
	var path := profile_path(profile_name)
	if not FileAccess.file_exists(path):
		return {}
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


func create_new_profile(profile_name: String, overwrite: bool = false) -> bool:
	var pname := profile_name.strip_edges()
	if pname.is_empty():
		show_toast("Enter a profile name.")
		return false
	if profile_exists(pname) and not overwrite:
		return false
	GameState.reset_for_new_profile()
	active_profile_name = pname
	_has_pending_player_position = false
	var ok := _write_profile_file(pname, SCHOOL_PATH, Vector2.ZERO, true)
	if not ok:
		show_toast("Could not create profile.")
		return false
	_register_profile_name(pname)
	return true


func start_new_game(profile_name: String, overwrite: bool = false) -> void:
	if not create_new_profile(profile_name, overwrite):
		if profile_exists(profile_name) and not overwrite:
			return
		show_toast("Could not start new game.")
		return
	SceneTransition.change_to(SCHOOL_PATH)


func request_manual_save() -> void:
	if active_profile_name.is_empty():
		show_toast("No active profile. Start or load a game first.")
		return
	if not GameState.has_progression_checkpoint():
		show_toast("Save is available after completing a progression checkpoint.")
		return
	if save_active_profile():
		show_toast("Game Saved")
	else:
		show_toast("Save failed.")


func save_active_profile() -> bool:
	if active_profile_name.is_empty():
		return false
	var scene := get_tree().current_scene
	if scene == null:
		return false
	var scene_path := str(scene.scene_file_path)
	if scene_path.is_empty() or scene_path.begins_with("res://scenes/ui/"):
		return false
	var pos := Vector2.ZERO
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		pos = player.global_position
	return _write_profile_file(active_profile_name, scene_path, pos, false)


func _write_profile_file(profile_name: String, scene_path: String, player_pos: Vector2, is_new: bool) -> bool:
	_ensure_profiles_dir()
	var payload := {
		"version": SAVE_VERSION,
		"profile_name": profile_name,
		"current_scene": scene_path,
		"player_position": {"x": player_pos.x, "y": player_pos.y},
		"progress_summary": GameState.progress_summary_label(),
		"game_state": GameState.get_save_data(),
		"saved_at_unix": Time.get_unix_time_from_system(),
		"is_new_profile": is_new,
	}
	var f := FileAccess.open(profile_path(profile_name), FileAccess.WRITE)
	if f == null:
		push_error("SaveManager: cannot write profile '%s'" % profile_name)
		return false
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	_register_profile_name(profile_name)
	return true


func load_profile_and_continue(profile_name: String) -> void:
	var data := load_profile_dict(profile_name)
	if data.is_empty():
		show_toast("Could not load profile.")
		return
	var scene_path := str(data.get("current_scene", ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		show_toast("Saved scene is missing or invalid.")
		return
	var gs: Variant = data.get("game_state", {})
	if typeof(gs) == TYPE_DICTIONARY:
		GameState.apply_save_data(gs as Dictionary)
	else:
		GameState.reset_for_new_profile()
	active_profile_name = str(data.get("profile_name", profile_name))
	var pos_data: Variant = data.get("player_position", {})
	_has_pending_player_position = false
	if typeof(pos_data) == TYPE_DICTIONARY:
		var pd: Dictionary = pos_data
		_pending_player_position = Vector2(float(pd.get("x", 0.0)), float(pd.get("y", 0.0)))
		var is_new := bool(data.get("is_new_profile", false))
		# World Map has no player; brand-new profiles use scene-authored School spawn.
		if scene_path != "res://scenes/world_map/WorldMap.tscn" and not is_new:
			_has_pending_player_position = true
	show_toast("Profile Loaded")
	SceneTransition.change_to(scene_path)


func _on_scene_transition_finished(_path: String) -> void:
	if not _has_pending_player_position:
		return
	# Floor scripts set PlayerSpawn in _ready; re-apply after that settles.
	await get_tree().process_frame
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player:
		player.global_position = _pending_player_position
		if player.has_method("set_scripted_control"):
			player.set_scripted_control(false)
		if player.has_method("set_seated"):
			player.set_seated(false)
	_has_pending_player_position = false
