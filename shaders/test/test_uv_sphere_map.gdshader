shader_type canvas_item;

//uniform sampler2D test_texture : filter_nearest, repeat_enable;
uniform sampler2D test_texture : filter_linear, repeat_enable;
uniform float vector_scaling = 1.0;
uniform float scroll_speed = 1.0;
uniform float finalizing_alpha = 1.0;
uniform vec3 sphere_rotation_vector = vec3(0.0);
uniform vec2 texture_scaling = vec2(1.0);
uniform vec2 sampled_value_params = vec2(0.0, 1.0);
uniform vec2 pole_reject_params = vec2(0.0, 1.0);
uniform vec2 screen_mask_params = vec2(0.0, 1.0);
uniform vec2 finalizing_params = vec2(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 sample_sphere_uv(vec3 sphere_unit_vector){
	//Wikipedia formula (Spherical mapping)
	float u = 0.5 + (atan(sphere_unit_vector.x, sphere_unit_vector.y) / (2.0 * PI));
	float v = 0.5 + (asin(sphere_unit_vector.z)/PI);

	//Stack Exchange formula (Cylindrycal mapping)
	//float u = atan(sphere_unit_vector.x, sphere_unit_vector.y) / (2.0 * PI) + 0.5;
	//float v = sphere_unit_vector.z * 0.5 + 0.5;

	return vec2(u, v);
}

vec2 add_uv_effects(vec2 uv_in){
	return vec2(uv_in.x * texture_scaling.x, (uv_in.y * texture_scaling.y) + (TIME * scroll_speed));
}

//This thing is prone to gimbal-lock and all but it's the simplest solution I think
//And also it seems to NOT WORK CORRECTLY??? Why does it return non units vectors when given unit vectors as input?
vec3 rotated_vector(vec3 sphere_unit_vector, vec3 rotation_vector){
	float x = sphere_unit_vector.x;
	float y = sphere_unit_vector.y;
	float z = sphere_unit_vector.z;

	vec3 maybe_its_a_floint_point_error = sphere_unit_vector;

	//Z axis rotation
	x = (x * cos(rotation_vector.z)) - (y * sin(rotation_vector.z));
	y = (x * sin(rotation_vector.z)) + (y * cos(rotation_vector.z));
	z = z;
	maybe_its_a_floint_point_error = vec3(
		(maybe_its_a_floint_point_error.x * cos(rotation_vector.z)) - (maybe_its_a_floint_point_error.y * sin(rotation_vector.z)),
		(maybe_its_a_floint_point_error.x * sin(rotation_vector.z)) + (maybe_its_a_floint_point_error.y * cos(rotation_vector.z)),
		maybe_its_a_floint_point_error.z
	);

	//X axis rotation
	x = x;
	y = (y * cos(rotation_vector.x)) - (z * sin(rotation_vector.x));
	z = (y * sin(rotation_vector.x)) + (z * cos(rotation_vector.x));
	maybe_its_a_floint_point_error = vec3(
	maybe_its_a_floint_point_error.x,
	(maybe_its_a_floint_point_error.y * cos(rotation_vector.x)) - (maybe_its_a_floint_point_error.z * sin(rotation_vector.x)),
	(maybe_its_a_floint_point_error.y * sin(rotation_vector.x)) + (maybe_its_a_floint_point_error.z * cos(rotation_vector.x))
	);

	//Y axis rotation
	x = (x * cos(rotation_vector.y)) + (z * sin(rotation_vector.y));
	y = y;
	z = -(x * sin(rotation_vector.y)) + (z * cos(rotation_vector.y));
	maybe_its_a_floint_point_error = vec3(
	(maybe_its_a_floint_point_error.x * cos(rotation_vector.y)) + (maybe_its_a_floint_point_error.z * sin(rotation_vector.y)),
	maybe_its_a_floint_point_error.y,
	-(maybe_its_a_floint_point_error.x * sin(rotation_vector.y)) + (maybe_its_a_floint_point_error.z * cos(rotation_vector.y))
	);

	return maybe_its_a_floint_point_error;
	//AND YES IT FDFUDUCVKCIUJGD WWWASAASADSJ GKJASYDG KJY ASGKJYFG KJASY GKJYFGAWJYSG FKYJAW GKJY GFUWYAG UYFJ WAf
	return vec3(x, y, z);
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

	//Better way would be to use math and stuff to get accurate sphere projected unit vector, but I'm too lazy for it, so normalized random ass vector should sufice
	vec3 sphere_unit_vector = normalize(vec3(proportional_uv.x, proportional_uv.y, 1));

	//Okay, this works poorly, but what if I use the same rotation function here?
	//vec3 sphere_unit_vector = rotated_vector(vec3(0.0, 0.0, 1.0), vec3(proportional_uv, 0.0));
	//This also wont work correctly for some reason :(

	float unit_vector_check_one = length(sphere_unit_vector) - 1.0;

	COLOR = vec4(sphere_unit_vector, 1.0);

	sphere_unit_vector = rotated_vector(sphere_unit_vector, sphere_rotation_vector);
	//sphere_unit_vector = normalize(rotated_vector(sphere_unit_vector, sphere_rotation_vector));

	float unit_vector_check_two = length(sphere_unit_vector) - 1.0;


	vec2 sampled_uv = sample_sphere_uv(sphere_unit_vector);
	vec2 uv_with_effects = add_uv_effects(sampled_uv);

	COLOR = vec4(sampled_uv, 0.0, 1.0);
	float sampled_value = apply_params(texture(test_texture, uv_with_effects).r, sampled_value_params);
	float pole_reject = apply_params(1.0 - (abs(sampled_uv.y - 0.5) * 2.0), pole_reject_params);
	float screen_mask = apply_params((mask_uv.x * mask_uv.x) + (mask_uv.y * mask_uv.y), screen_mask_params);

	COLOR = vec4(1.0, 1.0, 1.0, finalizing_alpha * apply_params(sampled_value * pole_reject * screen_mask, finalizing_params));

	//COLOR = vec4(unit_vector_check_one, unit_vector_check_two, unit_vector_check_one *  (-1.0), 1.0);
}
