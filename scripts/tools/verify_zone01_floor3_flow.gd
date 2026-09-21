extends SceneTree
## Floor2 → Floor3 → Floor2 / Floor4 stub. Light Exterior→F1 regression.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor3 flow verify ===")

	var err := change_scene_to_file("res://scenes/zone01/Zone01_Floor2.tscn")
	if err != OK:
		_fail("load Floor2")
		_finish()
		return
	await process_frame
	await process_frame

	var floor2 := current_scene
	if floor2 and floor2.has_method("_on_floor3_interacted"):
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
	if not reached_f3:
		_fail("Floor2 → Floor3")
		_finish()
		return
	print("OK Floor2 → Floor3")

	var floor3 := current_scene
	_expect(floor3.get_node_or_null("Background/Floor3Art") != null, "Floor3Art present")
	_expect(floor3.get_node_or_null("NPCs/Manager") != null, "Floor3 Manager")

	# Floor3 → Floor2
	if floor3.has_method("_on_floor2_interacted"):
		floor3._on_floor2_interacted(floor3.get_node("Player"))
	else:
		_fail("Floor3 missing floor2 interact")
		_finish()
		return

	var back := false
	for _i in 40:
		await create_timer(0.15).timeout
		if current_scene and current_scene.name == "Zone01_Floor2":
			back = true
			break
	if back:
		print("OK Floor3 → Floor2")
	else:
		_fail("Floor3 → Floor2")

	# Floor3 → Floor4 stub
	err = change_scene_to_file("res://scenes/zone01/Zone01_Floor3.tscn")
	if err != OK:
		_fail("reload Floor3")
		_finish()
		return
	await process_frame
	await process_frame
	floor3 = current_scene
	if floor3.has_method("_on_floor4_interacted"):
		floor3._on_floor4_interacted(floor3.get_node("Player"))
	else:
		_fail("Floor3 missing floor4 interact")
		_finish()
		return

	var reached_f4 := false
	for _i in 40:
		await create_timer(0.15).timeout
		if current_scene and current_scene.name == "Zone01_Floor4":
			reached_f4 = true
			break
	if reached_f4:
		print("OK Floor3 → Floor4 stub")
	else:
		_fail("Floor3 → Floor4 stub")

	# F1→F2 still works (chain fragment)
	err = change_scene_to_file("res://scenes/zone01/Zone01_Floor1.tscn")
	if err == OK:
		await process_frame
		await process_frame
		var f1 := current_scene
		if f1 and f1.has_method("_on_floor2_interacted"):
			f1._on_floor2_interacted(f1.get_node("Player"))
			var ok := false
			for _j in 40:
				await create_timer(0.15).timeout
				if current_scene and current_scene.name == "Zone01_Floor2":
					ok = true
					break
			if ok:
				print("OK Floor1 → Floor2 still works")
			else:
				_fail("Floor1 → Floor2 regression")
		else:
			_fail("Floor1 floor2 interact missing")
	else:
		_fail("reload Floor1")

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
