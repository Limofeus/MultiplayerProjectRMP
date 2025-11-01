shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled, fog_disabled;
#include "res://shaders/shaderincludes/3d_perlin.gdshaderinc"

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_linear;

uniform float screen_uv_divider = 50.0;
uniform float pixel_offset = 0.0;

vec3 cartesian_to_spherical(vec3 cartesian_coords){
	float radius = length(cartesian_coords);
	float theta = atan(cartesian_coords.x, cartesian_coords.z);
	float phi = acos(cartesian_coords.y / radius);
	return vec3(radius, theta, phi);
}

vec2 centered_scale_uv(vec2 input_uv, vec2 scale){
	vec2 uv = input_uv - vec2(0.5, 0.5);
	uv /= scale;
	uv += vec2(0.5, 0.5);
	return uv;
}

vec3 cartesian_to_spherical_zero_one(vec3 cartesian_coords){
	vec3 spherical_coords = cartesian_to_spherical(cartesian_coords);
	spherical_coords.y += PI;
	spherical_coords.y /= 2.0 * PI;
	spherical_coords.z /= 1.0 * PI;
	return spherical_coords;
}

float sample_sphere_noise(vec3 spherical_position, float sphere_dencity, float sphere_radius, float scroll_speed){
	vec3 noise_repeat = vec3(0.0, sphere_dencity, sphere_dencity);
	vec3 sample_position = spherical_position * vec3(sphere_radius, sphere_dencity, sphere_dencity) + vec3(-scroll_speed * TIME, 0.0, 0.0);

	return sample_repeating_perlin3D(sample_position, noise_repeat);
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

	vec3 screen_normal = texture(normal_roughness_texture, SCREEN_UV).xyz;
    screen_normal = screen_normal * 2.0 - 1.0;
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(screen_normal, 0.0)).xyz;

	vec3 world_vec_normalized = normalize(world.xyz);
	vec3 spherical_world_uv = cartesian_to_spherical_zero_one(world_vec_normalized);

	vec2 screen_sample_uv = SCREEN_UV;
	screen_sample_uv + vec2(fract(pixel_offset), 0.0);
	screen_sample_uv *= screen_uv_divider;
	screen_sample_uv = floor(screen_sample_uv);
	screen_sample_uv /= screen_uv_divider;

	vec3 screen_color = texture(screen_texture, screen_sample_uv).rgb;

	//ALBEDO = spherical_world_uv.ggg;
	ALBEDO = screen_color;
}