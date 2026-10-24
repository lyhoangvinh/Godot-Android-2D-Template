class_name CoinPickup
extends Area2D

signal collected

var _collected: bool = false


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _draw() -> void:
    draw_circle(Vector2(0, 3), 24.0, Color("#6f5228"))
    draw_circle(Vector2.ZERO, 21.0, Color("#f9d779"))
    draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 32, Color("#e8a94c"), 3.0)
    draw_line(Vector2(0, -9), Vector2(0, 9), Color("#a76e29"), 4.0)


func _on_body_entered(body: Node2D) -> void:
    if _collected or not body is ArenaPlayer:
        return
    _collected = true
    monitoring = false
    collected.emit()
    queue_free()
