class_name SaveMigrator
extends RefCounted
## New schemas get an explicit migration step. Unknown future versions FAIL CLOSED.


static func migrate(raw: Dictionary) -> Dictionary:
    var version: int = int(raw.get("schema_version", -1))
    if version == SaveValidator.CURRENT_SCHEMA:
        return raw.duplicate(true)
    if version == 1:
        if typeof(raw.get("gold")) != TYPE_INT:
            return {}
        if typeof(raw.get("best_score")) != TYPE_INT:
            return {}
        if typeof(raw.get("sound_enabled")) != TYPE_BOOL:
            return {}
        var upgraded: Dictionary = {
            "schema_version": 2,
            "profile": {
                "best_score": raw["best_score"],
                "coins": raw["gold"]
            },
            "settings": {"sound_enabled": raw["sound_enabled"]}
        }
        return upgraded if SaveValidator.is_valid(upgraded) else {}
    return {}
