shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled, fog_disabled;
#include "res://shaders/shaderincludes/3d_perlin.gdshaderinc"

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_linear;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_linear;

uniform vec3 world_pos_offset = vec3(0.0);

uniform float sphere_radius_scale = 1.0;
uniform float sphere_theta_phi_scale = 50.0;
uniform float noise_scroll_speed = 1.0;
uniform float sine_scale = 1.0;
uniform float sine_scroll_speed = 1.0;

uniform float speedlines_blend = 0.3;
uniform float sine_blend = 0.3;

uniform float threshold = 0.5;
uniform float threshold_feather = 0.01;

uniform float distort_sphere_radius_scale = 1.0;
uniform float distort_sphere_theta_phi_scale = 50.0;
uniform float distort_scroll_speed = 1.0;
uniform float screen_scale = 1.0;

uniform bool invert_result = false;


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
	 world_position -= world_pos_offset;

	vec3 screen_normal = texture(normal_roughness_texture, SCREEN_UV).xyz;
    screen_normal = screen_normal * 2.0 - 1.0;
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(screen_normal, 0.0)).xyz;

	float lines_angle_factor = abs(dot(normalize(world_position), world_normal));
	lines_angle_factor = 1.0 - smoothstep(0.0, 0.5, lines_angle_factor);

	float lines_distance_factor = (depth <= 0.0) ? 0.0 : 1.0;

	vec3 spherical_position = cartesian_to_spherical_zero_one(world_position);

	float radius_log = log2(spherical_position.x);
	float texture_scale_mult = pow(2.0, floor(radius_log));
	float transition_factor = fract(radius_log);

	float sphere_dencity = sphere_theta_phi_scale * texture_scale_mult;
	float next_sphere_dencity = sphere_dencity * 2.0;

	float current_noise_value = sample_sphere_noise(spherical_position, sphere_dencity, sphere_radius_scale, noise_scroll_speed);
	float next_noise_value = sample_sphere_noise(spherical_position, next_sphere_dencity, sphere_radius_scale, noise_scroll_speed);

	float mixed_noise_value = mix(current_noise_value, next_noise_value, transition_factor);

	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	float screen_avg = (0.299 * screen_color.r) + (0.587 * screen_color.g) + (0.114 * screen_color.b);

	float test_value = 0.0;
	test_value += mixed_noise_value * lines_angle_factor * lines_distance_factor * min(200.0 / spherical_position.x, 1.0) * speedlines_blend;
	float sin_value = sin((spherical_position.x * sine_scale) + (TIME * -sine_scroll_speed)) * min((30.0 / spherical_position.x), 1.0) * sine_blend;
	test_value += invert_result ? -sin_value : sin_value;
	float threshold_diff = abs(screen_avg - threshold);

	//vec3 scaled_screen_color = texture(screen_texture, centered_scale_uv(SCREEN_UV, vec2(1.0 + (mixed_noise_value * lines_angle_factor * lines_distance_factor * 0.08)))).rgb;
	//float scaled_avg = (0.299 * scaled_screen_color.r) + (0.587 * scaled_screen_color.g) + (0.114 * scaled_screen_color.b);

	float result = screen_avg + (threshold_diff * test_value);
	result = smoothstep(threshold, threshold + (threshold_feather * threshold_diff), result);

	if(invert_result) result = 1.0 - result;

	//result += 1.0;
	//result /= 2.0;

	//float sampled_distort_noise = sample_sphere_noise(spherical_position, distort_sphere_theta_phi_scale, distort_sphere_radius_scale, distort_scroll_speed);
	//sampled_distort_noise *= lines_angle_factor;
	//sampled_distort_noise *= lines_distance_factor;
	//vec3 scaled_screen_color = texture(screen_texture, centered_scale_uv(SCREEN_UV, vec2(1.0 + (mixed_noise_value * lines_angle_factor * lines_distance_factor * 0.08)))).rgb;

	ALBEDO = vec3(result);
	//ALBEDO = vec3(abs(brightnes_scale_power - screen_avg));
	//ALBEDO = scaled_screen_color;
}