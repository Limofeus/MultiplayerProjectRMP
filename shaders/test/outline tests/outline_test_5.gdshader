shader_type canvas_item;

//Overlay A on top of B
//Based on straight alpha over operator formula from Wikipedia:
//https://en.wikipedia.org/wiki/Alpha_compositing
vec4 over(vec4 color_a, vec4 color_b){
	float inverse_base_alpha = 1.0 - color_a.a;
	float alpha_over = color_a.a + (color_b.a * inverse_base_alpha);

	vec4 color_over = (color_a * color_a.a) + (color_b * color_b.a * inverse_base_alpha);
	color_over /= alpha_over;

	color_over.a = alpha_over;

	return color_over;
}

void fragment() {
	vec4 baked_params = texture(TEXTURE, UV);
	vec4 test_ao = texture(TEXTURE, UV + (vec2(-5.0) * TEXTURE_PIXEL_SIZE));

	vec4 base_color = vec4(1.0, 1.0, 1.0, baked_params.x);
	vec4 underglow_color = vec4(0.0, 0.0, 0.0, test_ao.x);

	COLOR = over(base_color, underglow_color);
}