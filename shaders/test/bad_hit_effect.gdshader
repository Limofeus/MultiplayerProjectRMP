shader_type spatial;
render_mode blend_add, shadows_disabled;

uniform sampler2D hit_texture;

uniform vec3 edge_color : source_color = vec3(0.0);
uniform vec3 main_color : source_color = vec3(0.0);

uniform vec2 scroll_speed = vec2(0.0, -1.0);
uniform vec2 displace_power = vec2(0.0, -0.5);
uniform vec2 displace_correct = vec2(0.0, 0.0);
uniform vec2 uv_correct = vec2(0.0);
uniform float manual_power = 1.0;

uniform float projectile_fade = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV + uv_correct;
	float noise_scroll = texture(hit_texture, (uv * 0.5) + (scroll_speed * TIME)).b;
	float power_scaling = 1.0 - texture(hit_texture, uv).r;
	vec2 displace_vector = (displace_power * noise_scroll * power_scaling) + displace_correct;
	vec2 displace_vector_manual = (displace_power * noise_scroll * manual_power) + displace_correct;
	float cut_edge = texture(hit_texture, uv + displace_vector_manual).g;
	float cut_full = texture(hit_texture, uv + displace_vector).r;
	float smoother_fade_value = clamp(projectile_fade * projectile_fade, 0.0, 1.0);
	ALBEDO = (edge_color * cut_edge) + (main_color * cut_full);
	ALPHA = smoother_fade_value * smoothstep(1.0 - projectile_fade, 1.1, clamp(noise_scroll * cut_full + cut_edge, 0.0, 1.0));
}