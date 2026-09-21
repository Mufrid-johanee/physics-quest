extends Node
## Persistent flags for scene flow + World Map unlocks.
## Unlock next zone only when Floor 4 passed AND mini-game placeholder SUCCESSFUL.

signal zone_unlock_changed(zone_id: String, unlocked: bool)

const ZONE_01 := "zone_01"
const ZONE_02 := "zone_02"
const ZONE_03 := "zone_03"
const ZONE_04 := "zone_04"
const ZONE_05 := "zone_05"

## Default: only Zone 01 unlocked for the current development path.
var _unlocked: Dictionary = {
	ZONE_01: true,
	ZONE_02: false,
	ZONE_03: false,
	ZONE_04: false,
	ZONE_05: false,
}

## Lightweight flags for Zone 01 exterior gate (editable later via gameplay).
var zone01_guard_granted: bool = false
var zone01_entered: bool = false
## Floor assessment passes (≥80%). Gate stairs to the next floor.
var zone01_floor1_passed: bool = false
var zone01_floor2_passed: bool = false
var zone01_floor3_passed: bool = false
var zone01_floor4_passed: bool = false
## Placeholder mini-game SUCCESSFUL (temporary progression gate).
var zone01_minigame_successful: bool = false
## Compatibility: set true with mini-game SUCCESSFUL (not on Floor 4 quiz alone).
var zone01_complete: bool = false
var zone01_badge_earned: bool = false

## Zone 02 floor assessment passes (≥80%).
var zone02_floor1_passed: bool = false
var zone02_floor2_passed: bool = false
var zone02_floor3_passed: bool = false
var zone02_floor4_passed: bool = false
var zone02_minigame_successful: bool = false
## Compatibility: set true with mini-game SUCCESSFUL (not on Floor 4 quiz alone).
var zone02_complete: bool = false
var zone02_badge_earned: bool = false
## Exterior spawn hint: "" = PlayerSpawn, or a Marker2D node path under Zone02_Exterior.
var zone02_exterior_spawn_marker: String = ""

## Zone 03 Signal Station floor assessment passes (≥80%).
var zone03_floor1_passed: bool = false
var zone03_floor2_passed: bool = false
var zone03_floor3_passed: bool = false
var zone03_floor4_passed: bool = false
var zone03_minigame_successful: bool = false
var zone03_complete: bool = false
var zone03_badge_earned: bool = false
## Exterior spawn hint under Zone03_Exterior.
var zone03_exterior_spawn_marker: String = ""

## Zone 04 Substation floor assessment passes (≥80%).
var zone04_floor1_passed: bool = false
var zone04_floor2_passed: bool = false
var zone04_floor3_passed: bool = false
var zone04_floor4_passed: bool = false
var zone04_minigame_successful: bool = false
var zone04_complete: bool = false
var zone04_badge_earned: bool = false
## Exterior spawn hint under Zone04_Exterior.
var zone04_exterior_spawn_marker: String = ""


func is_zone_unlocked(zone_id: String) -> bool:
	return bool(_unlocked.get(zone_id, false))


func set_zone_unlocked(zone_id: String, unlocked: bool = true) -> void:
	if _unlocked.get(zone_id, null) == unlocked:
		return
	_unlocked[zone_id] = unlocked
	zone_unlock_changed.emit(zone_id, unlocked)


func unlock_next_after(zone_id: String) -> void:
	match zone_id:
		ZONE_01:
			set_zone_unlocked(ZONE_02, true)
		ZONE_02:
			set_zone_unlocked(ZONE_03, true)
		ZONE_03:
			set_zone_unlocked(ZONE_04, true)
		ZONE_04:
			set_zone_unlocked(ZONE_05, true)
		_:
			push_warning("GameState.unlock_next_after: unknown zone '%s'" % zone_id)


## Mark placeholder mini-game SUCCESSFUL and sync World Map unlocks (monotonic).
func mark_minigame_successful(zone_id: String) -> void:
	match zone_id:
		ZONE_01:
			zone01_minigame_successful = true
			zone01_complete = true
		ZONE_02:
			zone02_minigame_successful = true
			zone02_complete = true
		ZONE_03:
			zone03_minigame_successful = true
			zone03_complete = true
		ZONE_04:
			zone04_minigame_successful = true
			zone04_complete = true
		_:
			push_warning("GameState.mark_minigame_successful: unknown zone '%s'" % zone_id)
			return
	sync_world_map_unlocks()


## Sync World Map unlocks: Floor 4 passed AND mini-game SUCCESSFUL (monotonic).
func sync_world_map_unlocks() -> void:
	if zone01_floor4_passed and zone01_minigame_successful:
		set_zone_unlocked(ZONE_02, true)
	if zone02_floor4_passed and zone02_minigame_successful:
		set_zone_unlocked(ZONE_03, true)
	if zone03_floor4_passed and zone03_minigame_successful:
		set_zone_unlocked(ZONE_04, true)
	if zone04_floor4_passed and zone04_minigame_successful:
		set_zone_unlocked(ZONE_05, true)


func reset_progress_flags() -> void:
	_unlocked = {
		ZONE_01: true,
		ZONE_02: false,
		ZONE_03: false,
		ZONE_04: false,
		ZONE_05: false,
	}
	zone01_guard_granted = false
	zone01_entered = false
	zone01_floor1_passed = false
	zone01_floor2_passed = false
	zone01_floor3_passed = false
	zone01_floor4_passed = false
	zone01_minigame_successful = false
	zone01_complete = false
	zone01_badge_earned = false
	zone02_floor1_passed = false
	zone02_floor2_passed = false
	zone02_floor3_passed = false
	zone02_floor4_passed = false
	zone02_minigame_successful = false
	zone02_complete = false
	zone02_badge_earned = false
	zone02_exterior_spawn_marker = ""
	zone03_floor1_passed = false
	zone03_floor2_passed = false
	zone03_floor3_passed = false
	zone03_floor4_passed = false
	zone03_minigame_successful = false
	zone03_complete = false
	zone03_badge_earned = false
	zone03_exterior_spawn_marker = ""
	zone04_floor1_passed = false
	zone04_floor2_passed = false
	zone04_floor3_passed = false
	zone04_floor4_passed = false
	zone04_minigame_successful = false
	zone04_complete = false
	zone04_badge_earned = false
	zone04_exterior_spawn_marker = ""


## Fresh profile: clear all progression. Active profile name is owned by SaveManager.
func reset_for_new_profile() -> void:
	reset_progress_flags()


## True after at least one floor pass or mini-game SUCCESSFUL (manual save gate).
func has_progression_checkpoint() -> bool:
	return (
		zone01_floor1_passed or zone01_floor2_passed or zone01_floor3_passed or zone01_floor4_passed
		or zone02_floor1_passed or zone02_floor2_passed or zone02_floor3_passed or zone02_floor4_passed
		or zone03_floor1_passed or zone03_floor2_passed or zone03_floor3_passed or zone03_floor4_passed
		or zone04_floor1_passed or zone04_floor2_passed or zone04_floor3_passed or zone04_floor4_passed
		or zone01_minigame_successful or zone02_minigame_successful
		or zone03_minigame_successful or zone04_minigame_successful
	)


func get_save_data() -> Dictionary:
	return {
		"unlocked": _unlocked.duplicate(true),
		"zone01_guard_granted": zone01_guard_granted,
		"zone01_entered": zone01_entered,
		"zone01_floor1_passed": zone01_floor1_passed,
		"zone01_floor2_passed": zone01_floor2_passed,
		"zone01_floor3_passed": zone01_floor3_passed,
		"zone01_floor4_passed": zone01_floor4_passed,
		"zone01_minigame_successful": zone01_minigame_successful,
		"zone01_complete": zone01_complete,
		"zone01_badge_earned": zone01_badge_earned,
		"zone02_floor1_passed": zone02_floor1_passed,
		"zone02_floor2_passed": zone02_floor2_passed,
		"zone02_floor3_passed": zone02_floor3_passed,
		"zone02_floor4_passed": zone02_floor4_passed,
		"zone02_minigame_successful": zone02_minigame_successful,
		"zone02_complete": zone02_complete,
		"zone02_badge_earned": zone02_badge_earned,
		"zone02_exterior_spawn_marker": zone02_exterior_spawn_marker,
		"zone03_floor1_passed": zone03_floor1_passed,
		"zone03_floor2_passed": zone03_floor2_passed,
		"zone03_floor3_passed": zone03_floor3_passed,
		"zone03_floor4_passed": zone03_floor4_passed,
		"zone03_minigame_successful": zone03_minigame_successful,
		"zone03_complete": zone03_complete,
		"zone03_badge_earned": zone03_badge_earned,
		"zone03_exterior_spawn_marker": zone03_exterior_spawn_marker,
		"zone04_floor1_passed": zone04_floor1_passed,
		"zone04_floor2_passed": zone04_floor2_passed,
		"zone04_floor3_passed": zone04_floor3_passed,
		"zone04_floor4_passed": zone04_floor4_passed,
		"zone04_minigame_successful": zone04_minigame_successful,
		"zone04_complete": zone04_complete,
		"zone04_badge_earned": zone04_badge_earned,
		"zone04_exterior_spawn_marker": zone04_exterior_spawn_marker,
	}


func apply_save_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	var unlocked: Variant = data.get("unlocked", {})
	if typeof(unlocked) == TYPE_DICTIONARY:
		_unlocked = {
			ZONE_01: bool(unlocked.get(ZONE_01, true)),
			ZONE_02: bool(unlocked.get(ZONE_02, false)),
			ZONE_03: bool(unlocked.get(ZONE_03, false)),
			ZONE_04: bool(unlocked.get(ZONE_04, false)),
			ZONE_05: bool(unlocked.get(ZONE_05, false)),
		}
	zone01_guard_granted = bool(data.get("zone01_guard_granted", false))
	zone01_entered = bool(data.get("zone01_entered", false))
	zone01_floor1_passed = bool(data.get("zone01_floor1_passed", false))
	zone01_floor2_passed = bool(data.get("zone01_floor2_passed", false))
	zone01_floor3_passed = bool(data.get("zone01_floor3_passed", false))
	zone01_floor4_passed = bool(data.get("zone01_floor4_passed", false))
	zone01_minigame_successful = bool(data.get("zone01_minigame_successful", false))
	zone01_complete = bool(data.get("zone01_complete", false))
	zone01_badge_earned = bool(data.get("zone01_badge_earned", false))
	zone02_floor1_passed = bool(data.get("zone02_floor1_passed", false))
	zone02_floor2_passed = bool(data.get("zone02_floor2_passed", false))
	zone02_floor3_passed = bool(data.get("zone02_floor3_passed", false))
	zone02_floor4_passed = bool(data.get("zone02_floor4_passed", false))
	zone02_minigame_successful = bool(data.get("zone02_minigame_successful", false))
	zone02_complete = bool(data.get("zone02_complete", false))
	zone02_badge_earned = bool(data.get("zone02_badge_earned", false))
	zone02_exterior_spawn_marker = str(data.get("zone02_exterior_spawn_marker", ""))
	zone03_floor1_passed = bool(data.get("zone03_floor1_passed", false))
	zone03_floor2_passed = bool(data.get("zone03_floor2_passed", false))
	zone03_floor3_passed = bool(data.get("zone03_floor3_passed", false))
	zone03_floor4_passed = bool(data.get("zone03_floor4_passed", false))
	zone03_minigame_successful = bool(data.get("zone03_minigame_successful", false))
	zone03_complete = bool(data.get("zone03_complete", false))
	zone03_badge_earned = bool(data.get("zone03_badge_earned", false))
	zone03_exterior_spawn_marker = str(data.get("zone03_exterior_spawn_marker", ""))
	zone04_floor1_passed = bool(data.get("zone04_floor1_passed", false))
	zone04_floor2_passed = bool(data.get("zone04_floor2_passed", false))
	zone04_floor3_passed = bool(data.get("zone04_floor3_passed", false))
	zone04_floor4_passed = bool(data.get("zone04_floor4_passed", false))
	zone04_minigame_successful = bool(data.get("zone04_minigame_successful", false))
	zone04_complete = bool(data.get("zone04_complete", false))
	zone04_badge_earned = bool(data.get("zone04_badge_earned", false))
	zone04_exterior_spawn_marker = str(data.get("zone04_exterior_spawn_marker", ""))
	sync_world_map_unlocks()


## Short label for profile list UI (no invented stats).
func progress_summary_label() -> String:
	if zone04_minigame_successful or zone04_complete:
		return "Zone 04 complete"
	if zone04_floor4_passed:
		return "Zone 04 Floor 4"
	if zone04_floor3_passed:
		return "Zone 04 Floor 3+"
	if zone04_floor2_passed:
		return "Zone 04 Floor 2+"
	if zone04_floor1_passed:
		return "Zone 04 Floor 1+"
	if is_zone_unlocked(ZONE_04):
		return "Zone 04 unlocked"
	if zone03_minigame_successful or zone03_complete:
		return "Zone 03 complete"
	if zone03_floor4_passed:
		return "Zone 03 Floor 4"
	if zone03_floor3_passed:
		return "Zone 03 Floor 3+"
	if zone03_floor2_passed:
		return "Zone 03 Floor 2+"
	if zone03_floor1_passed:
		return "Zone 03 Floor 1+"
	if is_zone_unlocked(ZONE_03):
		return "Zone 03 unlocked"
	if zone02_minigame_successful or zone02_complete:
		return "Zone 02 complete"
	if zone02_floor4_passed:
		return "Zone 02 Floor 4"
	if zone02_floor3_passed:
		return "Zone 02 Floor 3+"
	if zone02_floor2_passed:
		return "Zone 02 Floor 2+"
	if zone02_floor1_passed:
		return "Zone 02 Floor 1+"
	if is_zone_unlocked(ZONE_02):
		return "Zone 02 unlocked"
	if zone01_minigame_successful or zone01_complete:
		return "Zone 01 complete"
	if zone01_floor4_passed:
		return "Zone 01 Floor 4"
	if zone01_floor3_passed:
		return "Zone 01 Floor 3+"
	if zone01_floor2_passed:
		return "Zone 01 Floor 2+"
	if zone01_floor1_passed:
		return "Zone 01 Floor 1+"
	if zone01_guard_granted:
		return "Zone 01 Exterior"
	return "New game"
