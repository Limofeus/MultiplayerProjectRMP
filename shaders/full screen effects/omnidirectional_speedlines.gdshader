shader_type canvas_item;

uniform sampler2D test_texture : filter_linear, repeat_enable;
uniform float vector_scaling = 1.2;
//uniform float scroll_speed = 0.15; //Depricated, use scroll_position instead
uniform float scroll_position = 0.0;
uniform float finalizing_alpha = 0.0;
uniform vec3 sphere_rotation_vector = vec3(0.0);
uniform vec2 texture_scaling = vec2(1.0);
uniform vec2 sampled_value_params = vec2(0.0, 1.0);
uniform vec2 pole_reject_params = vec2(0.0, 1.0);
uniform vec2 screen_mask_params = vec2(0.0, 1.0);
uniform vec2 finalizing_params = vec2(0.0, 1.0);

vec2 sample_sphere_uv(vec3 sphere_unit_vector){
	//Wikipedia formula (Spherical mapping)
	float u = 0.5 + (atan(sphere_unit_vector.x, sphere_unit_vector.y) / (2.0 * PI));
	float v = 0.5 + (asin(sphere_unit_vector.z)/PI);

	return vec2(u, v);
}

vec2 add_uv_effects(vec2 uv_in){
	return vec2(uv_in.x * texture_scaling.x, (uv_in.y * texture_scaling.y) + (scroll_position));
}

vec3 rotated_vector(vec3 sphere_unit_vector, vec3 rotation_vector){

	vec3 rotated_vector = sphere_unit_vector;

	//Z axis rotation
	rotated_vector = vec3(
		(rotated_vector.x * cos(rotation_vector.z)) - (rotated_vector.y * sin(rotation_vector.z)),
		(rotated_vector.x * sin(rotation_vector.z)) + (rotated_vector.y * cos(rotation_vector.z)),
		rotated_vector.z
	);

	//X axis rotation
	rotated_vector = vec3(
	rotated_vector.x,
	(rotated_vector.y * cos(rotation_vector.x)) - (rotated_vector.z * sin(rotation_vector.x)),
	(rotated_vector.y * sin(rotation_vector.x)) + (rotated_vector.z * cos(rotation_vector.x))
	);

	//Y axis rotation
	rotated_vector = vec3(
	(rotated_vector.x * cos(rotation_vector.y)) + (rotated_vector.z * sin(rotation_vector.y)),
	rotated_vector.y,
	-(rotated_vector.x * sin(rotation_vector.y)) + (rotated_vector.z * cos(rotation_vector.y))
	);

	return rotated_vector;
}

float apply_params(float value, vec2 params){
	return clamp((value - params.x) * params.y, 0.0, 1.0);
}

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 mask_uv = vec2(SCREEN_UV.x - 0.5, SCREEN_UV.y - 0.5) * 2.0;
	vec2 proportional_uv = vec2(SCREEN_UV.x - 0.5, (SCREEN_UV.y - 0.5) * aspect_ratio) * 2.0 * vector_scaling;
	COLOR = texture(test_texture, proportional_uv);
	COLOR = vec4(proportional_uv, 0.0, 1.0);

	vec2 proportional_uv_squared = vec2(proportional_uv.x * proportional_uv.x, proportional_uv.y * proportional_uv.y);

	vec3 sphere_unit_vector = normalize(vec3(proportional_uv.x, proportional_uv.y, 1));

	float unit_vector_check_one = length(sphere_unit_vector) - 1.0;

	COLOR = vec4(sphere_unit_vector, 1.0);

	sphere_unit_vector = rotated_vector(sphere_unit_vector, sphere_rotation_vector);

	float unit_vector_check_two = length(sphere_unit_vector) - 1.0;

	vec2 sampled_uv = sample_sphere_uv(sphere_unit_vector);
	vec2 uv_with_effects = add_uv_effects(sampled_uv);

	COLOR = vec4(sampled_uv, 0.0, 1.0);
	float sampled_value = apply_params(texture(test_texture, uv_with_effects).r, sampled_value_params);
	float pole_reject = apply_params(1.0 - (abs(sampled_uv.y - 0.5) * 2.0), pole_reject_params);
	float screen_mask = apply_params((mask_uv.x * mask_uv.x) + (mask_uv.y * mask_uv.y), screen_mask_params);

	COLOR = vec4(1.0, 1.0, 1.0, finalizing_alpha * apply_params(sampled_value * pole_reject * screen_mask, finalizing_params));
}