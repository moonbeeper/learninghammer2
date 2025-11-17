// NOTE: Shader automatically converted from Godot Engine 4.5.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D screen_tex: source_color, filter_linear_mipmap, hint_default_white;
uniform vec2 uv_min = vec2(0.52, 0.48);
uniform vec2 uv_max = vec2(0.738, 0.016);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_g, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D texture_ambient_occlusion : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 ao_texture_channel;
uniform float ao_light_affect : hint_range(0.0, 1.0, 0.01);
void fragment() {
	// remap uvs
	vec2 local_uv = (UV - uv_min) / (uv_max - uv_min);
	// do horizontal or vertical or whatever flip. x for y and y for x
	local_uv = vec2(local_uv.y,  local_uv.x);

	// discard anything outside uvs
    if (local_uv.x < 0.0 || local_uv.x > 1.0 || local_uv.y < 0.0 || local_uv.y > 1.0) {
        discard;
    }

    ALBEDO = texture(screen_tex, local_uv).rgb;

	float metallic_tex = dot(texture(texture_metallic, UV), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(0.0, 1.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, UV), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;

	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, UV).rgb;
	NORMAL_MAP_DEPTH = normal_scale;

	vec3 emission_tex = texture(screen_tex, local_uv).rgb;
	// Emission Operator: Add
	EMISSION = (emission.rgb + emission_tex) * emission_energy;

	// Ambient Occlusion: Enabled
	AO = dot(texture(texture_ambient_occlusion, UV), ao_texture_channel);
	AO_LIGHT_AFFECT = ao_light_affect;

}