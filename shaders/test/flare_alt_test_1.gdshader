shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float flare_threshold = 0.95;
uniform float flare_margin = 0.05;

vec2 centered_scale_uv(vec2 input_uv, vec2 scale){
	vec2 uv = input_uv - vec2(0.5, 0.5);
	uv /= scale;
	uv += vec2(0.5, 0.5);
	return uv;
}

void fragment(){
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	float screen_gray_scale = (0.299 * screen_color.r) + (0.587 * screen_color.g) + (0.114 * screen_color.b);
	float flare_power = smoothstep(flare_threshold, flare_threshold + flare_margin, screen_gray_scale);
	COLOR = vec4(screen_color);
	if(screen_gray_scale > flare_threshold){
		COLOR = mix(COLOR, vec4(1.0, 0.0, 0.0, 1.0), flare_power);
	}
	if(screen_gray_scale >= 1.0){
		COLOR = vec4(0.0, 1.0, 0.0, 1.0);
	}
}