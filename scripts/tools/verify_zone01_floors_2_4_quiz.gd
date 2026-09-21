extends SceneTree
## Floor 2–4 assessment progression verify. No mini-game claims.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor2-4 assessment verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone01_floor1_passed = true
		gs.zone01_floor2_passed = false
		gs.zone01_floor3_passed = false
		gs.zone01_floor4_passed = false

	var ctl_script := load("res://scripts/quiz/QuizController.gd")
	_expect(ctl_script != null, "QuizController loads")
	var ctl: QuizController = ctl_script.new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true

	# Floor 2 bank — all MCQ
	_expect(ctl.load_floor2_bank(), "Floor2 bank loads")
	_expect(ctl.question_bank.size() == 50, "Floor2 bank 50 (got %d)" % ctl.question_bank.size())
	_expect(ctl.start_quiz(), "Floor2 start")
	_expect(ctl.get_session_total() == 10, "Floor2 exactly 10")
	var passed := {"ok": false}
	var failed := {"ok": false}
	ctl.quiz_passed.connect(func(_s, _t, _p): passed["ok"] = true)
	ctl.quiz_failed.connect(func(_s, _t, _p): failed["ok"] = true)
	await _answer_session_demo(ctl)
	_expect(passed["ok"] and not failed["ok"], "Floor2 demo 10/10 pass")

	passed["ok"] = false
	failed["ok"] = false
	_expect(ctl.retry_quiz(), "Floor2 retry")
	await _answer_n_correct_then_wrong(ctl, 7)
	_expect(failed["ok"] and not passed["ok"], "Floor2 7/10 fail → Try Again path")

	# Floor 3 — mixed one_word + mcq
	passed["ok"] = false
	failed["ok"] = false
	_expect(ctl.load_floor3_bank(), "Floor3 bank loads")
	_expect(ctl.question_bank.size() == 50, "Floor3 bank 50")
	_expect(ctl.start_quiz(), "Floor3 start")
	_expect(ctl.get_session_total() == 10, "Floor3 exactly 10")
	await _answer_session_demo(ctl)
	_expect(passed["ok"], "Floor3 demo pass (MCQ A / one_word any text)")

	# Floor 4
	passed["ok"] = false
	failed["ok"] = false
	_expect(ctl.load_floor4_bank(), "Floor4 bank loads")
	_expect(ctl.question_bank.size() == 50, "Floor4 bank 50")
	_expect(ctl.start_quiz(), "Floor4 start")
	_expect(ctl.get_session_total() == 10, "Floor4 exactly 10")
	await _answer_session_demo(ctl)
	_expect(passed["ok"], "Floor4 demo pass")

	ctl.queue_free()
	await process_frame

	# Scene structure Floor 2
	_expect(ResourceLoader.exists("res://scenes/zone01/Zone01_Floor2.tscn"), "Floor2 scene exists")
	var f2: Node = (load("res://scenes/zone01/Zone01_Floor2.tscn") as PackedScene).instantiate()
	root.add_child(f2)
	await process_frame
	await process_frame
	_expect(f2.get_node_or_null("NPCs/Manager/InteractionArea") is Area2D, "F2 Manager InteractionArea")
	_expect(f2.get_node_or_null("NPCs/Manager/InteractionArea/CollisionShape2D") != null, "F2 InteractionArea shape")
	_expect(f2.get_node_or_null("QuizController") != null, "F2 QuizController")
	_expect(f2.get_node_or_null("QuizPanel") != null, "F2 QuizPanel")
	_expect(is_equal_approx(f2.get_node("NPCs/Manager").position.x, 405.0), "F2 Manager pos preserved")
	# Gate locked before pass
	if gs:
		gs.zone01_floor2_passed = false
	f2._on_floor3_entered(f2.get_node("Player"))
	var prompt: Label = f2.get_node("UI/PromptLabel")
	_expect(prompt.visible and "Floor 2" in prompt.text, "F2 blocks Floor3 before pass")
	# Simulate continue sets flag
	f2._on_quiz_continue()
	_expect(gs != null and gs.zone01_floor2_passed, "F2 continue sets zone01_floor2_passed")
	f2.queue_free()
	await process_frame

	# Floor 3
	var f3: Node = (load("res://scenes/zone01/Zone01_Floor3.tscn") as PackedScene).instantiate()
	root.add_child(f3)
	await process_frame
	await process_frame
	_expect(f3.get_node_or_null("NPCs/Manager/InteractionArea") is Area2D, "F3 Manager InteractionArea")
	_expect(f3.get_node_or_null("QuizController") != null, "F3 QuizController")
	_expect(is_equal_approx(f3.get_node("NPCs/Manager").position.x, 434.0), "F3 Manager pos preserved")
	if gs:
		gs.zone01_floor3_passed = false
	f3._on_floor4_entered(f3.get_node("Player"))
	prompt = f3.get_node("UI/PromptLabel")
	_expect(prompt.visible and "Floor 3" in prompt.text, "F3 blocks Floor4 before pass")
	f3._on_quiz_continue()
	_expect(gs != null and gs.zone01_floor3_passed, "F3 continue sets zone01_floor3_passed")
	f3.queue_free()
	await process_frame

	# Floor 4 — no MG transition
	var f4: Node = (load("res://scenes/zone01/Zone01_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(f4)
	await process_frame
	await process_frame
	_expect(f4.get_node_or_null("NPCs/Director/InteractionArea") is Area2D, "F4 Director InteractionArea")
	_expect(f4.get_node_or_null("QuizController") != null, "F4 QuizController")
	_expect(is_equal_approx(f4.get_node("NPCs/Director").position.x, 399.0), "F4 Director pos preserved")
	var mg: Area2D = f4.get_node_or_null("Interactions/MiniGameHandoff") as Area2D
	_expect(mg != null and mg.enabled == false, "MiniGameHandoff disabled")
	if gs:
		gs.zone01_floor4_passed = false
	f4._on_quiz_continue()
	_expect(gs != null and gs.zone01_floor4_passed, "F4 continue sets zone01_floor4_passed")
	# MG interact must not change scene path claim — just prompt
	f4._on_mg_interacted(f4.get_node("Player"))
	prompt = f4.get_node("UI/PromptLabel")
	_expect(prompt.visible and "not available" in prompt.text.to_lower(), "MG handoff does not start mini-game")
	f4.queue_free()

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _answer_session_demo(ctl: QuizController) -> void:
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var opts = q.get("options", [])
		if opts is Array and opts.size() > 0:
			ctl.submit_option_text(str(opts[0]))
		else:
			ctl.submit_text_answer("demo")
		await process_frame
		ctl.advance_after_feedback()
		await process_frame


func _answer_n_correct_then_wrong(ctl: QuizController, n_correct: int) -> void:
	var i := 0
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var opts = q.get("options", [])
		if opts is Array and opts.size() > 0:
			if i < n_correct:
				ctl.submit_option_text(str(opts[0]))
			else:
				ctl.submit_option_text(str(opts[mini(1, opts.size() - 1)]))
		else:
			if i < n_correct:
				ctl.submit_text_answer("demo")
			else:
				ctl.submit_text_answer("")  # empty fails in demo too — force wrong via non-demo path
				# In demo empty fails; use that for wrong one_word
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
