shader_type canvas_item;

uniform float pixel_size = 1.0;
uniform float dither_power = 1.0;
uniform vec2 dither_scroll_speed = vec2(1.0);
uniform vec2 dither_tex_size = vec2(1.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform sampler2D dither_texture : repeat_enable, filter_nearest;

vec2 pixelate_uv(vec2 uv, vec2 sps, float pixelation_size){
	vec2 n_uv = uv;
	n_uv /= sps;
	n_uv /= pixelation_size;
	n_uv = floor(n_uv);
	n_uv *= pixel_size;
	n_uv *= sps;
	return n_uv;
}

void fragment(){
	float alpha_save = COLOR.a;
	vec2 uv = SCREEN_UV;
	vec4 base = texture(screen_texture, pixelate_uv(uv, SCREEN_PIXEL_SIZE, pixel_size));
	vec2 noise_uv = uv / (SCREEN_PIXEL_SIZE * dither_tex_size);
	noise_uv += floor(dither_scroll_speed * TIME) * pixel_size / dither_tex_size;
	noise_uv /= pixel_size;
	vec4 noise = texture(dither_texture, noise_uv);
	COLOR = round(base + (dither_power * (noise -0.5)));
	COLOR.a = alpha_save;
	//COLOR = noise;
}
