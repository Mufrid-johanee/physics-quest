extends SceneTree
## Zone 02 Floor 4 Director assessment — architecture + quiz rules (no exact layout asserts).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone02 Floor4 quiz verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone02_floor1_passed = true
		gs.zone02_floor2_passed = true
		gs.zone02_floor3_passed = true
		gs.zone02_floor4_passed = false
		gs.zone02_complete = false
		gs.zone02_exterior_spawn_marker = ""

	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor4.tscn"), "Floor4 scene exists")
	_expect(ResourceLoader.exists("res://scripts/zone02/Zone02Floor4.gd"), "Floor4 script exists")
	_expect(ResourceLoader.exists("res://data/zone02_floor4_questions.json"), "bank in data/")

	var ctl: QuizController = (load("res://scripts/quiz/QuizController.gd") as GDScript).new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true
	_expect(ctl.load_zone02_floor4_bank(), "load_zone02_floor4_bank")
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
	_expect(gs == null or gs.zone02_floor4_passed == false, "fail does not set floor4 flag")
	_expect(gs == null or gs.zone02_complete == false, "fail does not set zone02_complete")

	ctl.queue_free()
	await process_frame

	var scene: Node = (load("res://scenes/zone02/Zone02_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var room: Sprite2D = scene.get_node_or_null("Background/RoomArt") as Sprite2D
	_expect(room != null and room.texture != null, "RoomArt")
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with("energy_control_room.png"), "energy_control_room.png")

	var director = scene.get_node_or_null("NPCs/Director")
	_expect(director is CharacterBody2D, "Director CharacterBody2D")
	_expect(scene.get_node_or_null("NPCs/Manager") == null, "no Manager")
	_expect(scene.get_node_or_null("NPCs/Nabila") == null, "no Nabila")
	_expect(scene.get_node_or_null("NPCs/Farah") == null, "no Farah")
	_expect(scene.get_node_or_null("NPCs/Karim") == null, "no Karim")
	_expect(director.get_node_or_null("InteractionArea") is Area2D, "Director InteractionArea")
	_expect(director.get_node_or_null("InteractionArea/CollisionShape2D") != null, "InteractionArea shape")
	if director and "sprite_texture" in director and director.sprite_texture:
		_expect(String(director.sprite_texture.resource_path).ends_with("director 1.png"), "director 1.png asset")
	if "can_interact" in director:
		_expect(bool(director.can_interact) == false, "Interactable path disabled")

	_expect(scene.get_node_or_null("DialoguePanel") != null, "DialoguePanel")
	_expect(scene.get_node_or_null("QuizController") != null, "QuizController")
	_expect(scene.get_node_or_null("QuizPanel") != null, "QuizPanel")
	_expect(scene.get_node_or_null("Interactions/ExteriorExit") == null, "no ExteriorExit")
	_expect(scene.get_node_or_null("MiniGameArea") != null, "MiniGameArea present")
	_expect(scene.get_node_or_null("DemoCompleteUI") != null, "DemoCompleteUI present")

	var src := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Floor4.gd")
	_expect(src.contains("load_zone02_floor4_bank"), "loads zone02 floor4 bank")
	_expect(src.contains("mark_minigame_successful(GameState.ZONE_02)"), "PLAY marks ZONE_02 via GameState")
	_expect(src.contains("PLAY MINI-GAME 02"), "PLAY MINI-GAME 02 label")
	_expect(src.contains("SUCCESSFUL"), "SUCCESSFUL placeholder text")
	_expect(not src.contains("MiniGame02_HarborWorks.tscn"), "does not launch Harbor Works")
	_expect(not src.contains("MG2_PATH"), "MG2_PATH removed")
	_expect(not src.contains("zone02_complete = true"), "quiz Continue does not set complete")

	var before_marker := str(gs.zone02_exterior_spawn_marker) if gs else ""
	## Call without awaiting dialogue (headless has no line advance).
	scene._on_quiz_continue()
	await process_frame
	await process_frame
	_expect(gs != null and gs.zone02_floor4_passed, "CONTINUE sets zone02_floor4_passed")
	_expect(gs == null or gs.zone02_complete == false, "CONTINUE does not set zone02_complete")
	_expect(gs == null or gs.zone02_minigame_successful == false, "CONTINUE does not set MG successful")
	_expect(not gs.is_zone_unlocked(gs.ZONE_03), "quiz alone does not unlock ZONE_03")
	_expect(gs == null or str(gs.zone02_exterior_spawn_marker) == before_marker, "CONTINUE does not set exterior spawn")

	## PLAY placeholder marks success + unlocks Zone 03 (floor4 already passed).
	scene._on_play_mg1()
	await process_frame
	_expect(gs != null and gs.zone02_minigame_successful, "PLAY sets zone02_minigame_successful")
	_expect(gs != null and gs.zone02_complete, "PLAY sets zone02_complete")
	_expect(gs != null and gs.zone02_badge_earned, "PLAY sets zone02_badge_earned")
	_expect(gs.is_zone_unlocked(gs.ZONE_03), "PLAY unlocks ZONE_03")

	scene.queue_free()
	await process_frame

	# Floor3 → Floor4 path still wired
	var f3_src := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Floor3.gd")
	_expect(f3_src.contains("Zone02_Floor4.tscn"), "Floor3 Continue targets Floor4")
	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor4.tscn"), "Floor4 scene reachable")

	# Door persistence after Floor4 complete (via MG)
	var ext: Node = (load("res://scenes/zone02/Zone02_Exterior.tscn") as PackedScene).instantiate()
	root.add_child(ext)
	await process_frame
	await process_frame
	_expect(bool(ext.get("_door1_available")) == true, "Door1 remains available")
	_expect(bool(ext.get("_door2_locked")) == false, "Door2 remains unlocked")
	_expect(bool(ext.get("_door3_locked")) == false, "Door3 remains unlocked")

	print("=== failures: %d ===" % _failures)
	quit(_failures)


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
