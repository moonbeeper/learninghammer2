shader_type canvas_item;

uniform float curve_strength: hint_range(-0.4, 0.4) = 0.3;

void fragment() {
	vec2 uv = UV;
	vec2 centered = uv - 0.5;
	
	float displacement = centered.x * centered.x;
	float curve_factor = 1.0 + displacement * curve_strength;
	
	uv.y = centered.y / curve_factor + 0.5;
	
	COLOR = texture(TEXTURE, uv);
	
	// discard anything outside uvs - alpha getting zeroed
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR.a = 0.0;
	}
}