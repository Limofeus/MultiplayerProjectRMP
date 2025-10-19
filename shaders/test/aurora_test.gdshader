shader_type spatial;
render_mode unshaded, fog_disabled, blend_add;
#include "res://shaders/shaderincludes/3d_perlin.gdshaderinc"

uniform sampler2D aurora_color_gradient : repeat_disable;
uniform float aurora_mult = 1.0;

void vertex() {
	float aurora_pos = 1.0 - (abs(UV.y - 0.5) * 2.0);
	VERTEX += vec3(3.0, 0.0, 0.0) * (sin((UV.x * 5.0) + TIME) + (aurora_pos * 3.0));
}

void fragment() {
	float aurora_pos = 1.0 - (abs(UV.y - 0.5) * 2.0);
	float sampled_noise = sample_perlin3D(vec3(aurora_pos + TIME, UV.x * 100.0, TIME * 0.2));
	float aurora_val = aurora_pos * (1.0 - abs(sampled_noise));
	vec3 aurora_col = texture(aurora_color_gradient, vec2(aurora_val, 0.5)).rgb;
	ALBEDO = aurora_col * aurora_mult;
}
