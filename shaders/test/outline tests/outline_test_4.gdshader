shader_type canvas_item;

uniform float lod: hint_range(0.0, 5.0) = 1.0;
uniform vec2 offset = vec2(0.0);
uniform vec4 blur_color: source_color = vec4(1.0);

void fragment() {
	vec4 color = texture(TEXTURE, UV);
    vec4 blured_color = texture(TEXTURE, UV + (offset * TEXTURE_PIXEL_SIZE));
	//Since fully transparent pixels are treated as (0, 0, 0, 0) we have to do this workaround
	blured_color = vec4(blur_color.r, blur_color.g, blur_color.b, blur_color.a * blured_color.a);
	if(blured_color.a == 0.0)
	{
		blured_color = vec4(color.r, color.g, color.b, 0.0);
	}
	COLOR = mix(blured_color, color, color.a);
}