extends Node
## Composition root: owns navigation, save, and platform gateways.
## Never put game rules in this file.

const MENU_SCENE: PackedScene = preload("res://features/menu/main_menu.tscn")
const GAME_SCENE: PackedScene = preload("res://features/gameplay/gameplay.tscn")

@onready var _screen_host: Node = $ScreenHost

var _save: SaveRepository = SaveRepository.new()
var _ads: MockAdsGateway
var _billing: MockBillingGateway
var _current: Node


func _ready() -> void:
    _ads = MockAdsGateway.new()
    _ads.name = "MockAds"
    add_child(_ads)
    _billing = MockBillingGateway.new()
    _billing.name = "MockBilling"
    add_child(_billing)
    _open_menu()


func _replace_screen(screen: Node) -> void:
    if is_instance_valid(_current):
        _screen_host.remove_child(_current)
        _current.queue_free()
    _current = screen
    _screen_host.add_child(screen)


func _open_menu() -> void:
    var menu: MainMenu = MENU_SCENE.instantiate() as MainMenu
    _replace_screen(menu)
    menu.configure(_save, _ads)
    menu.start_requested.connect(_open_game)


func _open_game() -> void:
    var gameplay: GameplayScreen = GAME_SCENE.instantiate() as GameplayScreen
    _replace_screen(gameplay)
    gameplay.configure(_save)
    gameplay.exit_requested.connect(_open_menu)
    gameplay.restart_requested.connect(_open_game)


func _notification(what: int) -> void:
    if what == MainLoop.NOTIFICATION_APPLICATION_PAUSED:
        if is_instance_valid(_current) and _current is GameplayScreen:
            (_current as GameplayScreen).pause_for_background()
