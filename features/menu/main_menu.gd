class_name MainMenu
extends Control

signal start_requested

@onready var _title: Label = $Center/Content/Title
@onready var _subtitle: Label = $Center/Content/Subtitle
@onready var _best: Label = $Center/Content/BestScore
@onready var _coins: Label = $Center/Content/Coins
@onready var _notice: Label = $Center/Content/Notice
@onready var _status: Label = $Center/Content/Status
@onready var _start: Button = $Center/Content/StartButton
@onready var _sound: Button = $Center/Content/SoundButton
@onready var _mock_ad: Button = $Center/Content/MockAdButton

var _repo: SaveRepository
var _ads: AdsGateway


func _ready() -> void:
    UiStyle.apply_heading(_title, 52)
    for label: Label in [_subtitle, _best, _coins, _notice, _status]:
        UiStyle.apply_body(label)
    for button: Button in [_start, _sound, _mock_ad]:
        UiStyle.apply_button(button, button == _start)
    _start.pressed.connect(func() -> void: start_requested.emit())
    _sound.pressed.connect(_on_sound)
    _mock_ad.pressed.connect(_on_mock_reward)


func configure(repo: SaveRepository, ads: AdsGateway) -> void:
    _repo = repo
    _ads = ads
    _ads.rewarded_finished.connect(_on_rewarded_finished)
    if not OS.has_feature("editor"):
        _mock_ad.hide()
        _notice.text = "Ads/Billing are NOT connected. Demo gameplay only."
    _update_labels()
    if _repo.read_only:
        _status.text = "SAVE PROTECTED: " + _repo.last_error
        _mock_ad.disabled = true


func _update_labels() -> void:
    _best.text = "BEST SCORE   %d" % _repo.get_best_score()
    _coins.text = "COINS   %d" % _repo.get_coins()
    _sound.text = "SOUND PREF: " + ("ON" if _repo.is_sound_enabled() else "OFF")


func _on_sound() -> void:
    if not _repo.set_sound_enabled(not _repo.is_sound_enabled()):
        _status.text = "Save failed: " + _repo.last_error
    _update_labels()


func _on_mock_reward() -> void:
    _ads.show_rewarded("template_demo_only")


func _on_rewarded_finished(placement: String, earned: bool) -> void:
    if placement != "template_demo_only" or not earned:
        _status.text = "Mock reward declined."
        return
    if not _repo.add_demo_bonus(5):
        _status.text = "Save failed: " + _repo.last_error
        return
    _status.text = "MOCK success — granted 5 demo coins."
    _update_labels()
