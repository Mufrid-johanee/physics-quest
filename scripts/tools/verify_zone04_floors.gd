extends SceneTree
## Zone 04 Floors 1–4 — Mira/Echo/Nadia/Farid + MG placeholder (no badge / Zone 05).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone04 floors verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone04_floor1_passed = false
		gs.zone04_floor2_passed = false
		gs.zone04_floor3_passed = false
		gs.zone04_floor4_passed = false
		gs.zone04_complete = false
		gs.zone04_badge_earned = false

	_expect(ResourceLoader.exists("res://data/zone04_floor1_questions.json"), "bank F1")
	_expect(ResourceLoader.exists("res://data/zone04_floor2_questions.json"), "bank F2")
	_expect(ResourceLoader.exists("res://data/zone04_floor3_questions.json"), "bank F3")
	_expect(ResourceLoader.exists("res://data/zone04_floor4_questions.json"), "bank F4")
	_expect(not ResourceLoader.exists("res://data/zone04_floor5_questions.json"), "no bank F5")

	var ctl: QuizController = (load("res://scripts/quiz/QuizController.gd") as GDScript).new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true

	for pair in [
		["load_zone04_floor1_bank", 50, false],
		["load_zone04_floor2_bank", 50, false],
		["load_zone04_floor3_bank", 50, true],
		["load_zone04_floor4_bank", 50, true],
	]:
		var method: String = pair[0]
		_expect(ctl.call(method), method)
		_expect(ctl.question_bank.size() == int(pair[1]), "%s size" % method)
		_expect(ctl.start_quiz(), "%s start" % method)
		_expect(ctl.get_session_total() == 10, "%s exactly 10" % method)
		_expect(_unique_ids(ctl), "%s unique" % method)
		if bool(pair[2]):
			var has_ow := false
			for q in ctl.question_bank:
				var fmt := str(q.get("format", "")).to_lower()
				if fmt == "one_word" or fmt == "one-word":
					has_ow = true
					break
			_expect(has_ow, "%s mixed formats" % method)
		var passed := {"ok": false}
		var failed := {"ok": false}
		ctl.quiz_passed.connect(func(_s, _t, _p): passed["ok"] = true, CONNECT_ONE_SHOT)
		ctl.quiz_failed.connect(func(_s, _t, _p): failed["ok"] = true, CONNECT_ONE_SHOT)
		await _answer_all_demo(ctl)
		_expect(passed["ok"], "%s demo pass" % method)
		passed["ok"] = false
		failed["ok"] = false
		ctl.quiz_passed.connect(func(_s, _t, _p): passed["ok"] = true, CONNECT_ONE_SHOT)
		ctl.quiz_failed.connect(func(_s, _t, _p): failed["ok"] = true, CONNECT_ONE_SHOT)
		_expect(ctl.retry_quiz(), "%s retry" % method)
		await _answer_n_correct_demo(ctl, 7)
		_expect(failed["ok"], "%s 7/10 fail" % method)

	ctl.queue_free()
	await process_frame

	await _check_floor(
		"res://scenes/zone04/Zone04_Floor1.tscn",
		"NPCs/Mira",
		"Professor_Mira.png",
		"substation_bay1_fundamentals.png",
		"load_zone04_floor1_bank",
		"Floor1ReturnSpawn",
		"zone04_floor1_passed"
	)
	await _check_floor(
		"res://scenes/zone04/Zone04_Floor2.tscn",
		"NPCs/Echo",
		"Echo.png",
		"substation_bay2_circuits.png",
		"load_zone04_floor2_bank",
		"Floor2ReturnSpawn",
		"zone04_floor2_passed"
	)
	await _check_floor(
		"res://scenes/zone04/Zone04_Floor3.tscn",
		"NPCs/Nadia",
		"Professor_Nadia.png",
		"substation_bay3_ohmslaw.png",
		"load_zone04_floor3_bank",
		"Floor3ReturnSpawn",
		"zone04_floor3_passed"
	)

	# Floor 3 must return Exterior (not Continue to Floor 4)
	var f3src := FileAccess.get_file_as_string("res://scripts/zone04/Zone04Floor3.gd")
	_expect(f3src.contains("Zone04_Exterior.tscn"), "F3 returns Exterior")
	_expect(not f3src.contains("Zone04_Floor4.tscn"), "F3 does not jump to Floor4")

	# Floor4 + MiniGameArea placeholder
	var f4: Node = (load("res://scenes/zone04/Zone04_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(f4)
	await process_frame
	await process_frame
	var farid = f4.get_node_or_null("NPCs/Farid")
	_expect(farid is CharacterBody2D, "Farid")
	_expect(farid.get_node_or_null("InteractionArea") is Area2D, "Farid InteractionArea")
	if farid and "sprite_texture" in farid and farid.sprite_texture:
		_expect(String(farid.sprite_texture.resource_path).ends_with("Engineer_Farid.png"), "Farid asset")
	if "can_interact" in farid:
		_expect(bool(farid.can_interact) == false, "Farid interactable off")
	var room: Sprite2D = f4.get_node_or_null("Background/RoomArt") as Sprite2D
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with("substation_bay4_diagnostics.png"), "Floor4 room")
	var mga: Area2D = f4.get_node_or_null("MiniGameArea") as Area2D
	_expect(mga != null, "MiniGameArea")
	_expect(mga.get_node_or_null("CollisionShape2D") != null, "MiniGameArea CollisionShape2D")
	_expect(f4.get_node_or_null("DemoCompleteUI") != null, "DemoCompleteUI")
	var f4src := FileAccess.get_file_as_string("res://scripts/zone04/Zone04Floor4.gd")
	_expect(f4src.contains("load_zone04_floor4_bank"), "loads floor4 bank")
	_expect(f4src.contains("PLACEHOLDER") or f4src.contains("SUCCESSFUL"), "placeholder labeling")
	_expect(f4src.contains("zone04_floor4_passed"), "sets floor4_passed")
	_expect(f4src.contains("mark_minigame_successful"), "marks MG successful")
	_expect(not f4src.contains("zone04_badge_earned = true"), "does not set badge")
	_expect(f4.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame1Button") != null, "PLAY MG1")

	var before_badge := bool(gs.zone04_badge_earned) if gs else false
	f4._on_quiz_continue()
	await process_frame
	_expect(gs != null and gs.zone04_floor4_passed, "CONTINUE sets floor4")
	_expect(mga.monitoring == true, "MiniGameArea monitoring after pass")
	_expect(gs == null or gs.zone04_badge_earned == before_badge, "quiz Continue does not award badge")
	_expect(gs == null or gs.zone04_complete == false, "quiz Continue does not complete zone")
	_expect(not gs.is_zone_unlocked(gs.ZONE_05), "quiz alone does not unlock ZONE_05")

	f4._on_play_mg1()
	await process_frame
	_expect(gs != null and gs.zone04_minigame_successful, "PLAY sets MG successful")
	_expect(gs != null and gs.zone04_complete, "PLAY sets complete")
	_expect(gs.is_zone_unlocked(gs.ZONE_05), "PLAY unlocks ZONE_05")
	_expect(gs == null or gs.zone04_badge_earned == false, "PLAY does not award fake badge")

	# Flags from F1–F3 continue
	if gs:
		gs.zone04_floor1_passed = false
		gs.zone04_floor2_passed = false
		gs.zone04_floor3_passed = false
	var f1: Node = (load("res://scenes/zone04/Zone04_Floor1.tscn") as PackedScene).instantiate()
	root.add_child(f1)
	await process_frame
	f1._on_quiz_continue()
	_expect(gs != null and gs.zone04_floor1_passed, "F1 continue sets flag")
	f1.queue_free()

	var f2: Node = (load("res://scenes/zone04/Zone04_Floor2.tscn") as PackedScene).instantiate()
	root.add_child(f2)
	await process_frame
	f2._on_quiz_continue()
	_expect(gs != null and gs.zone04_floor2_passed, "F2 continue sets flag")
	f2.queue_free()

	var f3: Node = (load("res://scenes/zone04/Zone04_Floor3.tscn") as PackedScene).instantiate()
	root.add_child(f3)
	await process_frame
	f3._on_quiz_continue()
	_expect(gs != null and gs.zone04_floor3_passed, "F3 continue sets flag")
	f3.queue_free()

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _check_floor(
	path: String,
	npc_path: String,
	tex_suffix: String,
	room_suffix: String,
	load_method: String,
	spawn_marker: String,
	flag_name: String
) -> void:
	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var npc = scene.get_node_or_null(npc_path)
	_expect(npc is CharacterBody2D, "%s NPC" % path)
	_expect(npc.get_node_or_null("InteractionArea") is Area2D, "%s InteractionArea" % path)
	_expect(npc.get_node_or_null("InteractionArea/CollisionShape2D") != null, "%s IA shape" % path)
	if npc and "can_interact" in npc:
		_expect(bool(npc.can_interact) == false, "%s interactable off" % path)
	if npc and "sprite_texture" in npc and npc.sprite_texture:
		_expect(String(npc.sprite_texture.resource_path).ends_with(tex_suffix), "%s texture" % path)
	var room: Sprite2D = scene.get_node_or_null("Background/RoomArt") as Sprite2D
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with(room_suffix), "%s room" % path)
	_expect(scene.get_node_or_null("DialoguePanel") != null, "%s DialoguePanel" % path)
	_expect(scene.get_node_or_null("QuizPanel") != null, "%s QuizPanel" % path)
	_expect(scene.get_node_or_null("QuizController") != null, "%s QuizController" % path)
	_expect(scene.get_node_or_null("Interactions/ExteriorExit") != null, "%s ExteriorExit" % path)
	var src := FileAccess.get_file_as_string(path.replace("scenes/zone04/", "scripts/zone04/").replace(".tscn", ".gd").replace("Zone04_", "Zone04"))
	# Map scene path to script path manually
	var script_path := ""
	if path.ends_with("Floor1.tscn"):
		script_path = "res://scripts/zone04/Zone04Floor1.gd"
	elif path.ends_with("Floor2.tscn"):
		script_path = "res://scripts/zone04/Zone04Floor2.gd"
	elif path.ends_with("Floor3.tscn"):
		script_path = "res://scripts/zone04/Zone04Floor3.gd"
	if not script_path.is_empty():
		src = FileAccess.get_file_as_string(script_path)
		_expect(src.contains(load_method), "%s loads bank" % path)
		_expect(src.contains(spawn_marker), "%s return spawn" % path)
		_expect(src.contains(flag_name), "%s GameState flag" % path)
		_expect(src.contains("Zone04_Exterior.tscn"), "%s returns Exterior" % path)
	scene.queue_free()
	await process_frame


func _unique_ids(ctl: QuizController) -> bool:
	var seen: Dictionary = {}
	for q in ctl.session_questions:
		var qid := str(q.get("id", ""))
		if qid.is_empty() or seen.has(qid):
			return false
		seen[qid] = true
	return true


func _answer_all_demo(ctl: QuizController) -> void:
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var fmt := str(q.get("format", "")).to_lower()
		if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
			ctl.submit_text_answer("demo")
		else:
			var opts = q.get("options", [])
			var pick := str(opts[0]) if opts is Array and opts.size() > 0 else ""
			ctl.submit_option_text(pick)
		ctl.advance_after_feedback()
		await process_frame


func _answer_n_correct_demo(ctl: QuizController, n: int) -> void:
	var answered := 0
	while ctl.is_active():
		var q: Dictionary = ctl.get_current_question()
		var fmt := str(q.get("format", "")).to_lower()
		if answered < n:
			if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
				ctl.submit_text_answer("demo")
			else:
				var opts = q.get("options", [])
				ctl.submit_option_text(str(opts[0]) if opts is Array and opts.size() > 0 else "")
		else:
			if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
				ctl.submit_text_answer("")
			else:
				var opts2 = q.get("options", [])
				var wrong := str(opts2[1]) if opts2 is Array and opts2.size() > 1 else "__wrong__"
				ctl.submit_option_text(wrong)
		answered += 1
		ctl.advance_after_feedback()
		await process_frame


func _expect(cond: bool, label: String) -> void:
	if cond:
		print("OK %s" % label)
	else:
		_failures += 1
		printerr("FAIL %s" % label)
