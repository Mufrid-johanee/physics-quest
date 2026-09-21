shader_type canvas_item;
## Near-black key for JPG sprites that lack an alpha channel.

uniform vec3 key_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float threshold : hint_range(0.0, 1.0) = 0.12;
uniform float softness : hint_range(0.001, 0.5) = 0.08;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float d = distance(c.rgb, key_color);
	float a = smoothstep(threshold, threshold + softness, d);
	COLOR = vec4(c.rgb, c.a * a);
}
