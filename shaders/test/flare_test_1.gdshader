shader_type canvas_item;
#include "res://shaders/shaderincludes/wavelength_to_rgb.gdshaderinc"

uniform float min_wavelength;
uniform float max_wavelength;



void fragment() {
	float wavelen = min_wavelength + (UV.x * (max_wavelength - min_wavelength));
	vec3 wavelength_color = wavelength_to_rgb(wavelen);
	wavelength_color = sample_wavelength_rgb_zero_one(UV.x);
	COLOR = vec4(wavelength_color.r, wavelength_color.g, wavelength_color.b, 1.0);
}