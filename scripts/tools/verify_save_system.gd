extends SceneTree
## Headless smoke checks for profile save/load (waits for project autoloads).


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await process_frame
	await process_frame
	var failed := 0
	failed += _expect(ResourceLoader.exists("res://scripts/autoload/SaveManager.gd"), "SaveManager.gd")
	failed += _expect(ResourceLoader.exists("res://scenes/ui/MainMenu.tscn"), "MainMenu.tscn")
	failed += _expect(ResourceLoader.exists("res://scenes/ui/ProfileCreate.tscn"), "ProfileCreate.tscn")
	failed += _expect(ResourceLoader.exists("res://scenes/ui/ProfileLoad.tscn"), "ProfileLoad.tscn")
	failed += _expect(ResourceLoader.exists("res://asset/sprites/load game screen.png"), "menu panel art")

	var menu_ps: PackedScene = load("res://scenes/ui/MainMenu.tscn")
	failed += _expect(menu_ps != null, "MainMenu loads")
	if menu_ps:
		var menu: Node = menu_ps.instantiate()
		failed += _expect(menu.get_node_or_null("Center/PanelRoot/NewGameHotspot") != null, "NEW hotspot")
		failed += _expect(menu.get_node_or_null("Center/PanelRoot/LoadGameHotspot") != null, "LOAD hotspot")
		failed += _expect(menu.get_node_or_null("Center/PanelRoot/SaveGameHotspot") != null, "SAVE hotspot")
		failed += _expect(menu.get_node_or_null("Center/PanelRoot/QuitGameHotspot") != null, "QUIT hotspot")
		menu.free()

	var create_ps: PackedScene = load("res://scenes/ui/ProfileCreate.tscn")
	failed += _expect(create_ps != null, "ProfileCreate loads")
	if create_ps:
		var create_ui: Node = create_ps.instantiate()
		failed += _expect(create_ui.get_node_or_null("Center/Panel/Margin/VBox/NameEdit") != null, "ProfileCreate NameEdit")
		create_ui.free()

	var gs: Node = root.get_node_or_null("GameState")
	var sm: Node = root.get_node_or_null("SaveManager")
	failed += _expect(gs != null, "GameState autoload")
	failed += _expect(sm != null, "SaveManager autoload")
	if gs == null or sm == null:
		print("VERIFY_SAVE: FAIL count=", failed)
		quit(1)

	failed += _expect(gs.has_method("get_save_data"), "GameState.get_save_data")
	failed += _expect(gs.has_method("apply_save_data"), "GameState.apply_save_data")
	failed += _expect(gs.has_method("has_progression_checkpoint"), "GameState.has_progression_checkpoint")

	gs.call("reset_for_new_profile")
	failed += _expect(not bool(gs.call("has_progression_checkpoint")), "fresh = no checkpoint")
	gs.set("zone01_floor1_passed", true)
	failed += _expect(bool(gs.call("has_progression_checkpoint")), "floor1 pass = checkpoint")
	var blob: Dictionary = gs.call("get_save_data")
	gs.call("reset_for_new_profile")
	failed += _expect(not bool(gs.get("zone01_floor1_passed")), "reset cleared floor1")
	gs.call("apply_save_data", blob)
	failed += _expect(bool(gs.get("zone01_floor1_passed")), "restore floor1")

	var test_name := "__verify_profile_tmp__"
	sm.call("create_new_profile", test_name, true)
	failed += _expect(bool(sm.call("profile_exists", test_name)), "profile file exists")
	var listed: Array = sm.call("list_profiles")
	var found := false
	for e in listed:
		if str(e.get("profile_name", "")) == test_name:
			found = true
			break
	failed += _expect(found, "profile in index")

	var path: String = sm.call("profile_path", test_name)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var remaining: Array = []
	for e2 in sm.call("list_profiles"):
		var n := str(e2.get("profile_name", ""))
		if n != test_name and not n.is_empty() and FileAccess.file_exists(str(sm.call("profile_path", n))):
			remaining.append(n)
	var f := FileAccess.open("user://profiles/index.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"version": 1, "profiles": remaining}, "\t"))
		f.close()

	gs.call("reset_for_new_profile")
	if failed == 0:
		print("VERIFY_SAVE: PASS")
		quit(0)
		return
	print("VERIFY_SAVE: FAIL count=", failed)
	quit(1)


func _expect(cond: bool, msg: String) -> int:
	if cond:
		print("  OK  ", msg)
		return 0
	print("  FAIL ", msg)
	return 1
