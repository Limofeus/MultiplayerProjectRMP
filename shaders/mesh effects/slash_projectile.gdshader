shader_type spatial;
render_mode unshaded, blend_add, shadows_disabled, cull_disabled;

uniform sampler2D hit_texture;
uniform vec3 main_color : source_color = vec3(0.0);
uniform float projectile_lifetime = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float hit_alpha = texture(hit_texture, UV).a;
	ALBEDO = main_color * projectile_lifetime * hit_alpha;
	ALPHA = hit_alpha * projectile_lifetime;
}