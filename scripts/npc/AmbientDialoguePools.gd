extends RefCounted
## Short ambient factory dialogue pools. Not quiz content.
## Preload this script (avoid depending on global class_name registration).
## Upgrade guide: Docs/AMBIENT_CHARACTERS.md
## When extending: add short factory-flavor lines only — never quiz bank text.


static func default_for_speaker(speaker: String) -> PackedStringArray:
	var key := speaker.to_lower()
	if "lab" in key or "assistant" in key:
		return lab_assistant_lines()
	if "rina" in key:
		return observer_lines()
	if "supervisor" in key or "coworker" in key or "karim" in key:
		return coworker_lines()
	return worker_lines()


static func worker_lines() -> PackedStringArray:
	return PackedStringArray([
		"Looks like the equipment on this floor needs careful monitoring.",
		"Keep observing the machines. You may notice something interesting.",
		"Your Supervisor may ask you about what you see on this floor.",
		"Take a good look around before moving to the next area.",
		"Stay alert — small details often matter here.",
		"I've been checking this station all morning.",
	])


static func lab_assistant_lines() -> PackedStringArray:
	return PackedStringArray([
		"I'm monitoring the press instruments. Don't lean on the hazard strip.",
		"Double-check your readings before you report to the Supervisor.",
		"This area is quieter, but the concepts still matter.",
		"If something looks off, ask yourself why before you move on.",
		"Good habits in the lab make the assessments easier.",
	])


static func coworker_lines() -> PackedStringArray:
	return PackedStringArray([
		"Busy day on this floor. Keep your eyes open.",
		"The Supervisor keeps everyone focused — for good reason.",
		"Watch how the systems connect. It helps later.",
		"Another trainee? Welcome to the floor.",
	])


static func observer_lines() -> PackedStringArray:
	return PackedStringArray([
		"Interesting setup on this floor, isn't it?",
		"I like watching how the systems respond.",
		"If you study carefully, the quiz feels easier.",
		"Don't rush — observation is half the lesson.",
	])
