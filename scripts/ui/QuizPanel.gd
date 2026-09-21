extends CanvasLayer
## Minimal Floor assessment quiz UI. Driven by QuizController signals.
## Supports MCQ option buttons and one_word text entry.

signal continue_pressed
signal retry_pressed

@onready var root: Control = $Root
@onready var floor_title: Label = $Root/Center/Panel/Margin/VBox/Header/FloorTitle
@onready var question_counter: Label = $Root/Center/Panel/Margin/VBox/Header/QuestionCounter
@onready var progress_label: Label = $Root/Center/Panel/Margin/VBox/Header/ProgressLabel
@onready var question_label: Label = $Root/Center/Panel/Margin/VBox/QuestionLabel
@onready var options_box: VBoxContainer = $Root/Center/Panel/Margin/VBox/Options
@onready var option_a: Button = $Root/Center/Panel/Margin/VBox/Options/OptionA
@onready var option_b: Button = $Root/Center/Panel/Margin/VBox/Options/OptionB
@onready var option_c: Button = $Root/Center/Panel/Margin/VBox/Options/OptionC
@onready var option_d: Button = $Root/Center/Panel/Margin/VBox/Options/OptionD
@onready var text_answer_row: HBoxContainer = $Root/Center/Panel/Margin/VBox/TextAnswer
@onready var answer_input: LineEdit = $Root/Center/Panel/Margin/VBox/TextAnswer/AnswerInput
@onready var submit_answer: Button = $Root/Center/Panel/Margin/VBox/TextAnswer/SubmitAnswer
@onready var feedback_label: Label = $Root/Center/Panel/Margin/VBox/FeedbackLabel
@onready var explanation_label: Label = $Root/Center/Panel/Margin/VBox/ExplanationLabel
@onready var next_button: Button = $Root/Center/Panel/Margin/VBox/NextButton
@onready var result_panel: PanelContainer = $Root/Center/ResultPanel
@onready var result_title: Label = $Root/Center/ResultPanel/Margin/VBox/ResultTitle
@onready var score_label: Label = $Root/Center/ResultPanel/Margin/VBox/ScoreLabel
@onready var result_retry: Button = $Root/Center/ResultPanel/Margin/VBox/Buttons/RetryButton
@onready var result_continue: Button = $Root/Center/ResultPanel/Margin/VBox/Buttons/ContinueButton

var _controller: QuizController
var _options: Array[Button] = []
var _locked: bool = false
var _is_text_mode: bool = false


func _ready() -> void:
	visible = false
	_options = [option_a, option_b, option_c, option_d]
	for i in _options.size():
		var btn := _options[i]
		btn.pressed.connect(_on_option_pressed.bind(i))
	next_button.pressed.connect(_on_next_pressed)
	result_retry.pressed.connect(_on_retry_pressed)
	result_continue.pressed.connect(_on_continue_pressed)
	if submit_answer:
		submit_answer.pressed.connect(_on_submit_text_pressed)
	if answer_input:
		answer_input.text_submitted.connect(func(_t): _on_submit_text_pressed())
	next_button.visible = false
	result_panel.visible = false
	if text_answer_row:
		text_answer_row.visible = false
	feedback_label.text = ""
	explanation_label.text = ""


func bind_controller(controller: QuizController) -> void:
	_controller = controller
	if _controller.question_changed.is_connected(_on_question_changed):
		return
	_controller.question_changed.connect(_on_question_changed)
	_controller.answer_resolved.connect(_on_answer_resolved)
	_controller.quiz_passed.connect(_on_quiz_passed)
	_controller.quiz_failed.connect(_on_quiz_failed)


func open_quiz(floor_name: String = "Floor 1 Assessment") -> void:
	floor_title.text = floor_name
	result_panel.visible = false
	root.visible = true
	visible = true
	_locked = false
	_set_options_enabled(true)
	feedback_label.text = ""
	explanation_label.text = ""
	next_button.visible = false


func close_quiz() -> void:
	visible = false
	result_panel.visible = false
	_locked = false


func _on_question_changed(index: int, total: int, question: Dictionary) -> void:
	_locked = false
	_set_options_enabled(true)
	next_button.visible = false
	feedback_label.text = ""
	explanation_label.text = ""
	question_counter.text = "Question %d / %d" % [index + 1, total]
	progress_label.text = "Correct so far: %d" % (_controller.get_score() if _controller else 0)
	question_label.text = str(question.get("question", ""))
	var opts = question.get("options", [])
	_is_text_mode = _question_is_one_word(question)
	if _is_text_mode:
		options_box.visible = false
		if text_answer_row:
			text_answer_row.visible = true
		if answer_input:
			answer_input.text = ""
			answer_input.editable = true
			answer_input.grab_focus()
		if submit_answer:
			submit_answer.disabled = false
	else:
		if text_answer_row:
			text_answer_row.visible = false
		options_box.visible = true
		for i in _options.size():
			if opts is Array and i < opts.size():
				_options[i].text = "%s. %s" % [String.chr(65 + i), str(opts[i])]
				_options[i].visible = true
				_options[i].set_meta("option_text", str(opts[i]))
			else:
				_options[i].visible = false
				_options[i].set_meta("option_text", "")


func _question_is_one_word(question: Dictionary) -> bool:
	var fmt := str(question.get("format", "")).to_lower()
	if fmt == "one_word" or fmt == "one-word" or fmt == "short_answer":
		return true
	var options = question.get("options", null)
	return not (options is Array and options.size() > 0)


func _on_option_pressed(index: int) -> void:
	if _locked or _controller == null or _is_text_mode:
		return
	if index < 0 or index >= _options.size():
		return
	var opt_text := str(_options[index].get_meta("option_text", ""))
	if opt_text.is_empty():
		return
	_locked = true
	_set_options_enabled(false)
	_controller.submit_option_text(opt_text)


func _on_submit_text_pressed() -> void:
	if _locked or _controller == null or not _is_text_mode:
		return
	var typed := ""
	if answer_input:
		typed = answer_input.text
	if typed.strip_edges().is_empty():
		return
	_locked = true
	if answer_input:
		answer_input.editable = false
	if submit_answer:
		submit_answer.disabled = true
	_controller.submit_text_answer(typed)


func _on_answer_resolved(correct: bool, explanation: String) -> void:
	if correct:
		feedback_label.text = "Correct"
		feedback_label.modulate = Color(0.45, 0.85, 0.45)
	else:
		feedback_label.text = "Incorrect"
		feedback_label.modulate = Color(0.95, 0.45, 0.4)
	explanation_label.text = explanation
	progress_label.text = "Correct so far: %d" % (_controller.get_score() if _controller else 0)
	next_button.visible = true
	next_button.grab_focus()


func _on_next_pressed() -> void:
	if _controller:
		_controller.advance_after_feedback()


func _on_quiz_passed(score: int, total: int, percent: float) -> void:
	_show_result(true, score, total, percent)


func _on_quiz_failed(score: int, total: int, percent: float) -> void:
	_show_result(false, score, total, percent)


func _show_result(passed: bool, score: int, total: int, percent: float) -> void:
	result_panel.visible = true
	if passed:
		result_title.text = "ASSESSMENT PASSED"
		result_title.modulate = Color(0.45, 0.85, 0.45)
		result_continue.visible = true
		result_retry.visible = false
		result_continue.grab_focus()
	else:
		result_title.text = "FAIL"
		result_title.modulate = Color(0.95, 0.45, 0.4)
		result_continue.visible = false
		result_retry.visible = true
		result_retry.grab_focus()
	score_label.text = "Score: %d/%d\nPercentage: %d%%" % [score, total, int(round(percent))]


func _on_retry_pressed() -> void:
	result_panel.visible = false
	retry_pressed.emit()


func _on_continue_pressed() -> void:
	continue_pressed.emit()


func _set_options_enabled(enabled: bool) -> void:
	for btn in _options:
		btn.disabled = not enabled
	if submit_answer:
		submit_answer.disabled = not enabled
	if answer_input and enabled:
		answer_input.editable = true
