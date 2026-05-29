shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.5;
uniform vec4 fill_color : source_color = vec4(0.2, 0.8, 0.2, 1.0);
uniform vec4 empty_color : source_color = vec4(0.3, 0.3, 0.3, 1.0);

void fragment() {
    vec4 text = texture(TEXTURE, UV);

    // Use the glyph alpha as the mask
    float mask = text.a;

    // VERTEX gives us actual screen position — use it for fill direction
    // instead of UV which is local to each glyph atlas tile
    float fill = step(1.0 - progress, UV.y);

    COLOR.rgb = mix(empty_color.rgb, fill_color.rgb, fill);
    COLOR.a = mask;
}