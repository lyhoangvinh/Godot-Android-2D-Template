class_name UiStyle
extends RefCounted
## Minimal reusable UI styling. All colors are centralized.

const BG := Color("#101b30")
const PANEL := Color("#1d3150")
const MAIN := Color("#65d6c0")
const TEXT := Color("#f5f7fb")
const MUTED := Color("#adbad3")


static func apply_button(button: Button, important: bool = false) -> void:
    button.add_theme_font_size_override("font_size", 24)
    button.add_theme_color_override("font_color", BG if important else TEXT)
    button.add_theme_color_override("font_hover_color", BG)
    for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
        var style: StyleBoxFlat = StyleBoxFlat.new()
        style.bg_color = MAIN if important else PANEL
        if state == "pressed":
            style.bg_color = Color("#399f92")
        if state == "hover":
            style.bg_color = Color("#83e4d0")
        if state == "focus":
            style.bg_color = Color.TRANSPARENT
            style.border_color = MAIN
            style.set_border_width_all(2)
        style.set_corner_radius_all(16)
        style.content_margin_left = 24
        style.content_margin_right = 24
        style.content_margin_top = 14
        style.content_margin_bottom = 14
        button.add_theme_stylebox_override(state, style)


static func apply_heading(label: Label, size: int) -> void:
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", TEXT)


static func apply_body(label: Label) -> void:
    label.add_theme_font_size_override("font_size", 22)
    label.add_theme_color_override("font_color", MUTED)
