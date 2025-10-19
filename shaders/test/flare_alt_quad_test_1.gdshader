shader_type spatial;
render_mode unshaded, fog_disabled, blend_add;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float flare_threshold = 0.65;
uniform float flare_margin = 0.2;
uniform float uv_feather = 0.4;
uniform float global_flare_power = 0.2;

uniform float uv_mipmap_bias = 0.25;
uniform float flat_uv_bias = 0.0;
uniform float fisheye_power = 0.0;

uniform float cascade_1_scale = 1.25;
uniform float cascade_2_scale = 0.45;
uniform float cascade_3_scale = 0.2;
uniform float cascade_4_scale = -0.66;
uniform float cascade_5_scale = -1.5;

uniform float cascade_1_power = 0.03;
uniform float cascade_2_power = 0.07;
uniform float cascade_3_power = 0.06;
uniform float cascade_4_power = 0.02;
uniform float cascade_5_power = 0.04;


vec2 centered_scale_uv(vec2 input_uv, vec2 scale){
	vec2 uv = input_uv - vec2(0.5, 0.5);
	uv /= scale;
	uv += vec2(0.5, 0.5);
	return uv;
}

vec3 sample_flare_cascade(vec2 sam_uv, float mipmap_bias){

	vec2 uv = sam_uv;
	vec2 outrward_vector = uv - vec2(0.5, 0.5);
	vec2 fisheye_vector = normalize(outrward_vector) * tan(length(outrward_vector) * fisheye_power);

	uv += fisheye_vector;


	vec3 screen_color = texture(screen_texture, uv, mipmap_bias).rgb;
	float screen_gray_scale = (0.299 * screen_color.r) + (0.587 * screen_color.g) + (0.114 * screen_color.b);
	float flare_power = smoothstep(flare_threshold, flare_threshold + flare_margin, screen_gray_scale);
	vec2 uv_feather_test = abs((uv - vec2(0.5)) * 2.0);
	float uv_feather_factor = 1.0 - smoothstep(1.0 - uv_feather, 1.0, max(uv_feather_test.x, uv_feather_test.y));
	return flare_power * screen_color * uv_feather_factor;
}

vec3 sample_flare_cascade_at_scale(vec2 uv, float cascade_scale, float cascade_power){
	return cascade_power * sample_flare_cascade(centered_scale_uv(uv, vec2(cascade_scale)), flat_uv_bias + (uv_mipmap_bias * (1.0 / abs(cascade_scale))));
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment(){
	vec2 sample_uv = SCREEN_UV;
	vec3 flare_color = vec3(0.0);

	flare_color += sample_flare_cascade_at_scale(sample_uv, cascade_1_scale, cascade_1_power);
	flare_color += sample_flare_cascade_at_scale(sample_uv, cascade_2_scale, cascade_2_power);
	flare_color += sample_flare_cascade_at_scale(sample_uv, cascade_3_scale, cascade_3_power);
	flare_color += sample_flare_cascade_at_scale(sample_uv, cascade_4_scale, cascade_4_power);
	flare_color += sample_flare_cascade_at_scale(sample_uv, cascade_5_scale, cascade_5_power);

	
	ALBEDO = flare_color * global_flare_power;
}