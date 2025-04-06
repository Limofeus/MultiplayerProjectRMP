shader_type spatial;
render_mode shadows_disabled, depth_draw_always;

uniform vec3 main_color : source_color = vec3(0.0);
uniform float projectile_lifetime = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = main_color;
	ALPHA = projectile_lifetime;
}