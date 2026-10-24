class_name GameplayScreen
extends Node2D
## Gameplay screen coordinates presentation and persistence, never the SDK itself.

signal exit_requested
signal restart_requested

@onready var _world: ArenaWorld = $ArenaWorld
@onready var _title: Label = $HudLayer/Overlay/Title
@onready var _score_label: Label = $HudLayer/Overlay/Score
@onready var _hp_label: Label = $HudLayer/Overlay/Hp
@onready var _coins_label: Label = $HudLayer/Overlay/Coins
@onready var _info_label: Label = $HudLayer/Overlay/Info
@onready var _pause_button: Button = $HudLayer/Overlay/PauseButton
@onready var _joystick: TouchJoystick = $HudLayer/Overlay/Joystick
@onready var _modal: CenterContainer = $HudLayer/Overlay/CenterModal
@onready var _panel: PanelContainer = $HudLayer/Overlay/CenterModal/Panel
@onready var _result: Label = $HudLayer/Overlay/CenterModal/Panel/Contents/Result
@onready var _restart_button: Button = $HudLayer/Overlay/CenterModal/Panel/Contents/Restart
@onready var _menu_button: Button = $HudLayer/Overlay/CenterModal/Panel/Contents/Menu

var _repo: SaveRepository
var _run_committed: bool = false
var _game_over: bool = false
var _paused: bool = false


func _ready() -> void:
    UiStyle.apply_heading(_title, 34)
    UiStyle.apply_heading(_result, 35)
    for label: Label in [_score_label, _hp_label, _coins_label, _info_label]:
        UiStyle.apply_body(label)
    for button: Button in [_pause_button, _restart_button, _menu_button]:
        UiStyle.apply_button(button, button == _restart_button)
    var panel_style: StyleBoxFlat = StyleBoxFlat.new()
    panel_style.bg_color = UiStyle.PANEL
    panel_style.set_corner_radius_all(24)
    panel_style.set_content_margin_all(34)
    _panel.add_theme_stylebox_override("panel", panel_style)
    _joystick.direction_changed.connect(_world.set_touch_direction)
    _world.score_changed.connect(_on_score_changed)
    _world.coins_changed.connect(_on_coins_changed)
    _world.health_changed.connect(_on_hp_changed)
    _world.run_ended.connect(_on_run_ended)
    _pause_button.pressed.connect(_on_pause_pressed)
    _restart_button.pressed.connect(func() -> void: restart_requested.emit())
    _menu_button.pressed.connect(_on_exit)
    _on_score_changed(_world.get_score())
    _on_coins_changed(_world.get_coins())
    _on_hp_changed(_world.player.health.current_health, _world.player.health.max_health)


func configure(repo: SaveRepository) -> void:
    _repo = repo


func pause_for_background() -> void:
    if not _game_over:
        _set_paused(true)


func _on_pause_pressed() -> void:
    if not _game_over:
        _set_paused(not _paused)


func _set_paused(value: bool) -> void:
    _paused = value
    _world.set_active(not value)
    _pause_button.text = "RESUME" if value else "PAUSE"
    _info_label.text = "PAUSED" if value else "Drag the stick or use WASD"
    _joystick.clear_input()


func _on_score_changed(score: int) -> void:
    _score_label.text = "SCORE  %d" % score


func _on_coins_changed(coins: int) -> void:
    _coins_label.text = "COINS  %d" % coins


func _on_hp_changed(current: int, _maximum: int) -> void:
    _hp_label.text = "HP  %d" % current


func _on_run_ended(score: int, coins: int) -> void:
    if _game_over:
        return
    _game_over = true
    _commit_run()
    _joystick.hide()
    _pause_button.disabled = true
    _result.text = "GAME OVER\nScore: %d     Coins: %d" % [score, coins]
    if _repo != null and not _repo.last_error.is_empty():
        _result.text += "\nSave warning: " + _repo.last_error
    _modal.show()


func _commit_run() -> void:
    if _run_committed or _repo == null:
        return
    _run_committed = true
    if not _repo.record_run(_world.get_score(), _world.get_coins()):
        push_warning("Run could not save: " + _repo.last_error)


func _on_exit() -> void:
    _commit_run()
    exit_requested.emit()


func _exit_tree() -> void:
    _commit_run()
