extends Node
## No hardcoded UI translations outside this table for screens and actions.
signal language_changed
var language: String = "uk"

const TRANSLATIONS := {
    "uk": {
        "subtitle": "МІЖНАРОДНА ОБОРОНА ЗЕМЛІ  •  ПРОТОТИП",
        "geo": "ГЛОБУС", "base": "БАЗА", "research": "НАУКА", "language": "EN",
        "day": "День", "credits": "Кредити", "materials": "Зразки",
        "geoscape_title": "ГЕОСТРАТЕГІЯ", "geo_brief": "Невідомі сигнали над суходолом і під океаном. Командуйте обороною планети.",
        "alert_yes": "ВИЯВЛЕНО НЕВІДОМИЙ ОБ'ЄКТ", "alert_no": "Активних загроз не виявлено",
        "deploy": "ВІДПРАВИТИ ЗАГІН", "one_day": "+1 ДЕНЬ", "seven_days": "+7 ДНІВ",
        "mission_status": "Місії: перемог %d • поразок %d", "base_title": "ПІДЗЕМНА БАЗА AEGIS",
        "base_brief": "Розширюйте інфраструктуру. Вартість кожного нового модуля — 120 000 кредитів.",
        "lab": "Лабораторія", "workshop": "Майстерня", "hangar": "Ангар", "quarters": "Казарми", "build": "ПОБУДУВАТИ",
        "research_title": "НАУКОВИЙ ВІДДІЛ", "research_brief": "Науковці працюють щодня. Додаткові лабораторії пришвидшують дослідження.",
        "materials": "Матеріали прибульців", "biology": "Біологія прибульців", "signals": "Невідомі сигнали",
        "begin": "ДОСЛІДЖУВАТИ", "in_progress": "Активне дослідження: %s (%d%%)", "no_research": "Немає активних досліджень", "done": "ЗАВЕРШЕНО",
        "battle_title": "ТАКТИЧНА ОПЕРАЦІЯ", "battle_brief": "Оберіть бійця, потім клітинку для руху або ціль для пострілу.",
        "move": "РУХ", "fire": "ВОГОНЬ", "reload": "ПЕРЕЗАРЯДИТИ", "end_turn": "ЗАКІНЧИТИ ХІД",
        "retreat": "ВІДСТУПИТИ", "soldiers": "БІЙЦІ", "selected": "Обраний", "mode": "Дія",
        "turn": "Раунд", "victory": "ПЕРЕМОГА! Командування отримало трофеї та фінансування.",
        "defeat": "ПОРАЗКА. Загін втрачено, організація зазнала збитків.",
        "mission_log": "ЖУРНАЛ ОПЕРАЦІЙ", "welcome": "Сигнал AEGIS стабільний. Планета під наглядом.",
        "not_enough_ap": "Недостатньо очок дій", "blocked": "Недоступний шлях або клітинка зайнята",
        "out_of_range": "Ціль недосяжна або закрита перешкодою", "out_of_ammo": "Закінчилися набої",
        "no_mission": "Немає доступних операцій", "mission_started": "Загін висадився в районі сигналу",
        "reset": "НОВА КАМПАНІЯ", "tap_units": "Натисніть на бійця, щоб обрати його.",
        "cover": "Сірі клітинки — стіни, темні — невивчена територія.",
    },
    "en": {
        "subtitle": "EARTH DEFENSE INITIATIVE  •  PROTOTYPE",
        "geo": "GLOBE", "base": "BASE", "research": "SCIENCE", "language": "УКР",
        "day": "Day", "credits": "Credits", "materials": "Specimens",
        "geoscape_title": "GEOSTRATEGY", "geo_brief": "Unknown signals above land and beneath the oceans. Command Earth's defense.",
        "alert_yes": "UNIDENTIFIED OBJECT DETECTED", "alert_no": "No active threat detected",
        "deploy": "DEPLOY SQUAD", "one_day": "+1 DAY", "seven_days": "+7 DAYS",
        "mission_status": "Missions: %d wins • %d losses", "base_title": "AEGIS UNDERGROUND BASE",
        "base_brief": "Expand your infrastructure. Each new facility costs 120,000 credits.",
        "lab": "Laboratory", "workshop": "Workshop", "hangar": "Hangar", "quarters": "Barracks", "build": "BUILD",
        "research_title": "RESEARCH DIVISION", "research_brief": "Scientists work each day. More laboratories accelerate research.",
        "materials": "Alien materials", "biology": "Alien biology", "signals": "Unknown signals",
        "begin": "RESEARCH", "in_progress": "Current research: %s (%d%%)", "no_research": "No active research", "done": "COMPLETED",
        "battle_title": "TACTICAL OPERATION", "battle_brief": "Select a soldier, then tap a tile to move or an alien to fire.",
        "move": "MOVE", "fire": "FIRE", "reload": "RELOAD", "end_turn": "END TURN",
        "retreat": "RETREAT", "soldiers": "SQUAD", "selected": "Selected", "mode": "Action",
        "turn": "Round", "victory": "VICTORY! Command recovered specimens and secured funding.",
        "defeat": "DEFEAT. Squad was lost and AEGIS suffered a financial blow.",
        "mission_log": "OPERATIONS LOG", "welcome": "AEGIS signal steady. The planet is under observation.",
        "not_enough_ap": "Not enough action points", "blocked": "No viable path or destination occupied",
        "out_of_range": "Target is out of range or behind an obstacle", "out_of_ammo": "Out of ammunition",
        "no_mission": "No active operation available", "mission_started": "Squad deployed near the signal",
        "reset": "NEW CAMPAIGN", "tap_units": "Tap a soldier to select them.",
        "cover": "Gray cells are walls; dark cells are unexplored terrain.",
    }
}

func t(key: String) -> String:
    return str(TRANSLATIONS.get(language, TRANSLATIONS["en"]).get(key, key))

func toggle() -> void:
    language = "en" if language == "uk" else "uk"
    language_changed.emit()
