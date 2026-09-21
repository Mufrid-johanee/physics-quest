extends SceneTree
## Zone 02 Floor 3 assessment — architecture + quiz rules (no exact layout asserts).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone02 Floor3 quiz verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone02_floor1_passed = true
		gs.zone02_floor2_passed = true
		gs.zone02_floor3_passed = false
		gs.zone02_exterior_spawn_marker = ""

	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor3.tscn"), "Floor3 scene exists")
	_expect(ResourceLoader.exists("res://scripts/zone02/Zone02Floor3.gd"), "Floor3 script exists")
	_expect(ResourceLoader.exists("res://data/zone02_floor3_questions.json"), "bank in data/")
	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor4.tscn"), "Floor4 scene exists (Floor3 Continue target)")

	var ctl: QuizController = (load("res://scripts/quiz/QuizController.gd") as GDScript).new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true
	_expect(ctl.load_zone02_floor3_bank(), "load_zone02_floor3_bank")
	_expect(ctl.question_bank.size() == 50, "bank has 50 (got %d)" % ctl.question_bank.size())
	var mcq_n := 0
	var ow_n := 0
	for q in ctl.question_bank:
		var fmt := str(q.get("format", "")).to_lower()
		if fmt == "mcq":
			mcq_n += 1
		elif fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
			ow_n += 1
	_expect(mcq_n > 0 and ow_n > 0, "mixed MCQ+one_word bank (%d/%d)" % [mcq_n, ow_n])
	_expect(ctl.start_quiz(), "start_quiz")
	_expect(ctl.get_session_total() == 10, "exactly 10")
	_expect(_unique_ids(ctl), "unique ids")

	var passed := {"ok": false}
	var failed := {"ok": false}
	ctl.quiz_passed.connect(func(_s, _t, _p): passed["ok"] = true)
	ctl.quiz_failed.connect(func(_s, _t, _p): failed["ok"] = true)
	await _answer_all_demo(ctl)
	_expect(passed["ok"] and not failed["ok"], "demo 10/10 pass")

	passed["ok"] = false
	failed["ok"] = false
	_expect(ctl.retry_quiz(), "retry")
	await _answer_n_correct_demo(ctl, 7)
	_expect(failed["ok"] and not passed["ok"], "7/10 fail")
	_expect(gs == null or gs.zone02_floor3_passed == false, "fail does not set flag")

	ctl.queue_free()
	await process_frame

	var scene: Node = (load("res://scenes/zone02/Zone02_Floor3.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var room: Sprite2D = scene.get_node_or_null("Background/RoomArt") as Sprite2D
	_expect(room != null and room.texture != null, "RoomArt")
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with("energy_quiz_room_3.png"), "energy_quiz_room_3.png")

	var karim = scene.get_node_or_null("NPCs/Karim")
	_expect(karim is CharacterBody2D, "Karim CharacterBody2D")
	_expect(scene.get_node_or_null("NPCs/Manager") == null, "no Manager assessment NPC")
	_expect(scene.get_node_or_null("NPCs/Nabila") == null, "no Nabila on Floor3")
	_expect(scene.get_node_or_null("NPCs/Farah") == null, "no Farah on Floor3")
	_expect(karim.get_node_or_null("InteractionArea") is Area2D, "Karim InteractionArea")
	_expect(karim.get_node_or_null("InteractionArea/CollisionShape2D") != null, "InteractionArea shape")
	if karim and "sprite_texture" in karim and karim.sprite_texture:
		_expect(String(karim.sprite_texture.resource_path).ends_with("karim.png"), "karim.png asset")
	if "can_interact" in karim:
		_expect(bool(karim.can_interact) == false, "Interactable path disabled")

	_expect(scene.get_node_or_null("DialoguePanel") != null, "DialoguePanel")
	_expect(scene.get_node_or_null("QuizController") != null, "QuizController")
	_expect(scene.get_node_or_null("QuizPanel") != null, "QuizPanel")
	_expect(scene.find_child("MiniGame", true, false) == null, "no MiniGame")

	var src := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Floor3.gd")
	_expect(src.contains("load_zone02_floor3_bank"), "loads zone02 floor3 bank")
	_expect(src.contains("Zone02_Floor4.tscn"), "Continue targets Floor4 path")
	_expect(src.contains("Continue to Floor 4"), "Continue to Floor 4 label")
	_expect(not src.contains("MiniGame") and not src.contains("MG1"), "no MG dependency")

	# CONTINUE sets flag and must NOT set exterior return spawn
	var before_marker := str(gs.zone02_exterior_spawn_marker) if gs else ""
	scene._on_quiz_continue()
	_expect(gs != null and gs.zone02_floor3_passed, "CONTINUE sets zone02_floor3_passed")
	_expect(gs == null or str(gs.zone02_exterior_spawn_marker) == before_marker, "CONTINUE does not set exterior spawn")
	_expect(src.contains("_go_to_floor4_or_prompt"), "pass Continue uses Floor4 path")
	# Pass continue must not call Exterior spawn for Floor3 return
	_expect(not _continue_returns_to_exterior(src), "pass Continue does not return to Exterior")

	scene.queue_free()
	await process_frame

	# Exterior: after floor3 pass, doors 1–3 stay unlocked
	var ext: Node = (load("res://scenes/zone02/Zone02_Exterior.tscn") as PackedScene).instantiate()
	root.add_child(ext)
	await process_frame
	await process_frame
	_expect(ext.get_node_or_null("Floor3ReturnSpawn") != null, "Floor3ReturnSpawn marker")
	_expect(bool(ext.get("_door1_available")) == true, "Door1 remains available")
	_expect(bool(ext.get("_door2_locked")) == false, "Door2 remains unlocked")
	_expect(bool(ext.get("_door3_locked")) == false, "Door3 remains unlocked")
	var lv2: CanvasItem = ext.get_node_or_null("Doors/Door2/LockedVisual") as CanvasItem
	var lv3: CanvasItem = ext.get_node_or_null("Doors/Door3/LockedVisual") as CanvasItem
	_expect(lv2 == null or lv2.visible == false, "Door2 LockedVisual stays hidden")
	_expect(lv3 == null or lv3.visible == false, "Door3 LockedVisual stays hidden")

	var ext_src := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Exterior.gd")
	_expect(ext_src.contains("Zone02_Floor3.tscn"), "Exterior Door3 targets Floor3")

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _continue_returns_to_exterior(src: String) -> bool:
	## True if _on_quiz_continue body assigns exterior spawn or changes to Exterior.
	var idx := src.find("func _on_quiz_continue")
	if idx < 0:
		return true
	var next_fn := src.find("\nfunc ", idx + 1)
	var body := src.substr(idx, next_fn - idx if next_fn > idx else src.length() - idx)
	return body.contains("EXTERIOR_PATH") or body.contains("zone02_exterior_spawn_marker")


func _unique_ids(ctl: QuizController) -> bool:
	var seen := {}
	for q in ctl.session_questions:
		var id := str(q.get("id", ""))
		if id.is_empty() or seen.has(id):
			return false
		seen[id] = true
	return true


func _answer_all_demo(ctl: QuizController) -> void:
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var fmt := str(q.get("format", "")).to_lower()
		if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
			ctl.submit_text_answer("demo")
		else:
			var opts = q.get("options", [])
			if opts is Array and opts.size() > 0:
				ctl.submit_option_text(str(opts[0]))
		await process_frame
		ctl.advance_after_feedback()
		await process_frame


func _answer_n_correct_demo(ctl: QuizController, n: int) -> void:
	var i := 0
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var fmt := str(q.get("format", "")).to_lower()
		if i < n:
			if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
				ctl.submit_text_answer("demo")
			else:
				var opts = q.get("options", [])
				if opts is Array and opts.size() > 0:
					ctl.submit_option_text(str(opts[0]))
		else:
			if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
				## Empty fails non-demo; with demo any non-empty passes — use empty if supported
				ctl.submit_text_answer("")
			else:
				var opts2 = q.get("options", [])
				if opts2 is Array and opts2.size() > 1:
					ctl.submit_option_text(str(opts2[1]))
				elif opts2 is Array and opts2.size() > 0:
					ctl.submit_option_text("__wrong__")
		await process_frame
		ctl.advance_after_feedback()
		await process_frame
		i += 1


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)
