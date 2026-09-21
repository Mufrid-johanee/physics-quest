extends SceneTree
## Map → Exterior → (grant) → Floor1 stub. Also checks School→Map still works lightly.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Exterior flow verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs and gs.has_method("reset_progress_flags"):
		gs.reset_progress_flags()

	var err := change_scene_to_file("res://scenes/zone01/Zone01_Exterior.tscn")
	if err != OK:
		_fail("load Exterior")
		_finish()
		return
	await process_frame
	await process_frame
	await create_timer(0.2).timeout

	var exterior := current_scene
	_expect(exterior != null and exterior.name == "Zone01_Exterior", "Exterior current")

	if exterior.has_method("_grant_gate_access"):
		await exterior._grant_gate_access()
	else:
		_fail("no grant method")
		_finish()
		return

	await process_frame
	if exterior.has_method("_on_floor1_interacted"):
		exterior._on_floor1_interacted(exterior.get_node("Player"))
	else:
		_fail("no floor1 interact")
		_finish()
		return

	var reached := false
	for _i in 50:
		await create_timer(0.15).timeout
		var cur := current_scene
		if cur and (
			cur.name == "Zone01_Floor1"
			or str(cur.scene_file_path).ends_with("Zone01_Floor1.tscn")
		):
			reached = true
			break
	if reached:
		print("OK Exterior → Floor1 stub")
	else:
		_fail("Exterior → Floor1 stub")

	# WorldMap → Exterior regression
	if gs and gs.has_method("reset_progress_flags"):
		gs.reset_progress_flags()
	err = change_scene_to_file("res://scenes/world_map/WorldMap.tscn")
	if err != OK:
		_fail("reload WorldMap")
	else:
		await process_frame
		await process_frame
		var map := current_scene
		if map and map.has_method("select_zone01"):
			map.select_zone01()
			var back := false
			for _j in 40:
				await create_timer(0.15).timeout
				var c2 := current_scene
				if c2 and c2.name == "Zone01_Exterior":
					back = true
					break
			if back:
				print("OK WorldMap → Exterior still works")
			else:
				_fail("WorldMap → Exterior regression")
		else:
			_fail("WorldMap missing select_zone01")

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
