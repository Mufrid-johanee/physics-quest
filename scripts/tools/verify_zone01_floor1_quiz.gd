extends SceneTree
## Floor 1 quiz + gate verification (Phase 11A). No visual placement claims.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone01 Floor1 quiz verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone01_floor1_passed = false
		gs.zone01_guard_granted = true

	# --- Bank / controller unit checks ---
	var ctl_script := load("res://scripts/quiz/QuizController.gd")
	_expect(ctl_script != null, "QuizController script loads")
	var ctl: QuizController = ctl_script.new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true
	_expect(ctl.load_floor1_bank(), "Floor1 bank loads from res://data/")
	_expect(ctl.question_bank.size() == 50, "bank has 50 questions (got %d)" % ctl.question_bank.size())
	_expect(ctl.start_quiz(), "start_quiz")
	_expect(ctl.get_session_total() == 10, "exactly 10 selected (got %d)" % ctl.get_session_total())
	_expect(_session_ids_unique(ctl), "no duplicate ids in session")
	_expect(_all_have_four_options(ctl), "each MCQ has 4 options")

	# Demo: first option correct for all → 10/10 pass
	var passed_flag := {"ok": false}
	var failed_flag := {"ok": false}
	ctl.quiz_passed.connect(func(s, t, p): passed_flag["ok"] = true)
	ctl.quiz_failed.connect(func(s, t, p): failed_flag["ok"] = true)
	await _answer_all_first_option(ctl)
	_expect(passed_flag["ok"] and not failed_flag["ok"], "10/10 demo pass emits quiz_passed")
	_expect(ctl.get_score() == 10, "score 10/10")
	_expect(is_equal_approx(ctl.get_percent(), 100.0), "percent 100")

	# 8/10 pass
	passed_flag["ok"] = false
	failed_flag["ok"] = false
	ctl.demo_first_option_is_correct = true
	_expect(ctl.retry_quiz(), "retry starts new quiz")
	_expect(ctl.get_session_total() == 10, "retry still 10 questions")
	await _answer_n_first_then_wrong(ctl, 8)
	_expect(passed_flag["ok"], "8/10 passes")
	_expect(ctl.get_score() == 8, "score 8")

	# 7/10 fail — must not set GameState
	if gs:
		gs.zone01_floor1_passed = false
	passed_flag["ok"] = false
	failed_flag["ok"] = false
	_expect(ctl.retry_quiz(), "retry for fail case")
	await _answer_n_first_then_wrong(ctl, 7)
	_expect(failed_flag["ok"] and not passed_flag["ok"], "7/10 fails")
	_expect(gs == null or gs.zone01_floor1_passed == false, "fail does not set zone01_floor1_passed")

	# Non-demo uses correct_answer string (spot check)
	ctl.demo_first_option_is_correct = false
	_expect(ctl.start_quiz(), "start non-demo quiz")
	var q: Dictionary = ctl.get_current_question()
	var correct := str(q.get("correct_answer", ""))
	var opts: Array = q.get("options", [])
	_expect(opts.has(correct), "correct_answer is one of the options")
	# Submit wrong then right path not needed — just ensure effective answer differs from demo when first != correct
	if opts.size() > 0 and str(opts[0]) != correct:
		ctl.submit_option_text(str(opts[0]))
		await process_frame
		# score should still be 0 after wrong first option in non-demo
		_expect(ctl.get_score() == 0, "non-demo: first option wrong when not matching correct_answer")

	ctl.queue_free()
	await process_frame

	# --- Scene structural + gate ---
	var err := change_scene_to_file("res://scenes/zone01/Zone01_Floor1.tscn")
	_expect(err == OK, "load Floor1 scene")
	await process_frame
	await process_frame
	var floor1 := current_scene
	_expect(floor1 != null and floor1.name == "Zone01_Floor1", "Floor1 current")
	_expect(floor1.get_node_or_null("NPCs/Manager/InteractionArea") != null, "Manager InteractionArea exists")
	_expect(floor1.get_node_or_null("NPCs/Manager/InteractionArea/CollisionShape2D") != null, "Manager InteractionArea shape")
	_expect(floor1.get_node_or_null("QuizController") != null, "QuizController node")
	_expect(floor1.get_node_or_null("QuizPanel") != null, "QuizPanel node")

	if gs:
		gs.zone01_floor1_passed = false
	var f2 = floor1.get_node_or_null("Interactions/Floor2Entrance")
	_expect(f2 != null, "Floor2Entrance exists")
	if floor1.has_method("_on_floor2_interacted"):
		floor1._on_floor2_interacted(null)
		await process_frame
		await create_timer(0.35).timeout
		_expect(current_scene != null and current_scene.name == "Zone01_Floor1", "Floor2 blocked before pass")

	if gs:
		gs.zone01_floor1_passed = true
	# Reload Floor1 so interact uses fresh scene with flag already true
	err = change_scene_to_file("res://scenes/zone01/Zone01_Floor1.tscn")
	_expect(err == OK, "reload Floor1 for pass gate")
	await process_frame
	await process_frame
	floor1 = current_scene
	if floor1 and floor1.has_method("_on_floor2_interacted"):
		floor1._on_floor2_interacted(null)
		var st := root.get_node_or_null("/root/SceneTransition")
		if st and st.has_signal("transition_finished"):
			await st.transition_finished
		var ok_f2 := false
		for i in 90:
			await process_frame
			if current_scene and (
				current_scene.name == "Zone01_Floor2"
				or str(current_scene.scene_file_path).ends_with("Zone01_Floor2.tscn")
			):
				ok_f2 = true
				break
		_expect(ok_f2, "Floor2 allowed after pass")
	else:
		_expect(false, "Floor1 missing after reload")

	# Light regression: school path still loads
	err = change_scene_to_file("res://scenes/school/SchoolOpening.tscn")
	_expect(err == OK, "SchoolOpening still loads")
	await process_frame

	_finish()


func _answer_all_first_option(ctl: QuizController) -> void:
	for i in 10:
		var q: Dictionary = ctl.get_current_question()
		var opts: Array = q.get("options", [])
		_expect(opts.size() == 4, "question %d has 4 options" % (i + 1))
		ctl.submit_option_text(str(opts[0]))
		await process_frame
		ctl.advance_after_feedback()
		await process_frame


func _answer_n_first_then_wrong(ctl: QuizController, correct_count: int) -> void:
	for i in 10:
		var q: Dictionary = ctl.get_current_question()
		var opts: Array = q.get("options", [])
		if i < correct_count:
			ctl.submit_option_text(str(opts[0]))
		else:
			# Pick a non-first option (demo treats first as correct)
			ctl.submit_option_text(str(opts[1]))
		await process_frame
		ctl.advance_after_feedback()
		await process_frame


func _session_ids_unique(ctl: QuizController) -> bool:
	var seen: Dictionary = {}
	for q in ctl.session_questions:
		var id := str(q.get("id", ""))
		if id.is_empty() or seen.has(id):
			return false
		seen[id] = true
	return seen.size() == ctl.session_questions.size()


func _all_have_four_options(ctl: QuizController) -> bool:
	for q in ctl.session_questions:
		var opts = q.get("options", [])
		if not (opts is Array) or opts.size() != 4:
			return false
	return true


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)


func _finish() -> void:
	print("=== failures: %d ===" % _failures)
	quit(1 if _failures > 0 else 0)
