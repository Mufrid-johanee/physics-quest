extends SceneTree
## Headless smoke check for Phase 1 foundation.
## Run:
##   Godot_v4.7.1-stable_win64_console.exe --path "d:\capstone 2" --headless --script res://scripts/tools/verify_foundation.gd

const PATHS := [
	"res://scenes/boot/BootTest.tscn",
	"res://scenes/player/Player.tscn",
	"res://scenes/npc/NPC.tscn",
	"res://scenes/school/School.tscn",
	"res://scenes/world_map/WorldMap.tscn",
	"res://scenes/zone01/Zone01_Exterior.tscn",
	"res://scenes/zone01/Zone01_Floor1.tscn",
	"res://scenes/zone01/Zone01_Floor2.tscn",
	"res://scenes/zone01/Zone01_Floor3.tscn",
	"res://scenes/zone01/Zone01_Floor4.tscn",
	"res://asset/sprites/animation/player animation.png",
	"res://asset/sprites/character/player seated.png",
	"res://asset/sprites/Environment/classroom.png",
	"res://asset/sprites/Environment/zone 1/factory_floor_2.png",
]

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	print("=== Physics Quest foundation verify ===")
	for path in PATHS:
		_check_exists(path)

	_check_pack("res://scenes/player/Player.tscn")
	_check_pack("res://scenes/npc/NPC.tscn")
	_check_pack("res://scenes/boot/BootTest.tscn")
	_check_pack("res://scenes/school/School.tscn")

	var gs := root.get_node_or_null("/root/GameState")
	var st := root.get_node_or_null("/root/SceneTransition")
	if gs == null:
		_failures += 1
		printerr("GameState autoload missing")
	elif not gs.is_zone_unlocked("zone_01"):
		_failures += 1
		printerr("Zone 01 should be unlocked by default")
	else:
		print("OK GameState zone_01 unlocked")

	if st == null:
		_failures += 1
		printerr("SceneTransition autoload missing")
	else:
		print("OK SceneTransition autoload")

	# Load main boot scene into tree briefly.
	var err := change_scene_to_file("res://scenes/boot/BootTest.tscn")
	if err != OK:
		_failures += 1
		printerr("change_scene_to_file BootTest failed: %s" % err)
	else:
		await process_frame
		await process_frame
		var boot := root.get_child(root.get_child_count() - 1)
		# After change_scene, current scene is under root; find Player.
		var current := current_scene
		if current == null:
			_failures += 1
			printerr("BootTest current_scene null")
		elif current.get_node_or_null("Player") == null:
			_failures += 1
			printerr("BootTest missing Player child")
		else:
			print("OK BootTest loaded with Player")
		# Silence unused warning
		if boot:
			pass

	print("=== failures: %d ===" % _failures)
	quit(_failures)


func _check_exists(path: String) -> void:
	if ResourceLoader.exists(path):
		print("OK exists %s" % path)
	else:
		_failures += 1
		printerr("MISSING %s" % path)


func _check_pack(path: String) -> void:
	var packed := load(path)
	if packed == null:
		_failures += 1
		printerr("LOAD FAIL %s" % path)
		return
	var inst = packed.instantiate()
	if inst == null:
		_failures += 1
		printerr("INSTANTIATE FAIL %s" % path)
		return
	print("OK instantiate %s (%s)" % [path, inst.get_class()])
	inst.free()
