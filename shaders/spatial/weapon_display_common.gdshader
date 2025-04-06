shader_type spatial;

uniform vec3 main_color : source_color = vec3(1.0);
uniform vec3 fresnel_color : source_color = vec3(0.0);
uniform float fresnel_amount = 1.0;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
	ALBEDO = main_color + (fresnel(fresnel_amount, NORMAL, VIEW) * fresnel_color);
}