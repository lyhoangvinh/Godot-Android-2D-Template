class_name ChaserEnemy
extends CharacterBody2D
## Dumb demo enemy. AI behavior stays in this feature, not in the scene router.

@export var speed: float = 105.0
var target: Node2D
var active: bool = true


func _physics_process(_delta: float) -> void:
    if not active or not is_instance_valid(target):
        velocity = Vector2.ZERO
        return
    velocity = global_position.direction_to(target.global_position) * speed
    move_and_slide()


func _draw() -> void:
    draw_circle(Vector2(0, 5), 25.0, Color("#532d40"))
    draw_circle(Vector2.ZERO, 22.0, Color("#fa869a"))
    draw_circle(Vector2(-8, -3), 3.0, Color("#462b3e"))
    draw_circle(Vector2(8, -3), 3.0, Color("#462b3e"))
    draw_line(Vector2(-7, 9), Vector2(7, 9), Color("#462b3e"), 2)
