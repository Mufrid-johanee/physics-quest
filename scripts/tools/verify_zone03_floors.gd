extends SceneTree
## Zone 03 Floors 1–4 assessments + MiniGameArea demo (no exact layout asserts).

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Zone03 floors + demo verify ===")
	var gs := root.get_node_or_null("/root/GameState")
	if gs:
		gs.zone03_floor1_passed = false
		gs.zone03_floor2_passed = false
		gs.zone03_floor3_passed = false
		gs.zone03_floor4_passed = false
		gs.zone03_complete = false
		gs.zone03_badge_earned = false

	# Banks
	_expect(ResourceLoader.exists("res://data/zone03_floor1_questions.json"), "bank F1")
	_expect(ResourceLoader.exists("res://data/zone03_floor2_questions.json"), "bank F2")
	_expect(ResourceLoader.exists("res://data/zone03_floor3_questions.json"), "bank F3")
	_expect(ResourceLoader.exists("res://data/zone03_floor4_questions.json"), "bank F4")
	_expect(FileAccess.file_exists("res://scenes/minigames/zone03/README.md"), "minigames folder")
	_expect(FileAccess.file_exists("res://scripts/minigames/zone03/README.md"), "minigame scripts folder")

	var ctl: QuizController = (load("res://scripts/quiz/QuizController.gd") as GDScript).new() as QuizController
	root.add_child(ctl)
	ctl.demo_first_option_is_correct = true

	for pair in [
		["load_zone03_floor1_bank", 50, false],
		["load_zone03_floor2_bank", 50, false],
		["load_zone03_floor3_bank", 50, true],
		["load_zone03_floor4_bank", 50, true],
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

	# Floor casts
	await _check_floor(
		"res://scenes/zone03/Zone03_Floor1.tscn",
		"NPCs/Farid",
		"char_farid_idle.png",
		"signal_station_deck1_waves.png",
		"load_zone03_floor1_bank",
		true
	)
	await _check_floor(
		"res://scenes/zone03/Zone03_Floor2.tscn",
		"NPCs/Shirin",
		"char_shirin_idle.png",
		"signal_station_deck2_sound.png",
		"load_zone03_floor2_bank",
		true
	)
	await _check_floor(
		"res://scenes/zone03/Zone03_Floor3.tscn",
		"NPCs/Tania",
		"char_tania_idle.png",
		"signal_station_deck3_optics.png",
		"load_zone03_floor3_bank",
		true
	)

	# Floor4 + MiniGameArea demo
	var f4: Node = (load("res://scenes/zone03/Zone03_Floor4.tscn") as PackedScene).instantiate()
	root.add_child(f4)
	await process_frame
	await process_frame
	var anwar = f4.get_node_or_null("NPCs/Anwar")
	_expect(anwar is CharacterBody2D, "Anwar")
	_expect(anwar.get_node_or_null("InteractionArea") is Area2D, "Anwar InteractionArea")
	if anwar and "sprite_texture" in anwar and anwar.sprite_texture:
		_expect(String(anwar.sprite_texture.resource_path).ends_with("char_anwar_idle.png"), "Anwar asset")
	if "can_interact" in anwar:
		_expect(bool(anwar.can_interact) == false, "Anwar interactable off")
	var room: Sprite2D = f4.get_node_or_null("Background/RoomArt") as Sprite2D
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with("signal_station_deck4_diagnostic.png"), "Floor4 room")
	var mga: Area2D = f4.get_node_or_null("MiniGameArea") as Area2D
	_expect(mga != null, "MiniGameArea")
	_expect(mga.get_node_or_null("CollisionShape2D") != null, "MiniGameArea CollisionShape2D")
	_expect(f4.get_node_or_null("DemoCompleteUI") != null, "DemoCompleteUI")
	_expect(f4.find_child("MiniGameHandoff", true, false) == null, "no MiniGameHandoff")
	var f4src := FileAccess.get_file_as_string("res://scripts/zone03/Zone03Floor4.gd")
	_expect(f4src.contains("load_zone03_floor4_bank"), "loads floor4 bank")
	_expect(f4src.contains("PLACEHOLDER") or f4src.contains("SUCCESSFUL"), "placeholder labeling")
	_expect(f4src.contains("EXTERIOR_PATH"), "Floor4 can return to Exterior")
	_expect(f4.get_node_or_null("Interactions/ExteriorExit") != null, "ExteriorExit on Floor4")
	_expect(f4.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame1Button") != null, "PLAY MG1")
	_expect(f4.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/ReturnToWorldMapButton") != null, "RETURN WM")

	# Pass continue enables MG + sets floor4 — does NOT unlock yet
	var before_badge := bool(gs.zone03_badge_earned) if gs else false
	f4._on_quiz_continue()
	await process_frame
	_expect(gs != null and gs.zone03_floor4_passed, "CONTINUE sets floor4")
	_expect(mga.monitoring == true, "MiniGameArea monitoring after pass")
	_expect(gs == null or gs.zone03_badge_earned == before_badge, "quiz Continue does not award badge")
	_expect(gs == null or gs.zone03_complete == false, "quiz Continue does not complete zone")
	_expect(not gs.is_zone_unlocked(gs.ZONE_04), "quiz alone does not unlock ZONE_04")

	# PLAY SUCCESSFUL unlocks Zone 04
	f4._open_placeholder_ui()
	await process_frame
	var play2vis: CanvasItem = f4.get_node_or_null("DemoCompleteUI/Root/Center/Panel/Margin/VBox/PlayMiniGame2Button") as CanvasItem
	_expect(play2vis == null or play2vis.visible == false, "exactly one PLAY visible")
	f4._on_play_mg1()
	await process_frame
	_expect(gs != null and gs.zone03_minigame_successful, "PLAY sets MG successful")
	_expect(gs != null and gs.zone03_complete, "PLAY sets complete")
	_expect(gs.is_zone_unlocked(gs.ZONE_04), "PLAY unlocks ZONE_04")
	_expect(gs == null or gs.zone03_badge_earned == false, "PLAY does not award fake badge")

	# Floor flags from F1–F3 continue
	var f1: Node = (load("res://scenes/zone03/Zone03_Floor1.tscn") as PackedScene).instantiate()
	root.add_child(f1)
	await process_frame
	f1._on_quiz_continue()
	_expect(gs != null and gs.zone03_floor1_passed, "F1 flag")
	f1.queue_free()

	var f2: Node = (load("res://scenes/zone03/Zone03_Floor2.tscn") as PackedScene).instantiate()
	root.add_child(f2)
	await process_frame
	f2._on_quiz_continue()
	_expect(gs != null and gs.zone03_floor2_passed, "F2 flag")
	f2.queue_free()

	var f3: Node = (load("res://scenes/zone03/Zone03_Floor3.tscn") as PackedScene).instantiate()
	root.add_child(f3)
	await process_frame
	f3._on_quiz_continue()
	_expect(gs != null and gs.zone03_floor3_passed, "F3 flag")
	var f3src := FileAccess.get_file_as_string("res://scripts/zone03/Zone03Floor3.gd")
	_expect(f3src.contains("EXTERIOR_PATH"), "F3 returns to Exterior")
	_expect(not f3src.contains("Continue to Floor 4"), "no Continue to Floor 4")
	_expect(not f3src.contains("Zone03_Floor4.tscn"), "F3 does not load Floor4")
	f3.queue_free()

	f4.queue_free()
	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _check_floor(path: String, npc_path: String, asset_suffix: String, room_suffix: String, bank_fn: String, has_exit: bool) -> void:
	var scene: Node = (load(path) as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var npc = scene.get_node_or_null(npc_path)
	_expect(npc is CharacterBody2D, "%s CharacterBody2D" % npc_path)
	_expect(npc.get_node_or_null("InteractionArea") is Area2D, "%s InteractionArea" % npc_path)
	if npc and "sprite_texture" in npc and npc.sprite_texture:
		_expect(String(npc.sprite_texture.resource_path).ends_with(asset_suffix), "%s asset" % npc_path)
	if "can_interact" in npc:
		_expect(bool(npc.can_interact) == false, "%s interactable off" % npc_path)
	var room: Sprite2D = scene.get_node_or_null("Background/RoomArt") as Sprite2D
	if room and room.texture:
		_expect(String(room.texture.resource_path).ends_with(room_suffix), "%s room" % path.get_file())
	_expect(scene.get_node_or_null("DialoguePanel") != null, "%s DialoguePanel" % path.get_file())
	_expect(scene.get_node_or_null("QuizController") != null, "%s QuizController" % path.get_file())
	_expect(scene.get_node_or_null("QuizPanel") != null, "%s QuizPanel" % path.get_file())
	if has_exit:
		_expect(scene.get_node_or_null("Interactions/ExteriorExit") != null, "%s ExteriorExit" % path.get_file())
	var src_path := path.replace("scenes/zone03/", "scripts/zone03/").replace(".tscn", ".gd").replace("Zone03_", "Zone03")
	# Map scene names to scripts
	var script_map := {
		"Zone03_Floor1.tscn": "res://scripts/zone03/Zone03Floor1.gd",
		"Zone03_Floor2.tscn": "res://scripts/zone03/Zone03Floor2.gd",
		"Zone03_Floor3.tscn": "res://scripts/zone03/Zone03Floor3.gd",
	}
	var sp: String = script_map.get(path.get_file(), "")
	if not sp.is_empty():
		var src := FileAccess.get_file_as_string(sp)
		_expect(src.contains(bank_fn), "%s loads bank" % path.get_file())
	scene.queue_free()
	await process_frame


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
				else:
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
