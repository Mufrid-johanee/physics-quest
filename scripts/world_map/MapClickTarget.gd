extends Area2D
## Scene-authored map click target. No player proximity / E-F.
## CollisionShape2D size/position must be edited in the scene.

signal clicked(target: Area2D)

@export var landmark_id: String = ""
@export var is_locked: bool = false


func _ready() -> void:
	input_pickable = true
	monitoring = false
	monitorable = false
	if not input_event.is_connected(_on_input_event):
		input_event.connect(_on_input_event)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self)
