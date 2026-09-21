extends SceneTree
## Floor3 → Floor4 → Floor3 / MiniGame stub. F2→F3 regression fragment.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor4 flow verify ===")

	var err := change_scene_to_file("res://scenes/zone01/Zone01_Floor3.tscn")
	if err != OK:
		_fail("load Floor3")
		_finish()
		return
	await process_frame
	await process_frame

	var floor3 := current_scene
	if floor3 and floor3.has_method("_on_floor4_interacted"):
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
	if not reached_f4:
		_fail("Floor3 → Floor4")
		_finish()
		return
	print("OK Floor3 → Floor4")

	var floor4 := current_scene
	_expect(floor4.get_node_or_null("NPCs/Director") != null, "Director present")
	_expect(floor4.get_node_or_null("Background/Floor4Art") != null, "Floor4Art present")

	# Floor4 → Floor3
	if floor4.has_method("_on_floor3_interacted"):
		floor4._on_floor3_interacted(floor4.get_node("Player"))
	else:
		_fail("Floor4 missing floor3 interact")
		_finish()
		return

	var back := false
	for _i in 40:
		await create_timer(0.15).timeout
		if current_scene and current_scene.name == "Zone01_Floor3":
			back = true
			break
	if back:
		print("OK Floor4 → Floor3")
	else:
		_fail("Floor4 → Floor3")

	# Floor4 → MiniGame stub
	err = change_scene_to_file("res://scenes/zone01/Zone01_Floor4.tscn")
	if err != OK:
		_fail("reload Floor4")
		_finish()
		return
	await process_frame
	await process_frame
	floor4 = current_scene
	if floor4.has_method("_on_mg_interacted"):
		floor4._on_mg_interacted(floor4.get_node("Player"))
	else:
		_fail("Floor4 missing mg interact")
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
		print("OK Floor4 → MiniGame stub (placeholder)")
	else:
		_fail("Floor4 → MiniGame stub")

	# F2 → F3 still works
	err = change_scene_to_file("res://scenes/zone01/Zone01_Floor2.tscn")
	if err == OK:
		await process_frame
		await process_frame
		var f2 := current_scene
		if f2 and f2.has_method("_on_floor3_interacted"):
			f2._on_floor3_interacted(f2.get_node("Player"))
			var ok := false
			for _j in 40:
				await create_timer(0.15).timeout
				if current_scene and current_scene.name == "Zone01_Floor3":
					ok = true
					break
			if ok:
				print("OK Floor2 → Floor3 still works")
			else:
				_fail("Floor2 → Floor3 regression")
		else:
			_fail("Floor2 floor3 interact missing")
	else:
		_fail("reload Floor2")

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
