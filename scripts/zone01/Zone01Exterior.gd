extends Node2D
## Zone 01 Factory Exterior. Scene tree owns all layout transforms.
## Script only wires spawn, guard dialogue → gate grant, and Floor 1 entry.

const FLOOR1_PATH := "res://scenes/zone01/Zone01_Floor1.tscn"

## Documented exterior beat (master §2.3): guard expects student; grants gate access.
const GUARD_LINE_1 := "We've been expecting you. Your physics assignment still isn't turned in."
const GUARD_LINE_2 := "Alright — I'll open the gate. Go on inside when you're ready."

@onready var player: CharacterBody2D = $Player
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var guard: CharacterBody2D = $NPCs/Guard
@onready var guard_aside: Marker2D = $NPCs/GuardAsidePoint
@onready var gate_locked: Sprite2D = $Gate/LockedVisual
@onready var gate_open: Sprite2D = $Gate/OpenVisual
@onready var gate_barrier: CollisionShape2D = $Gate/Barrier/CollisionShape2D
@onready var floor1_entrance: Area2D = $InteractionPoints/Floor1Entrance
@onready var dialogue: CanvasLayer = $DialoguePanel
@onready var prompt_label: Label = $UI/PromptLabel

var _guard_busy: bool = false


func _ready() -> void:
	if player_spawn and player:
		player.global_position = player_spawn.global_position
	if player.has_method("set_seated"):
		player.set_seated(false)
	if player.has_method("set_scripted_control"):
		player.set_scripted_control(false)

	if prompt_label:
		prompt_label.visible = false

	_apply_gate_visuals(GameState.zone01_guard_granted)

	# Exterior Guard: auto-trigger via InteractionArea (no E/F).
	# Shared NPC Interactable remains disabled (can_interact = false).
	var guard_area: Area2D = guard.get_node_or_null("InteractionArea") as Area2D if guard else null
	if guard_area:
		if not guard_area.body_entered.is_connected(_on_guard_area_entered):
			guard_area.body_entered.connect(_on_guard_area_entered)
	elif guard and guard.has_signal("interaction_requested"):
		# Fallback only if InteractionArea missing.
		guard.interaction_requested.connect(_on_guard_interaction)

	if floor1_entrance:
		if floor1_entrance.has_signal("interacted"):
			floor1_entrance.interacted.connect(_on_floor1_interacted)
		if floor1_entrance.has_signal("player_entered"):
			floor1_entrance.player_entered.connect(_on_floor1_entered)
		if floor1_entrance.has_signal("player_exited"):
			floor1_entrance.player_exited.connect(_on_floor1_exited)
		_update_floor1_prompt_enabled()


func _apply_gate_visuals(opened: bool) -> void:
	if gate_locked:
		gate_locked.visible = not opened
	if gate_open:
		gate_open.visible = opened
	if gate_barrier:
		gate_barrier.disabled = opened
	_update_floor1_prompt_enabled()


func _update_floor1_prompt_enabled() -> void:
	if floor1_entrance and "enabled" in floor1_entrance:
		floor1_entrance.enabled = GameState.zone01_guard_granted


func _on_guard_area_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	_on_guard_interaction(guard)


func _on_guard_interaction(_npc: Node) -> void:
	if _guard_busy:
		return
	_guard_busy = true
	if GameState.zone01_guard_granted:
		await _show_line("Guard", "Gate's open. Head through when you're ready.")
		dialogue.hide_dialogue()
		_guard_busy = false
		return

	await _show_line("Guard", GUARD_LINE_1)
	await _show_line("Guard", GUARD_LINE_2)
	dialogue.hide_dialogue()
	await _grant_gate_access()
	_guard_busy = false


func _grant_gate_access() -> void:
	GameState.zone01_guard_granted = true
	_apply_gate_visuals(true)
	# Optional aside: only if marker exists. Does not rewrite marker; one-time gameplay move.
	if guard and guard_aside:
		var tw := create_tween()
		tw.tween_property(guard, "global_position", guard_aside.global_position, 0.45)
		await tw.finished
		var guard_sprite := guard.get_node_or_null("Sprite2D") as Sprite2D
		if guard_sprite:
			guard_sprite.flip_h = false
		if "face_left" in guard:
			guard.face_left = false


func _on_floor1_entered(_body: Node) -> void:
	if not GameState.zone01_guard_granted:
		if prompt_label:
			prompt_label.visible = true
			prompt_label.text = "The gate is locked. Approach the Guard."
		return
	if prompt_label:
		prompt_label.visible = true
		prompt_label.text = "Press E / F — Enter Floor 1"


func _on_floor1_exited(_body: Node) -> void:
	if prompt_label:
		prompt_label.visible = false


func _on_floor1_interacted(_by: Node) -> void:
	if not GameState.zone01_guard_granted:
		if prompt_label:
			prompt_label.visible = true
			prompt_label.text = "The gate is locked. Approach the Guard."
		return
	if prompt_label:
		prompt_label.visible = false
	GameState.zone01_entered = true
	_go_floor1()


func _go_floor1() -> void:
	if SceneTransition.is_busy():
		await SceneTransition.transition_finished
	SceneTransition.change_to(FLOOR1_PATH)


func _show_line(speaker: String, text: String) -> void:
	dialogue.show_line(speaker, text)
	await dialogue.line_finished
