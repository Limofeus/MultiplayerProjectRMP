shader_type sky;

group_uniforms Sky;
uniform sampler2D stars_panorama_map : source_color, repeat_disable, filter_linear_mipmap_anisotropic;
uniform samplerCube stars_cube_map : source_color, repeat_disable, filter_linear_mipmap_anisotropic;
uniform float stars_texture_lod = 0.0;
group_uniforms Rainbow;
uniform sampler2D rainbow_gradient : source_color, repeat_disable;
uniform float angle_degrees_start = 40.0;
uniform float angle_degrees_end = 43.0;
uniform float rainbow_exposure = 1.0;
uniform sampler2D time_to_exposure;
group_uniforms SkyGradients;
/** The gradient texture that is sampled using the Sun-Zenith angle */
uniform sampler2D sun_zenith_gradient : source_color, repeat_disable;
/** The gradient texture that is sampled using the View-Zenith angle */
uniform sampler2D view_zenith_gradient : source_color, repeat_disable;
/** The gradient texture that is sampled using the Sun-View angle */
uniform sampler2D sun_view_gradient : source_color, repeat_disable;
group_uniforms Sun;
uniform float sun_radius : hint_range(0, 1) = 0.04;
uniform float sun_feather = 0.01;
uniform vec3 sun_color : source_color = vec3(1.0, 1.0, 1.0);
group_uniforms Ground;
uniform vec4 ground_color : source_color = vec4(0.2, 0.169, 0.133, 1.0);
uniform float ground_curve : hint_range(0, 1) = 0.02;
group_uniforms Moons;
uniform float moon_1_radius : hint_range(0, 1) = 0.05;
uniform float moon_1_feather = 0.01;
uniform float moon_1_feather_bias = 0.01;
uniform float moon_1_exposure : hint_range(-16, 16) = 0;
uniform vec3 moon_1_color : source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D moon_1_sampler : source_color, repeat_enable;
uniform float moon_1_texture_lod = 0.0;
uniform float moon_2_radius : hint_range(0, 1) = 0.05;
uniform float moon_2_feather = 0.01;
uniform float moon_2_feather_bias = 0.01;
uniform float moon_2_exposure : hint_range(-16, 16) = 0;
uniform vec3 moon_2_color : source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D moon_2_sampler : source_color, repeat_enable;
uniform float moon_2_texture_lod = 0.0;

group_uniforms Directions;
uniform vec3 sun_dir;
uniform vec3 moon_1_dir;
uniform vec3 moon_2_dir;

float get_sun_mask(float sun_view_dot, float radius)
{
    float step_radius = 1.0 - radius * radius;
    return smoothstep(step_radius, step_radius + (sun_feather * 0.01), sun_view_dot);
}

float feather_mask(float view_dot, float radius, float feather, float feather_bias)
{
    float step_radius = 1.0 - radius * radius;
    return smoothstep(step_radius, step_radius + (feather * 0.01), view_dot - (feather_bias * 0.01));
}

float sphere_intersect(vec3 ray_dir, vec3 sphere_pos, float radius)
{
    vec3 oc = -sphere_pos;
    float b = dot(oc, ray_dir);
    float c = dot(oc, oc) - radius * radius;
    float h = b * b - c;
    if(h < 0.0) return -1.0;
    h = sqrt(h);
    return -b - h;
}

vec2 sample_sphere_uv(vec3 sphere_unit_vector){
	//Wikipedia formula (Spherical mapping)
	float u = 0.5 + (atan(sphere_unit_vector.x, sphere_unit_vector.y) / (2.0 * PI));
	float v = 0.5 + (asin(sphere_unit_vector.z)/PI);
	return vec2(u, v);
}

vec3 sample_moon_texture(sampler2D sampler, vec3 moon_dir, float texture_lod){
	return textureLod(sampler, sample_sphere_uv(normalize(moon_dir.xzy)), texture_lod).rgb;
}

float get_moon_feather_mask(vec3 view_dir, vec3 moon_dir, float moon_radius, float moon_feather, float moon_feather_bias){
	float moon_feathered_mask = feather_mask(dot(moon_dir, view_dir), moon_radius, moon_feather, moon_feather_bias);
	return moon_feathered_mask;
}

vec3 get_moon(vec3 view_dir, vec3 moon_dir, float moon_radius, float moon_exposure, vec3 moon_color, sampler2D moon_sampler, float moon_texture_lod) {
	float moon_intersect = sphere_intersect(view_dir, moon_dir, moon_radius);
	float moon_mask = moon_intersect > -1.0 ? 1.0 : 0.0;
	vec3 moon_normal = normalize(view_dir * moon_intersect - moon_dir);
	float moon_ndotl = clamp(dot(moon_normal, sun_dir), 0.0, 1.0);
	float moon_view_dot = dot(moon_dir, view_dir);
	vec3 moon_output = moon_mask * moon_ndotl * exp2(moon_exposure) * moon_color * sample_moon_texture(moon_sampler, moon_normal, moon_texture_lod);
	return moon_output;
}

vec3 subtract_mask(vec3 input_color, float mask){
	return input_color * max(1.0 - mask, 0.0);
}

void sky() {
	vec3 view_dir = EYEDIR;

	float sun_view_dot = dot(sun_dir, view_dir);
	float sun_zenith_dot = sun_dir.y;
	float view_zenith_dot = view_dir.y;
	float sun_moon_1_dot = dot(sun_dir, moon_1_dir);
	float sun_moon_2_dot = dot(sun_dir, moon_2_dir);

	float sun_view_dot01 = (sun_view_dot + 1.0) * 0.5;
	float sun_zenith_dot01 = (sun_zenith_dot + 1.0) * 0.5;

	vec3 sun_zenith_color = texture(sun_zenith_gradient, vec2(sun_zenith_dot01, 0.5)).rgb;

	vec3 view_zenith_color = texture(view_zenith_gradient, vec2(sun_zenith_dot01, 0.5)).rgb;
	float vz_mask = pow(clamp(1.0 - view_zenith_dot, 0.0, 1.0), 4);

	vec3 sun_view_color = texture(sun_view_gradient, vec2(sun_zenith_dot01, 0.5)).rgb;
	float sv_mask = pow(clamp(sun_view_dot, 0.0, 1.0), 4);


	vec3 sky_output = sun_zenith_color + vz_mask * view_zenith_color + sv_mask * sun_view_color;

	//Sun
	float sun_mask = get_sun_mask(sun_view_dot, sun_radius);
	vec3 sun_output = sun_color * sun_mask;

	//Moon
	float moon_1_feathered_mask = get_moon_feather_mask(view_dir, moon_1_dir, moon_1_radius, moon_1_feather, moon_1_feather_bias);
	vec3 moon_1_output = get_moon(view_dir, moon_1_dir, moon_1_radius, moon_1_exposure, moon_1_color, moon_1_sampler, moon_1_texture_lod) * moon_1_feathered_mask;
	float moon_2_feathered_mask = get_moon_feather_mask(view_dir, moon_2_dir, moon_2_radius, moon_2_feather, moon_2_feather_bias);
	vec3 moon_2_output = get_moon(view_dir, moon_2_dir, moon_2_radius, moon_2_exposure, moon_2_color, moon_2_sampler, moon_2_texture_lod) * moon_2_feathered_mask * (1.0 - moon_1_feathered_mask);

	vec3 stars_output = textureLod(stars_panorama_map, SKY_COORDS, stars_texture_lod).rgb;
	vec3 stars_test = subtract_mask(texture(stars_cube_map, view_dir, -0.3).rgb, moon_1_feathered_mask + moon_2_feathered_mask);

	float rainbow_top_pos = angle_degrees_end / 180.0;
	float rainbow_bottom_pos = angle_degrees_start / 180.0;
	float rainbow_sky_coef = (sun_view_dot + 1.0) / 2.0;
	float rainbow_pos = (rainbow_sky_coef - rainbow_bottom_pos) / (rainbow_top_pos - rainbow_bottom_pos);
	rainbow_pos = clamp(rainbow_pos, 0.0, 1.0);
	vec3 rainbow_test =  texture(rainbow_gradient, vec2(rainbow_pos, 0.5)).rgb * rainbow_exposure;
	rainbow_test = rainbow_test * texture(time_to_exposure, vec2(sun_zenith_dot01, 0.5)).rgb;

	vec3 output = sky_output + sun_output + moon_1_output + moon_2_output + rainbow_test;// + stars_test;
	//output = stars_test;

	//Ground mix
	float v_angle = acos(clamp(EYEDIR.y, -1.0, 1.0));
	float c = (v_angle - (PI * 0.5)) / (PI * 0.5);
	output = mix(output, ground_color.rgb, clamp(1.0 - pow(1.0 - c, 1.0 / ground_curve), 0.0, 1.0));

	COLOR = output;
}