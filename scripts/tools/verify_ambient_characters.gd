extends SceneTree
## Headless verify: ambient characters on Zone 01–04 floors.
## Guide: Docs/AMBIENT_CHARACTERS.md
## When adding ambient nodes, extend the expected Dictionary in _check_floors().


func _init() -> void:
	var failed := 0
	failed += _check_scripts()
	failed += _check_floors()
	failed += _check_school()
	failed += _check_player_mask()
	if failed == 0:
		print("VERIFY_AMBIENT: PASS")
		quit(0)
	else:
		print("VERIFY_AMBIENT: FAIL count=", failed)
		quit(1)


func _expect(cond: bool, msg: String) -> int:
	if cond:
		print("  OK  ", msg)
		return 0
	print("  FAIL ", msg)
	return 1


func _check_scripts() -> int:
	var n := 0
	n += _expect(ResourceLoader.exists("res://scripts/npc/AmbientProximity.gd"), "AmbientProximity.gd")
	n += _expect(ResourceLoader.exists("res://scripts/npc/AmbientDialoguePools.gd"), "AmbientDialoguePools.gd")
	var prox: Script = load("res://scripts/npc/AmbientProximity.gd") as Script
	n += _expect(prox != null, "AmbientProximity.gd compiles")
	var pools: Script = load("res://scripts/npc/AmbientDialoguePools.gd") as Script
	n += _expect(pools != null, "AmbientDialoguePools.gd compiles")
	return n


func _check_school() -> int:
	var n := 0
	var f := FileAccess.open("res://scripts/school/SchoolOpening.gd", FileAccess.READ)
	if f == null:
		return _expect(false, "SchoolOpening.gd open")
	var src := f.get_as_text()
	f.close()
	n += _expect("TEACHER_LINE_SUPERVISOR" in src, "Teacher supervisor context const")
	n += _expect("Each floor of the factory has a Supervisor" in src, "Teacher supervisor message text")
	return n


func _check_player_mask() -> int:
	var n := 0
	var scene: PackedScene = load("res://scenes/player/Player.tscn") as PackedScene
	if scene == null:
		return _expect(false, "Player.tscn")
	var inst := scene.instantiate()
	n += _expect(int(inst.collision_mask) & 4 != 0, "Player collision_mask includes NPC layer 4")
	inst.free()
	return n


func _check_floors() -> int:
	var n := 0
	var expected: Dictionary = {
		"res://scenes/zone01/Zone01_Floor1.tscn": ["NPCs/Workers/Worker_01/AmbientProximity", "NPCs/Workers/Worker_02/AmbientProximity", "NPCs/Workers/Worker_03/AmbientProximity"],
		"res://scenes/zone01/Zone01_Floor2.tscn": ["NPCs/LabAssistant/AmbientProximity"],
		"res://scenes/zone01/Zone01_Floor3.tscn": ["NPCs/Workers/Worker_01/AmbientProximity", "NPCs/Workers/Worker_02/AmbientProximity"],
		"res://scenes/zone01/Zone01_Floor4.tscn": ["LabAssistant2/AmbientProximity", "LabAssistant2/BodyCollision", "Worker7/AmbientProximity", "Worker7/BodyCollision"],
		"res://scenes/zone02/Zone02_Floor3.tscn": ["Worker1/AmbientProximity", "Worker7/AmbientProximity"],
		"res://scenes/zone02/Zone02_Floor4.tscn": ["NPCs/Worker5/AmbientProximity", "NPCs/Worker5/BodyCollision"],
		"res://scenes/zone03/Zone03_Floor1.tscn": ["RinaForntView/AmbientProximity", "Interactions/ExteriorExit/Worker7/AmbientProximity"],
		"res://scenes/zone03/Zone03_Floor2.tscn": ["Interactions/ExteriorExit/Supervisor1/AmbientProximity", "Interactions/ExteriorExit/Worker7/AmbientProximity"],
		"res://scenes/zone03/Zone03_Floor3.tscn": ["Worker1/AmbientProximity", "Worker2/AmbientProximity", "Collision/BoundLeft/Worker5/AmbientProximity"],
		"res://scenes/zone03/Zone03_Floor4.tscn": ["Background/Worker4/AmbientProximity", "Background/Worker2/AmbientProximity", "MiniGameArea/Worker5/AmbientProximity"],
		"res://scenes/zone04/Zone04_Floor1.tscn": ["Supervisor1/AmbientProximity", "Interactions/ExteriorExit/LabAssistant2/AmbientProximity", "Interactions/ExteriorExit/Worker5/AmbientProximity"],
		"res://scenes/zone04/Zone04_Floor2.tscn": ["NPCs/Worker5/AmbientProximity", "Interactions/ExteriorExit/Supervisor1/AmbientProximity", "Interactions/ExteriorExit/Worker7/AmbientProximity", "Interactions/ExteriorExit/RinaForntView/AmbientProximity"],
		"res://scenes/zone04/Zone04_Floor3.tscn": ["Worker1/AmbientProximity", "Worker2/AmbientProximity", "Collision/BoundLeft/Worker5/AmbientProximity", "Collision/BoundLeft/Worker6/AmbientProximity"],
		"res://scenes/zone04/Zone04_Floor4.tscn": ["Background/Worker4/AmbientProximity", "Background/Worker2/AmbientProximity", "Background/Worker7/AmbientProximity", "Karim/AmbientProximity"],
	}
	for path in expected.keys():
		var scene: PackedScene = load(path) as PackedScene
		if scene == null:
			n += _expect(false, "load " + path)
			continue
		var root := scene.instantiate()
		for node_path in expected[path]:
			var node := root.get_node_or_null(NodePath(node_path))
			n += _expect(node != null, "%s :: %s" % [path.get_file(), node_path])
			if node and String(node_path).ends_with("AmbientProximity"):
				n += _expect(node is Area2D, "%s AmbientProximity is Area2D" % node_path)
				# Script may fail to attach under --script if floor scripts need autoloads;
				# verify ext_resource / CollisionShape instead of get_script().
				var shape := node.get_node_or_null("CollisionShape2D")
				n += _expect(shape != null, "%s has CollisionShape2D" % node_path)
				n += _expect(shape.shape != null, "%s CollisionShape has shape" % node_path)
		# Supervisor InteractionArea still present on assessment floors
		if "Zone01_Floor1" in path or "Zone01_Floor2" in path or "Zone01_Floor3" in path:
			n += _expect(root.get_node_or_null("NPCs/Manager/InteractionArea") != null, "%s Manager InteractionArea intact" % path.get_file())
			var mgr := root.get_node_or_null("NPCs/Manager")
			if mgr and "display_name" in mgr:
				n += _expect(str(mgr.display_name) == "Supervisor", "%s Manager display_name Supervisor" % path.get_file())
		root.free()
	# Floors with no ambient still load
	for path in ["res://scenes/zone02/Zone02_Floor1.tscn", "res://scenes/zone02/Zone02_Floor2.tscn"]:
		var scene2: PackedScene = load(path) as PackedScene
		n += _expect(scene2 != null, "load " + path)
		if scene2:
			var r := scene2.instantiate()
			n += _expect(r.get_node_or_null("DialoguePanel") != null, path.get_file() + " DialoguePanel")
			r.free()
	return n
