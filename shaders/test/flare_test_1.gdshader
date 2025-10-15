shader_type canvas_item;
render_mode blend_add;

uniform sampler2D flare_texture : filter_linear_mipmap;
uniform float fisheye_power = 1.0;
uniform float scale_test = 1.0;
uniform vec2 offset_test = vec2(0.0, 0.0);
uniform float scale_test_2 = 1.0;


vec2 centered_scale_uv(vec2 input_uv, vec2 scale){
	vec2 uv = input_uv - vec2(0.5, 0.5);
	uv /= scale;
	uv += vec2(0.5, 0.5);
	return uv;
}

void fragment() {
	float aspect_ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	//vec2 uv = centered_scale_uv(SCREEN_UV, vec2(1.0 / aspect_ratio, 1.0)); //vertical
	vec2 uv_max = centered_scale_uv(SCREEN_UV, vec2(max(aspect_ratio, 1.0), max(1.0 / aspect_ratio, 1.0)));
	vec2 uv_min = centered_scale_uv(SCREEN_UV, vec2(min(aspect_ratio, 1.0), min(1.0 / aspect_ratio, 1.0)));
	vec2 uv_ratio = uv_max / uv_min;
	vec2 uv = uv_min;
	
	vec2 outrward_vector = uv_max - vec2(0.5, 0.5);
	vec2 fisheye_vector = normalize(outrward_vector) * tan(length(outrward_vector) * fisheye_power);
	
	uv += fisheye_vector;
	uv = centered_scale_uv(uv, vec2(scale_test,scale_test));
	uv -= offset_test;
	uv = centered_scale_uv(uv, vec2(scale_test_2, scale_test_2));
	
	
	COLOR = texture(flare_texture, uv);
	//COLOR = vec4(abs(fisheye_vector.x), abs(fisheye_vector.y), 0.0, 1.0);
}