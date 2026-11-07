extends Node
## Persistent strategic campaign state. No network access or external assets.
signal changed

const SAVE_PATH := "user://aegis_save.json"
const FACILITY_COST := 120000
const RESEARCH_GOAL := 100

var day: int = 1
var credits: int = 900000
var materials: int = 0
var mission_available: bool = true
var mission_wins: int = 0
var mission_losses: int = 0
var facilities: Dictionary = {"lab": 1, "workshop": 1, "hangar": 1, "quarters": 1}
var active_research: String = ""
var research_progress: int = 0
var completed_research: Array[String] = []

func _ready() -> void:
    load_game()

func reset_campaign() -> void:
    day = 1
    credits = 900000
    materials = 0
    mission_available = true
    mission_wins = 0
    mission_losses = 0
    facilities = {"lab": 1, "workshop": 1, "hangar": 1, "quarters": 1}
    active_research = ""
    research_progress = 0
    completed_research.clear()
    _commit()

func advance_days(count: int) -> void:
    for _i in range(clampi(count, 1, 30)):
        day += 1
        if day % 7 == 0:
            credits += 45000
        if active_research != "":
            research_progress += 8 + (int(facilities.get("lab", 1)) - 1) * 4
            if research_progress >= RESEARCH_GOAL:
                completed_research.append(active_research)
                active_research = ""
                research_progress = 0
        if day % 4 == 0:
            mission_available = true
    _commit()

func build_facility(key: String) -> bool:
    if not facilities.has(key) or credits < FACILITY_COST:
        return false
    credits -= FACILITY_COST
    facilities[key] = int(facilities[key]) + 1
    _commit()
    return true

func begin_research(key: String) -> bool:
    if active_research != "" or completed_research.has(key) or not ["materials", "biology", "signals"].has(key):
        return false
    active_research = key
    research_progress = 0
    _commit()
    return true

func report_mission(victory: bool) -> void:
    mission_available = false
    if victory:
        mission_wins += 1
        credits += 100000
        materials += 1
    else:
        mission_losses += 1
        credits = maxi(0, credits - 30000)
    _commit()

func _commit() -> void:
    save_game()
    changed.emit()

func save_game() -> void:
    var data := {
        "version": 1,
        "day": day,
        "credits": credits,
        "materials": materials,
        "mission_available": mission_available,
        "mission_wins": mission_wins,
        "mission_losses": mission_losses,
        "facilities": facilities,
        "active_research": active_research,
        "research_progress": research_progress,
        "completed_research": completed_research,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data))

func load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary) or int(parsed.get("version", 0)) != 1:
        return
    day = maxi(1, int(parsed.get("day", day)))
    credits = maxi(0, int(parsed.get("credits", credits)))
    materials = maxi(0, int(parsed.get("materials", materials)))
    mission_available = bool(parsed.get("mission_available", mission_available))
    mission_wins = maxi(0, int(parsed.get("mission_wins", mission_wins)))
    mission_losses = maxi(0, int(parsed.get("mission_losses", mission_losses)))
    var loaded_facilities: Variant = parsed.get("facilities", {})
    if loaded_facilities is Dictionary:
        for key in facilities.keys():
            if loaded_facilities.has(key):
                facilities[key] = maxi(1, int(loaded_facilities[key]))
    active_research = str(parsed.get("active_research", ""))
    research_progress = clampi(int(parsed.get("research_progress", 0)), 0, 99)
    completed_research.clear()
    var loaded_research: Variant = parsed.get("completed_research", [])
    if loaded_research is Array:
        for item in loaded_research:
            if str(item) in ["materials", "biology", "signals"] and not completed_research.has(str(item)):
                completed_research.append(str(item))
