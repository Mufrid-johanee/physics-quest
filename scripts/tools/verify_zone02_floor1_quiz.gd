extends SceneTree
## Zone 02 Floor 1 assessment — architecture + quiz rules (no exact layout asserts).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone02 Floor1 quiz verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone02_floor1_passed = false
		gs.zone02_exterior_spawn_marker = ""

	_expect(ResourceLoader.exists("res://scenes/zone02/Zone02_Floor1.tscn"), "Floor1 scene exists")
	_expect(ResourceLoader.exists("res://scripts/zone02/Zone02Floor1.gd"), "Floor1 script exists")
	_expect(ResourceLoader.exists("res://data/zone02_floor1_questions.json"), "bank in data/")

	var ctl: QuizController = (load("res://scripts/quiz/QuizController.gd") as GDScript).new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true
	_expect(ctl.load_zone02_floor1_bank(), "load_zone02_floor1_bank")
	_expect(ctl.question_bank.size() == 50, "bank has 50 (got %d)" % ctl.question_bank.size())
	_expect(ctl.start_quiz(), "start_quiz")
	_expect(ctl.get_session_total() == 10, "exactly 10")
	_expect(_unique_ids(ctl), "unique ids")

	var passed := {"ok": false}
	var failed := {"ok": false}
	ctl.quiz_passed.connect(func(_s, _t, _p): passed["ok"] = true)
	ctl.quiz_failed.connect(func(_s, _t, _p): failed["ok"] = true)
	await _answer_all_first(ctl)
	_expect(passed["ok"] and not failed["ok"], "demo 10/10 pass")

	passed["ok"] = false
	failed["ok"] = false
	_expect(ctl.retry_quiz(), "retry")
	await _answer_n_correct(ctl, 7)
	_expect(failed["ok"] and not passed["ok"], "7/10 fail")
	_expect(gs == null or gs.zone02_floor1_passed == false, "fail does not set flag")

	ctl.queue_free()
	await process_frame

	var scene: Node = (load("res://scenes/zone02/Zone02_Floor1.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	var room: Sprite2D = scene.get_node_or_null("Background/RoomArt") as Sprite2D
	_expect(room != null and room.texture != null, "RoomArt")
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with("energy_quiz_room_1.png"), "energy_quiz_room_1.png")

	var nabila = scene.get_node_or_null("NPCs/Nabila")
	_expect(nabila is CharacterBody2D, "Nabila CharacterBody2D")
	_expect(scene.get_node_or_null("NPCs/Manager") == null, "no Manager assessment NPC")
	_expect(nabila.get_node_or_null("InteractionArea") is Area2D, "Nabila InteractionArea")
	_expect(nabila.get_node_or_null("InteractionArea/CollisionShape2D") != null, "InteractionArea shape")
	if nabila and "sprite_texture" in nabila and nabila.sprite_texture:
		_expect(String(nabila.sprite_texture.resource_path).ends_with("nabila.png"), "nabila.png asset")
	if "can_interact" in nabila:
		_expect(bool(nabila.can_interact) == false, "Interactable path disabled")

	_expect(scene.get_node_or_null("DialoguePanel") != null, "DialoguePanel")
	_expect(scene.get_node_or_null("QuizController") != null, "QuizController")
	_expect(scene.get_node_or_null("QuizPanel") != null, "QuizPanel")
	_expect(scene.get_node_or_null("Interactions/ExteriorExit") != null, "ExteriorExit")
	_expect(scene.find_child("MiniGame", true, false) == null, "no MiniGame")

	var src := FileAccess.get_file_as_string("res://scripts/zone02/Zone02Floor1.gd")
	_expect(src.contains("load_zone02_floor1_bank"), "loads zone02 floor1 bank")
	_expect(not src.contains("MiniGame") and not src.contains("MG1"), "no MG dependency")

	# CONTINUE sets flag
	scene._on_quiz_continue()
	_expect(gs != null and gs.zone02_floor1_passed, "CONTINUE sets zone02_floor1_passed")
	scene.queue_free()
	await process_frame

	# Exterior Door2 unlock + return spawn
	var ext: Node = (load("res://scenes/zone02/Zone02_Exterior.tscn") as PackedScene).instantiate()
	root.add_child(ext)
	await process_frame
	await process_frame
	_expect(ext.get_node_or_null("Floor1ReturnSpawn") != null, "Floor1ReturnSpawn marker")
	_expect(bool(ext.get("_door2_locked")) == false, "Door2 unlocked after floor1 pass")
	var lv: CanvasItem = ext.get_node_or_null("Doors/Door2/LockedVisual") as CanvasItem
	_expect(lv == null or lv.visible == false, "Door2 LockedVisual hidden when unlocked")
	_expect(bool(ext.get("_door3_locked")) == true, "Door3 still locked")

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


func _answer_all_first(ctl: QuizController) -> void:
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var opts = q.get("options", [])
		if opts is Array and opts.size() > 0:
			ctl.submit_option_text(str(opts[0]))
		await process_frame
		ctl.advance_after_feedback()
		await process_frame


func _answer_n_correct(ctl: QuizController, n: int) -> void:
	var i := 0
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var opts = q.get("options", [])
		if opts is Array and opts.size() > 0:
			if i < n:
				ctl.submit_option_text(str(opts[0]))
			else:
				ctl.submit_option_text(str(opts[mini(1, opts.size() - 1)]))
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
