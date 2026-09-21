extends CanvasLayer
## Minimal dialogue hook for opening sequence. Not a full dialogue framework.

signal line_finished

@onready var panel: PanelContainer = $Root/Panel
@onready var speaker_label: Label = $Root/Panel/Margin/VBox/Speaker
@onready var body_label: Label = $Root/Panel/Margin/VBox/Body
@onready var continue_button: Button = $Root/Panel/Margin/VBox/Continue

var _active: bool = false


func _ready() -> void:
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not _active or not visible:
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_on_continue_pressed()
		get_viewport().set_input_as_handled()


func show_line(speaker: String, text: String) -> void:
	speaker_label.text = speaker
	body_label.text = text
	visible = true
	_active = true
	continue_button.grab_focus()


func hide_dialogue() -> void:
	_active = false
	visible = false


func _on_continue_pressed() -> void:
	if not _active:
		return
	_active = false
	line_finished.emit()
