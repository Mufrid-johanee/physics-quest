extends Node2D
## Visual-only seated student. Transforms are scene-authored; never regenerated at runtime.

@export var face_left: bool = false
@export var enable_collision: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var body: StaticBody2D = get_node_or_null("StaticBody2D") as StaticBody2D


func _ready() -> void:
	if sprite:
		sprite.flip_h = face_left
	if body:
		body.visible = enable_collision
		for child in body.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).disabled = not enable_collision
