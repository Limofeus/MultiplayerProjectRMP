shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, shadows_disabled;

uniform sampler2D main_texture : filter_linear_mipmap_anisotropic;
uniform vec4 main_color : source_color = vec4(1.0);
uniform float power_mult = 1.0;
uniform float alpha_mult = 1.0;
uniform float mpimap_offset = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 sampled_texture = texture(main_texture, UV, mpimap_offset);
	ALBEDO = main_color.rgb * power_mult * sampled_texture.a;
	ALPHA = main_color.a * sampled_texture.a * alpha_mult;
}