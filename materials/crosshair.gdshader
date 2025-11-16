shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float threshold: hint_range(0, 1) = 0.5;
uniform float smoothness: hint_range(0.01, 0.2) = 0.08;
uniform vec4 color_dark: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_light: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float alpha: hint_range(0, 1) = 1.0;

void fragment() {
	vec2 center_uv = vec2(0.5, 0.5);
	vec4 bg_col = texture(screen_texture, center_uv);
	float luminance = dot(bg_col.rgb, vec3(0.299, 0.587, 0.114));
	float t = smoothstep(threshold - smoothness, threshold + smoothness, luminance);
	vec3 cross_col = mix(color_dark.rgb, color_light.rgb, 1.0 - t);
	float cross_alpha = texture(TEXTURE, UV).a;
	COLOR = vec4(cross_col, cross_alpha * alpha);
}