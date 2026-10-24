extends SceneTree
## Dependency-free smoke/regression tests. Run after Godot Editor import.

var _passes: int = 0
var _failures: int = 0


func _initialize() -> void:
    call_deferred("_run")


func _check(condition: bool, description: String) -> void:
    if condition:
        _passes += 1
        print("PASS: ", description)
    else:
        _failures += 1
        push_error("FAIL: " + description)


func _fixture(path: String) -> Dictionary:
    var decoded: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
    if typeof(decoded) != TYPE_DICTIONARY:
        return {}
    return decoded


func _run() -> void:
    var v1: Dictionary = _fixture("res://tests/fixtures/save_v1.json")
    var migrated: Dictionary = SaveMigrator.migrate(v1)
    _check(SaveValidator.is_valid(migrated), "v1 migrates to valid v2")
    _check(int(migrated.get("profile", {}).get("coins", -1)) == 53, "v1 gold preserved")
    _check(int(migrated.get("profile", {}).get("best_score", -1)) == 120, "v1 best score preserved")
    _check(migrated.get("settings", {}).get("sound_enabled") == false, "v1 setting preserved")
    var v2: Dictionary = _fixture("res://tests/fixtures/save_v2.json")
    _check(SaveValidator.is_valid(v2), "v2 fixture valid")
    _check(not SaveValidator.is_valid({"schema_version": 2}), "malformed save rejected")
    _check(SaveMigrator.migrate(_fixture("res://tests/fixtures/save_future_unsupported.json")).is_empty(), "future schema rejected")
    _check(not SaveValidator.is_valid({"schema_version": 2, "profile": {"coins": -1, "best_score": 0}, "settings": {"sound_enabled": true}}), "negative coins rejected")

    var base: String = "user://template_tests"
    DirAccess.make_dir_recursive_absolute(base)
    var path: String = base + "/state.json"
    for suffix: String in ["", ".tmp", ".bak"]:
        if FileAccess.file_exists(path + suffix):
            DirAccess.remove_absolute(path + suffix)
    var repo: SaveRepository = SaveRepository.new(path)
    _check(repo.get_best_score() == 0 and repo.get_coins() == 0, "defaults")
    _check(repo.record_run(100, 2), "first commit")
    _check(repo.record_run(50, 3), "second commit")
    _check(repo.get_best_score() == 100 and repo.get_coins() == 5, "score max and currency accumulate")
    var reloaded: SaveRepository = SaveRepository.new(path)
    _check(reloaded.get_best_score() == 100 and reloaded.get_coins() == 5, "durable reload")
    _check(not reloaded.record_run(-1, 2), "negative run rejected")
    # Last valid main gets copied to backup before new data replaces it.
    _check(reloaded.record_run(110, 7), "third commit")
    var broken: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if broken != null:
        broken.store_string("{broken json")
        broken.close()
    var recovered: SaveRepository = SaveRepository.new(path)
    _check(recovered.get_best_score() == 100 and recovered.get_coins() == 5, "backup recovery")
    # Test future-version save does not reset and overwrite player data.
    var future: FileAccess = FileAccess.open(path, FileAccess.WRITE)
    if future != null:
        future.store_string(JSON.stringify(_fixture("res://tests/fixtures/save_future_unsupported.json")))
        future.close()
    var unreadable: FileAccess = FileAccess.open(path + ".bak", FileAccess.WRITE)
    if unreadable != null:
        unreadable.store_string("not json")
        unreadable.close()
    var protected: SaveRepository = SaveRepository.new(path)
    _check(protected.read_only, "unsupported/corrupt save guarded read-only")
    _check(not protected.record_run(1000, 1000), "protected save cannot be overwritten")
    var ads: MockAdsGateway = MockAdsGateway.new()
    var callback_observed: Array = []
    ads.rewarded_finished.connect(func(placement: String, earned: bool) -> void:
        callback_observed.append([placement, earned])
    )
    ads.next_reward_succeeds = false
    ads.show_rewarded("test")
    _check(callback_observed.size() == 1 and callback_observed[0][1] == false, "declined rewarded event")
    ads.free()
    var billing: MockBillingGateway = MockBillingGateway.new()
    var purchasing: Array = []
    billing.purchase_finished.connect(func(product_id: String, success: bool) -> void:
        purchasing.append([product_id, success])
    )
    billing.purchase("fake.remove_ads")
    _check(purchasing.size() == 1 and purchasing[0][1] == false, "mock billing fails closed")
    billing.free()
    print("RESULT: %d passed, %d failed" % [_passes, _failures])
    quit(0 if _failures == 0 else 1)
