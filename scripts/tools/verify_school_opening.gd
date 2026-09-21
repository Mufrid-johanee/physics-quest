extends SceneTree
## Headless structural check for School Opening.
## Godot_v4.7.1-stable_win64_console.exe --path "d:\capstone 2" --headless --script res://scripts/tools/verify_school_opening.gd

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== School Opening verify ===")
	var path := "res://scenes/school/SchoolOpening.tscn"
	if not ResourceLoader.exists(path):
		_fail("missing SchoolOpening.tscn")
		_finish()
		return

	var packed := load(path) as PackedScene
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	_expect(scene.get_node_or_null("ClassroomBackground") != null, "ClassroomBackground")
	_expect(scene.get_node_or_null("Teacher") != null, "Teacher")
	_expect(scene.get_node_or_null("AmbientStudents") != null, "AmbientStudents")
	_expect(scene.get_node_or_null("MainPlayer") != null, "MainPlayer")
	_expect(scene.get_node_or_null("Collision") != null, "Collision")
	_expect(scene.get_node_or_null("OpeningSequence") != null, "OpeningSequence")
	_expect(scene.get_node_or_null("DialoguePanel") != null, "DialoguePanel")

	var ambient: Node = scene.get_node("AmbientStudents")
	var student_count := 0
	for child in ambient.get_children():
		if str(child.name).begins_with("Student_"):
			student_count += 1
	_expect(student_count >= 4, "ambient students >= 4 (got %d)" % student_count)
	print("OK ambient student count=%d" % student_count)

	for marker_name in ["StandPoint", "WalkPoint_01", "WalkPoint_02", "DoorPoint", "ExitPoint"]:
		_expect(scene.get_node_or_null("OpeningSequence/%s" % marker_name) != null, marker_name)

	var player: Node = scene.get_node("MainPlayer")
	if player.has_method("set_seated"):
		print("OK MainPlayer has set_seated")
	else:
		_fail("MainPlayer missing set_seated")

	if "is_seated" in player and player.is_seated:
		print("OK MainPlayer starts seated")
	else:
		# start_seated applied in _ready; may need another frame
		await process_frame
		if "is_seated" in player and player.is_seated:
			print("OK MainPlayer starts seated")
		else:
			_fail("MainPlayer not seated after ready")

	# Ambient must remain present independently of player seated toggle
	if player.has_method("set_seated"):
		player.set_seated(false)
		await process_frame
		_expect(ambient.get_child_count() == student_count, "ambient count stable after player stands")
		player.set_seated(true)

	var bg: Sprite2D = scene.get_node("ClassroomBackground") as Sprite2D
	if bg and bg.texture:
		var sz := bg.texture.get_size()
		_expect(int(sz.x) == 1920 and int(sz.y) == 1072, "classroom texture 1920x1072 (got %sx%s)" % [sz.x, sz.y])
		print("OK classroom texture size %sx%s" % [sz.x, sz.y])
	else:
		_fail("ClassroomBackground texture missing")

	scene.queue_free()
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
