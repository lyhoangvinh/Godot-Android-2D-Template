class_name ArenaPlayer
extends CharacterBody2D

const SPEED: float = 270.0
const BOUNDS: Rect2 = Rect2(64.0, 222.0, 592.0, 830.0)

@onready var health: HealthComponent = $Health

var desired_direction: Vector2 = Vector2.ZERO
var active: bool = true
var _phase: float = 0.0


func _physics_process(delta: float) -> void:
    if not active:
        velocity = Vector2.ZERO
        return
    _phase += delta
    var keyboard: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    velocity = (keyboard if keyboard != Vector2.ZERO else desired_direction) * SPEED
    move_and_slide()
    position = position.clamp(BOUNDS.position, BOUNDS.end)
    queue_redraw()


func _draw() -> void:
    var bob: float = sin(_phase * 8.0) * 2.0
    draw_circle(Vector2(0.0, bob + 5.0), 29.0, Color("#142e40"))
    draw_circle(Vector2(0.0, bob), 25.0, Color("#65d6c0"))
    draw_circle(Vector2(-8.0, bob - 5.0), 3.0, Color("#101b30"))
    draw_circle(Vector2(8.0, bob - 5.0), 3.0, Color("#101b30"))
    draw_arc(Vector2(0.0, bob + 2.0), 9.0, 0.15, PI - 0.15, 16, Color("#101b30"), 2.0)
