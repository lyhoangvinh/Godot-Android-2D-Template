class_name SaveValidator
extends RefCounted
## Strict validation before save or migration commit; no silent economy reset.

const CURRENT_SCHEMA: int = 2


static func default_state() -> Dictionary:
    return {
        "schema_version": CURRENT_SCHEMA,
        "profile": {"best_score": 0, "coins": 0},
        "settings": {"sound_enabled": true}
    }


static func is_valid(data: Dictionary) -> bool:
    if data.get("schema_version") != CURRENT_SCHEMA:
        return false
    if typeof(data.get("profile")) != TYPE_DICTIONARY:
        return false
    if typeof(data.get("settings")) != TYPE_DICTIONARY:
        return false
    var profile: Dictionary = data["profile"]
    var settings: Dictionary = data["settings"]
    if typeof(profile.get("coins")) != TYPE_INT:
        return false
    if typeof(profile.get("best_score")) != TYPE_INT:
        return false
    if int(profile["coins"]) < 0 or int(profile["best_score"]) < 0:
        return false
    if typeof(settings.get("sound_enabled")) != TYPE_BOOL:
        return false
    return true
