shader_type spatial;
render_mode unshaded, fog_disabled, blend_add;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler3D noise_sampler;
uniform sampler2D noise_gradient;

uniform float sphere_radius_scale = 1.0;
uniform float sphere_radius_power = 1.0;
uniform float sphere_radius_scroll_speed = 1.0;
uniform vec3 offset_vector = vec3(0.0);
uniform vec3 pre_sphere_scale_vector = vec3(1.0);
uniform float mult_val = 1.0;

vec3 cartesian_to_spherical(vec3 cartesian_coords){
	float radius = length(cartesian_coords);
	float theta = atan(cartesian_coords.x, cartesian_coords.z);
	float phi = acos(cartesian_coords.y / radius);
	return vec3(radius, theta, phi);
}

vec3 cartesian_to_spherical_zero_one(vec3 cartesian_coords){
	vec3 spherical_coords = cartesian_to_spherical(cartesian_coords);
	spherical_coords.y += PI;
	spherical_coords.y /= 2.0 * PI;
	spherical_coords.z /= 1.0 * PI;
	return spherical_coords;
}

void vertex() {
  POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment(){
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	#else
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	#endif
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	world_position += offset_vector;
	world_position *= pre_sphere_scale_vector;
	
	vec3 sphere_coords = cartesian_to_spherical_zero_one(world_position * pre_sphere_scale_vector);
	
	sphere_coords.x /= sphere_radius_scale;
	sphere_coords.x = pow(sphere_coords.x, 1.0 / sphere_radius_power);
	sphere_coords.x -= TIME * sphere_radius_scroll_speed;
	
	sphere_coords.z = world_position.y;
	
	vec4 sampled_value = texture(noise_gradient, vec2(texture(noise_sampler ,sphere_coords).x, 0.5));
	sampled_value *= mult_val;
	
	ALBEDO = sampled_value.rgb;
	//ALBEDO = sphere_coords;
}