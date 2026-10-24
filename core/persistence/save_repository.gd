class_name SaveRepository
extends RefCounted
## Versioned local save, temp write + validated backup recovery.
## No persistence implementation can promise atomic rename on every filesystem.

var read_only: bool = false
var last_error: String = ""
var _path: String
var _state: Dictionary = SaveValidator.default_state()


func _init(path: String = "user://player_state.json") -> void:
    _path = path
    _load()


func get_best_score() -> int:
    return int(_state["profile"]["best_score"])


func get_coins() -> int:
    return int(_state["profile"]["coins"])


func is_sound_enabled() -> bool:
    return bool(_state["settings"]["sound_enabled"])


func record_run(score: int, earned_coins: int) -> bool:
    if score < 0 or earned_coins < 0:
        return false
    var draft: Dictionary = _state.duplicate(true)
    var profile: Dictionary = draft["profile"]
    profile["best_score"] = maxi(int(profile["best_score"]), score)
    profile["coins"] = int(profile["coins"]) + earned_coins
    return _commit(draft)


func add_demo_bonus(coins: int) -> bool:
    ## DEMO ONLY. Do not expose this entitlement path in a shipping game.
    if coins <= 0:
        return false
    return record_run(0, coins)


func set_sound_enabled(value: bool) -> bool:
    var draft: Dictionary = _state.duplicate(true)
    var settings: Dictionary = draft["settings"]
    settings["sound_enabled"] = value
    return _commit(draft)


func _load() -> void:
    var primary: Dictionary = _read_valid(_path)
    if not primary.is_empty():
        _state = primary
        return
    var recovered: Dictionary = _read_valid(_path + ".bak")
    if not recovered.is_empty():
        _state = recovered
        last_error = "Primary save unreadable; recovered backup."
        return
    if FileAccess.file_exists(_path) or FileAccess.file_exists(_path + ".bak"):
        read_only = true
        last_error = "Save corrupted/unsupported. Write disabled to protect player data."
        push_error(last_error)


func _read_valid(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var text_data: String = FileAccess.get_file_as_string(path)
    var parsed: Variant = JSON.parse_string(text_data)
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    var migrated: Dictionary = SaveMigrator.migrate(parsed)
    if not SaveValidator.is_valid(migrated):
        return {}
    return migrated


func _commit(candidate: Dictionary) -> bool:
    if read_only:
        last_error = "Save is read-only because recovery was unsuccessful."
        return false
    if not SaveValidator.is_valid(candidate):
        last_error = "Rejected invalid save data."
        return false
    var full_path: String = ProjectSettings.globalize_path(_path)
    var folder: String = full_path.get_base_dir()
    if DirAccess.make_dir_recursive_absolute(folder) != OK:
        last_error = "Could not create save directory."
        return false
    var tmp: String = _path + ".tmp"
    var file: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
    if file == null:
        last_error = "Could not create temporary save."
        return false
    file.store_string(JSON.stringify(candidate, "  "))
    file.flush()
    file.close()
    if _read_valid(tmp).is_empty():
        last_error = "Temporary save verification failed."
        return false
    var full_tmp: String = ProjectSettings.globalize_path(tmp)
    var backup: String = ProjectSettings.globalize_path(_path + ".bak")
    # Only back up VALID previous state: never replace good backup with corrupt bytes.
    if FileAccess.file_exists(_path) and not _read_valid(_path).is_empty():
        if DirAccess.copy_absolute(full_path, backup) != OK:
            last_error = "Backup write failed; original save preserved."
            return false
    var code: Error = DirAccess.rename_absolute(full_tmp, full_path)
    if code != OK:
        # On systems that do not replace existing files, backup above allows recovery.
        # Avoid deleting the only copy of a save if backup was not created.
        if FileAccess.file_exists(_path) and FileAccess.file_exists(_path + ".bak"):
            if DirAccess.remove_absolute(full_path) == OK:
                code = DirAccess.rename_absolute(full_tmp, full_path)
    if code != OK:
        last_error = "Could not finalize save; temp and backup retained."
        return false
    _state = candidate.duplicate(true)
    last_error = ""
    return true
