class_name ArenaWorld
extends Node2D
## Owns one run's live entities and state. No storage, ads or menus.

signal score_changed(score: int)
signal coins_changed(coins: int)
signal health_changed(current: int, maximum: int)
signal run_ended(score: int, coins: int)

const ENEMY_SCENE: PackedScene = preload("res://features/gameplay/enemy/chaser_enemy.tscn")
const COIN_SCENE: PackedScene = preload("res://features/gameplay/coin/coin_pickup.tscn")
const ARENA := Rect2(54.0, 214.0, 612.0, 860.0)

@onready var player: ArenaPlayer = $Player
@onready var _entities: Node2D = $Entities

var active: bool = true
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _score: int = 0
var _coins: int = 0
var _enemy_spawn_timer: float = 0.0
var _damage_cooldown: float = 0.0
var _enemies: Array[ChaserEnemy] = []


func _ready() -> void:
    _rng.randomize()
    player.health.changed.connect(func(current: int, maximum: int) -> void: health_changed.emit(current, maximum))
    player.health.died.connect(_on_player_died)
    _spawn_coin()
    _spawn_coin()
    _spawn_coin()
    _spawn_enemy()
    _spawn_enemy()
    score_changed.emit(_score)
    coins_changed.emit(_coins)
    health_changed.emit(player.health.current_health, player.health.max_health)


func set_active(value: bool) -> void:
    active = value
    player.active = value
    if not value:
        player.desired_direction = Vector2.ZERO
    for enemy: ChaserEnemy in _enemies:
        if is_instance_valid(enemy):
            enemy.active = value


func set_touch_direction(direction: Vector2) -> void:
    player.desired_direction = direction


func get_score() -> int:
    return _score


func get_coins() -> int:
    return _coins


func _physics_process(delta: float) -> void:
    if not active:
        return
    _enemy_spawn_timer += delta
    _damage_cooldown = maxf(0.0, _damage_cooldown - delta)
    if _enemy_spawn_timer >= 7.0 and _enemies.size() < 7:
        _enemy_spawn_timer = 0.0
        _spawn_enemy()
    if _damage_cooldown > 0.0:
        return
    for enemy: ChaserEnemy in _enemies:
        if is_instance_valid(enemy) and enemy.position.distance_to(player.position) < 50.0:
            _damage_cooldown = 1.3
            player.health.take_damage(1)
            break


func _spawn_enemy() -> void:
    var enemy: ChaserEnemy = ENEMY_SCENE.instantiate() as ChaserEnemy
    enemy.position = _random_free_position(210.0)
    enemy.target = player
    _entities.add_child(enemy)
    enemy.active = active
    _enemies.append(enemy)


func _spawn_coin() -> void:
    var coin: CoinPickup = COIN_SCENE.instantiate() as CoinPickup
    coin.position = _random_free_position(100.0)
    _entities.add_child(coin)
    coin.collected.connect(_on_coin_collected)


func _random_free_position(min_distance: float) -> Vector2:
    var candidate: Vector2 = ARENA.get_center()
    for attempt: int in range(24):
        candidate = Vector2(
            _rng.randf_range(ARENA.position.x, ARENA.end.x),
            _rng.randf_range(ARENA.position.y, ARENA.end.y)
        )
        if candidate.distance_to(player.position) >= min_distance:
            break
    return candidate


func _on_coin_collected() -> void:
    if not active:
        return
    _score += 10
    _coins += 1
    score_changed.emit(_score)
    coins_changed.emit(_coins)
    # Defer spawn to avoid modifying the physics scene tree during a collision signal.
    _spawn_coin.call_deferred()


func _on_player_died() -> void:
    set_active(false)
    run_ended.emit(_score, _coins)


func _draw() -> void:
    draw_rect(Rect2(0, 0, 720, 1280), Color("#101b30"))
    draw_rect(ARENA, Color("#203452"), true)
    for x: int in range(72, 666, 48):
        draw_line(Vector2(x, 214), Vector2(x, 1074), Color("#2b4361"), 1.0)
    for y: int in range(214, 1074, 48):
        draw_line(Vector2(54, y), Vector2(666, y), Color("#2b4361"), 1.0)
    draw_rect(ARENA, Color("#45617c"), false, 3.0)
