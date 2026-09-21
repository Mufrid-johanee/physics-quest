extends SceneTree
## Floor1 → Floor2 → Floor1 / Floor3 stub. No MG1.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor2 flow verify ===")

	var err := change_scene_to_file("res://scenes/zone01/Zone01_Floor1.tscn")
	if err != OK:
		_fail("load Floor1")
		_finish()
		return
	await process_frame
	await process_frame

	var floor1 := current_scene
	if floor1 and floor1.has_method("_on_floor2_interacted"):
		floor1._on_floor2_interacted(floor1.get_node("Player"))
	else:
		_fail("Floor1 missing floor2 interact")
		_finish()
		return

	var reached_f2 := false
	for _i in 40:
		await create_timer(0.15).timeout
		var cur := current_scene
		if cur and cur.name == "Zone01_Floor2":
			reached_f2 = true
			break
	if not reached_f2:
		_fail("Floor1 → Floor2")
		_finish()
		return
	print("OK Floor1 → Floor2")

	var floor2 := current_scene
	_expect(floor2.get_node_or_null("NPCs/Manager") != null, "Floor2 Manager")
	_expect(floor2.get_node_or_null("NPCs/LabAssistant") != null, "Floor2 LabAssistant")
	_expect(floor2.get_node_or_null("NPCs/Workers") == null, "no Workers group on Floor2")

	# Floor2 → Floor1
	if floor2.has_method("_on_floor1_interacted"):
		floor2._on_floor1_interacted(floor2.get_node("Player"))
	else:
		_fail("Floor2 missing floor1 interact")
		_finish()
		return

	var back_f1 := false
	for _i in 40:
		await create_timer(0.15).timeout
		if current_scene and current_scene.name == "Zone01_Floor1":
			back_f1 = true
			break
	if back_f1:
		print("OK Floor2 → Floor1")
	else:
		_fail("Floor2 → Floor1")

	# Floor2 → Floor3 stub
	err = change_scene_to_file("res://scenes/zone01/Zone01_Floor2.tscn")
	if err != OK:
		_fail("reload Floor2")
		_finish()
		return
	await process_frame
	await process_frame
	floor2 = current_scene
	if floor2.has_method("_on_floor3_interacted"):
		floor2._on_floor3_interacted(floor2.get_node("Player"))
	else:
		_fail("Floor2 missing floor3 interact")
		_finish()
		return

	var reached_f3 := false
	for _i in 40:
		await create_timer(0.15).timeout
		if current_scene and current_scene.name == "Zone01_Floor3":
			reached_f3 = true
			break
	if reached_f3:
		print("OK Floor2 → Floor3 stub")
	else:
		_fail("Floor2 → Floor3 stub")

	# Exterior → Floor1 regression (light)
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone01_guard_granted = true
	err = change_scene_to_file("res://scenes/zone01/Zone01_Exterior.tscn")
	if err == OK:
		await process_frame
		await process_frame
		var exterior := current_scene
		if exterior and exterior.has_method("_apply_gate_visuals"):
			exterior._apply_gate_visuals(true)
		if exterior and exterior.has_method("_on_floor1_interacted"):
			exterior._on_floor1_interacted(exterior.get_node("Player"))
			var ok := false
			for _j in 40:
				await create_timer(0.15).timeout
				if current_scene and current_scene.name == "Zone01_Floor1":
					ok = true
					break
			if ok:
				print("OK Exterior → Floor1 still works")
			else:
				_fail("Exterior → Floor1 regression")
		else:
			_fail("Exterior floor1 interact missing")
	else:
		_fail("reload Exterior")

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
