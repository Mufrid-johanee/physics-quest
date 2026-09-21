extends SceneTree
## School → WorldMap → Zone01 Exterior (click-select simulated via select_zone01).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== School→Map→Zone01 flow verify (click-only map) ===")

	var err := change_scene_to_file("res://scenes/school/SchoolOpening.tscn")
	if err != OK:
		_fail("load SchoolOpening")
		_finish()
		return
	await process_frame
	await process_frame
	await create_timer(0.8).timeout

	var school := current_scene
	var dialogue := school.get_node_or_null("DialoguePanel")
	if dialogue == null:
		_fail("DialoguePanel")
		_finish()
		return
	for i in 2:
		var btn: Button = dialogue.get_node_or_null("Root/Panel/Margin/VBox/Continue")
		btn.emit_signal("pressed")
		await process_frame
		await create_timer(0.1).timeout

	var reached_map := false
	for _i in 120:
		await create_timer(0.25).timeout
		var cur := current_scene
		if cur and (cur.name == "WorldMap" or str(cur.scene_file_path).ends_with("WorldMap.tscn")):
			reached_map = true
			break
	if not reached_map:
		_fail("School → WorldMap")
		_finish()
		return
	print("OK School → WorldMap")

	var st := root.get_node_or_null("/root/SceneTransition")
	if st and st.has_method("is_busy"):
		for _j in 40:
			if not st.is_busy():
				break
			await create_timer(0.1).timeout

	await process_frame
	await process_frame
	var map := current_scene
	_expect(map.get_node_or_null("Background") != null, "WorldMap has Background art")
	_expect(map.get_node_or_null("Landmarks/Zone01/PropArt") != null, "WorldMap has factory")
	_expect(map.get_node_or_null("Player") == null, "WorldMap has no Player")
	_expect(map.get_node_or_null("Landmarks/Zone01/ClickArea") != null, "Factory ClickArea present")

	if map.has_method("select_zone01"):
		map.select_zone01()
	else:
		_fail("WorldMap missing select_zone01")
		_finish()
		return

	var reached_ext := false
	for _i in 60:
		await create_timer(0.2).timeout
		var cur2 := current_scene
		if cur2 and (
			cur2.name == "Zone01_Exterior"
			or str(cur2.scene_file_path).ends_with("Zone01_Exterior.tscn")
		):
			reached_ext = true
			break
	if reached_ext:
		print("OK WorldMap → Zone01_Exterior (factory select)")
	else:
		_fail("WorldMap → Zone01_Exterior")

	_finish()


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_fail(label)


func _fail(msg: String) -> void:
	_failures += 1
	printerr("FAIL %s" % msg)


func _finish() -> void:
	print("=== failures: %d ===" % _failures)
	quit(_failures)
