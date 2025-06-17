shader_type canvas_item;

uniform float outline_width : hint_range(0, 0.2) = 0.05;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    float dist = distance(UV, vec2(0.5));
    float outline = smoothstep(0.5 - outline_width, 0.5, dist);
    
    COLOR = mix(tex_color, outline_color, outline);
    COLOR.a = max(tex_color.a, outline); // Mantener transparencia
}