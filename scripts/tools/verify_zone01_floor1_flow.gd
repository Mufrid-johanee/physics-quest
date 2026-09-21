extends SceneTree
## Exterior → Floor1 → MG1 stub. Regression Exterior path intact.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor1 flow verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs and gs.has_method("reset_progress_flags"):
		gs.reset_progress_flags()
		gs.zone01_guard_granted = true

	var err := change_scene_to_file("res://scenes/zone01/Zone01_Floor1.tscn")
	if err != OK:
		_fail("load Floor1")
		_finish()
		return
	await process_frame
	await process_frame

	var floor1 := current_scene
	_expect(floor1 != null and floor1.name == "Zone01_Floor1", "Floor1 current")
	_expect(floor1.get_node_or_null("Background/Floor1Art") != null, "has Floor1Art")

	if floor1.has_method("_on_mg1_interacted"):
		floor1._on_mg1_interacted(floor1.get_node("Player"))
	else:
		_fail("missing MG1 interact")
		_finish()
		return

	var reached_mg := false
	for _i in 40:
		await create_timer(0.15).timeout
		var cur := current_scene
		if cur and (
			cur.name == "MiniGame01_Brake_Stub"
			or str(cur.scene_file_path).ends_with("MiniGame01_Brake_Stub.tscn")
		):
			reached_mg = true
			break
	if reached_mg:
		print("OK Floor1 → MG1 stub")
	else:
		_fail("Floor1 → MG1 stub")

	# Exterior → Floor1 still works
	if gs and gs.has_method("reset_progress_flags"):
		gs.reset_progress_flags()
		gs.zone01_guard_granted = true
	err = change_scene_to_file("res://scenes/zone01/Zone01_Exterior.tscn")
	if err != OK:
		_fail("reload Exterior")
	else:
		await process_frame
		await process_frame
		var exterior := current_scene
		if exterior and exterior.has_method("_on_floor1_interacted"):
			# Grant already set
			exterior._apply_gate_visuals(true)
			await process_frame
			exterior._on_floor1_interacted(exterior.get_node("Player"))
			var back := false
			for _j in 40:
				await create_timer(0.15).timeout
				var c2 := current_scene
				if c2 and c2.name == "Zone01_Floor1":
					back = true
					break
			if back:
				print("OK Exterior → Floor1 still works")
			else:
				_fail("Exterior → Floor1 regression")
		else:
			_fail("Exterior missing floor1 interact")

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
