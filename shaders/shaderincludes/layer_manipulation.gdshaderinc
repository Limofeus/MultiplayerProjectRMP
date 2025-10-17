vec4 over(vec4 color_a, vec4 color_b){
	float inverse_base_alpha = 1.0 - color_a.a;
	float alpha_over = color_a.a + (color_b.a * inverse_base_alpha);
	
	vec4 color_over = (color_a * color_a.a) + (color_b * color_b.a * inverse_base_alpha);
	color_over /= alpha_over;
	
	color_over.a = alpha_over;
	
	return color_over;
}