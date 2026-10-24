class_name TouchJoystick
extends Control
## Multi-touch safe local joystick. Mouse support for editor.

signal direction_changed(direction: Vector2)

const RADIUS: float = 76.0
var _touch_id: int = -10
var _direction: Vector2 = Vector2.ZERO


func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()


func clear_input() -> void:
    _touch_id = -10
    _set_direction(Vector2.ZERO)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch: InputEventScreenTouch = event
        if touch.pressed and _touch_id == -10:
            _touch_id = touch.index
            _update_position(touch.position)
            accept_event()
        elif not touch.pressed and touch.index == _touch_id:
            clear_input()
            accept_event()
    elif event is InputEventScreenDrag:
        var drag: InputEventScreenDrag = event
        if drag.index == _touch_id:
            _update_position(drag.position)
            accept_event()
    elif event is InputEventMouseButton:
        var click: InputEventMouseButton = event
        if click.button_index == MOUSE_BUTTON_LEFT:
            if click.pressed and _touch_id == -10:
                _touch_id = -1
                _update_position(click.position)
            elif not click.pressed and _touch_id == -1:
                clear_input()
            accept_event()
    elif event is InputEventMouseMotion and _touch_id == -1:
        _update_position((event as InputEventMouseMotion).position)
        accept_event()


func _update_position(local_position: Vector2) -> void:
    var center: Vector2 = size / 2.0
    _set_direction((local_position - center) / RADIUS)


func _set_direction(value: Vector2) -> void:
    _direction = value.limit_length(1.0)
    if _direction.length() < 0.12:
        _direction = Vector2.ZERO
    direction_changed.emit(_direction)
    queue_redraw()


func _draw() -> void:
    var center: Vector2 = size / 2.0
    draw_circle(center, RADIUS + 16.0, Color(0.48, 0.77, 0.83, 0.18))
    draw_arc(center, RADIUS, 0.0, TAU, 48, Color("#78afbc"), 3.0)
    draw_circle(center + _direction * RADIUS, 28.0, Color("#65d6c0"))
