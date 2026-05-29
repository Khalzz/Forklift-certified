shader_type canvas_item;

void fragment() {
    // UV.y creates a vertical gradient (0.0 at top, 1.0 at bottom)
    // COLOR.a is the original alpha of the UI element
    COLOR.a = COLOR.a * (1.0 - UV.y);
}