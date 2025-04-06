shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;

void fragment(){
	vec4 color = texture(screen_texture, SCREEN_UV);
	COLOR = COLOR - color;
	COLOR.a = 1.0;
}
