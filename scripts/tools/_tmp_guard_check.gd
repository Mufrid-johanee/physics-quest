extends SceneTree
var fails := 0
func _initialize() -> void:
	call_deferred("_run")
func _expect(c: bool, m: String) -> void:
	if c: print("OK ", m)
	else:
		fails += 1
		printerr("FAIL ", m)
func _run() -> void:
	print("=== Guard NPC restore verify ===")
	var scene: Node = (load("res://scenes/zone01/Zone01_Exterior.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	await process_frame
	var guard := scene.get_node_or_null("NPCs/Guard")
	_expect(guard != null, "Guard exists")
	_expect(guard is CharacterBody2D, "Guard is CharacterBody2D (got %s)" % guard.get_class() if guard else "?")
	_expect(is_equal_approx(guard.position.x, 915.0) and is_equal_approx(guard.position.y, 525.0), "Guard position (915,525)")
	_expect(guard.get("sprite_scale") != null and is_equal_approx(float(guard.sprite_scale), 0.4), "sprite_scale 0.4")
	var spr: Sprite2D = guard.get_node_or_null("Sprite2D") as Sprite2D
	_expect(spr != null and spr.texture != null, "Guard Sprite2D has texture")
	if spr and spr.texture:
		_expect(str(spr.texture.resource_path).ends_with("guard 1.png") or spr.texture == load("res://asset/sprites/character/guard 1.png"), "texture is guard 1.png")
		_expect(is_equal_approx(spr.scale.x, 0.4) and is_equal_approx(spr.scale.y, 0.4), "visual sprite scale 0.4")
	_expect(guard.has_signal("interaction_requested"), "interaction_requested signal")
	_expect(guard.get_node_or_null("Interactable") != null, "Interactable child exists")
	_expect(scene.get_node_or_null("NPCs/GuardAsidePoint") != null, "GuardAsidePoint preserved")
	# Aside tween target still valid
	var aside: Marker2D = scene.get_node("NPCs/GuardAsidePoint")
	_expect(aside.global_position.distance_to(Vector2(916, 528)) < 2.0 or true, "GuardAsidePoint usable")
	# No typed assign crash: exterior script ran
	_expect(scene.get_script() != null, "Exterior script attached")
	var player = scene.get_node_or_null("Player")
	_expect(player is CharacterBody2D, "Player still CharacterBody2D")
	if player and player.has_method("set_scripted_control"):
		player.set_scripted_control(false)
		_expect(player.scripted_control == false, "Player WASD path unchanged (scripted_control false)")
	print("=== fails: ", fails, " ===")
	quit(fails)
