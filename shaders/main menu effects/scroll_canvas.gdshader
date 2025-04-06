shader_type canvas_item;

uniform vec2 scroll_speed = vec2(1.0);


void fragment(){
	vec2 uv = UV + (TIME * scroll_speed);
	COLOR = texture(TEXTURE, uv);
}
