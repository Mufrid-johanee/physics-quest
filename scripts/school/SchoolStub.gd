extends Node2D
## Placeholder shell. Polished School opening is the next implementation task.

@onready var return_button: Button = $UI/ReturnButton


func _ready() -> void:
	if return_button:
		return_button.pressed.connect(_on_return_pressed)


func _on_return_pressed() -> void:
	SceneTransition.change_to("res://scenes/boot/BootTest.tscn")
