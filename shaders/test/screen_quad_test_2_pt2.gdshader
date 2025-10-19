shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float threshold = 0.5;
uniform float threshold_feather = 0.01;
uniform bool invert_result = false;

void fragment() {
	vec3 screen_color = texture(screen_texture, SCREEN_UV).rgb;
	float screen_avg = (screen_color.r + screen_color.g + screen_color.b) / 3.0;
	
	float result = smoothstep(threshold, threshold + threshold_feather, screen_avg);
	
	if(invert_result) result = 1.0 - result;
	
	COLOR = vec4(result, result, result, 1.0);
}
