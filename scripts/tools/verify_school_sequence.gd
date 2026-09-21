extends SceneTree
## Advances School Opening dialogue and waits for World Map transition.
## NOTE: Does not visually judge placement quality.

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== School Opening sequence verify ===")
	var err := change_scene_to_file("res://scenes/school/SchoolOpening.tscn")
	if err != OK:
		printerr("FAIL load SchoolOpening: %s" % err)
		quit(1)
		return

	await process_frame
	await process_frame

	var school := current_scene
	if school == null:
		printerr("FAIL current_scene null")
		quit(1)
		return

	# Wait for auto_start delay + dialogue visible
	await create_timer(0.8).timeout
	var dialogue := school.get_node_or_null("DialoguePanel")
	if dialogue == null:
		printerr("FAIL DialoguePanel missing")
		quit(1)
		return

	# Advance teacher + student lines
	for i in 2:
		var btn: Button = dialogue.get_node_or_null("Root/Panel/Margin/VBox/Continue")
		if btn == null:
			printerr("FAIL Continue button missing")
			quit(1)
			return
		btn.emit_signal("pressed")
		await process_frame
		await create_timer(0.15).timeout
		print("OK dialogue continue %d" % (i + 1))

	# Wait for walk + fade transition (scripted path can take several seconds)
	var reached_map := false
	for _i in 120:
		await create_timer(0.25).timeout
		var cur := current_scene
		if cur and cur.name == "WorldMap":
			reached_map = true
			break
		# Also accept path-based detection
		if cur and str(cur.scene_file_path).ends_with("WorldMap.tscn"):
			reached_map = true
			break

	if reached_map:
		print("OK reached WorldMap stub")
	else:
		_failures += 1
		var cur2 := current_scene
		printerr("FAIL did not reach WorldMap (current=%s path=%s)" % [
			cur2.name if cur2 else "null",
			cur2.scene_file_path if cur2 else "null"
		])

	print("=== failures: %d ===" % _failures)
	quit(_failures)
