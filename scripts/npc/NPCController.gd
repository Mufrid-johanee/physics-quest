extends CharacterBody2D
## Reusable NPC. Placement/scale/texture are scene-authored exports.
## This script does not reposition the node on ready.
## Floor roles: Supervisors use InteractionArea (floor script); ambient workers use
## AmbientProximity.gd (see Docs/AMBIENT_CHARACTERS.md). Do not merge those systems.

signal interaction_requested(npc: Node)

@export var display_name: String = "NPC"
@export var sprite_texture: Texture2D
@export var sprite_scale: float = 0.35
## If true and sprite still at identity scale, apply sprite_scale once.
@export var apply_sprite_scale_on_ready: bool = true
@export var face_left: bool = false
@export var enable_collision: bool = true
@export var can_interact: bool = false
@export_multiline var dialogue_lines: PackedStringArray = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interactable: Area2D = $Interactable


func _ready() -> void:
	collision_layer = 4 if enable_collision else 0
	collision_mask = 0
	if collision_shape:
		collision_shape.disabled = not enable_collision
	if sprite_texture:
		sprite.texture = sprite_texture
	if apply_sprite_scale_on_ready and sprite.scale == Vector2.ONE:
		sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.flip_h = face_left
	if interactable:
		interactable.monitoring = can_interact
		interactable.monitorable = can_interact
		if "enabled" in interactable:
			interactable.enabled = can_interact
		if interactable.has_signal("interacted"):
			if not interactable.interacted.is_connected(_on_interacted):
				interactable.interacted.connect(_on_interacted)


func _on_interacted(_by: Node) -> void:
	if not can_interact:
		return
	interaction_requested.emit(self)


func get_dialogue_lines() -> PackedStringArray:
	return dialogue_lines
