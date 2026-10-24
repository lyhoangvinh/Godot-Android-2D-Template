class_name HealthComponent
extends Node
## Pure health behavior. Does not know HUD, sprite or gameplay screen.

signal changed(current: int, maximum: int)
signal died

@export_range(1, 999, 1) var max_health: int = 3
var current_health: int = 0


func _ready() -> void:
    reset()


func reset() -> void:
    current_health = max_health
    changed.emit(current_health, max_health)


func take_damage(amount: int) -> bool:
    if amount <= 0 or current_health <= 0:
        return false
    current_health = maxi(0, current_health - amount)
    changed.emit(current_health, max_health)
    if current_health == 0:
        died.emit()
    return true
