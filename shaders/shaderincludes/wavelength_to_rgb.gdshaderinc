//SHIT ASS GOVNO NE ISPOLZOVAT, UDALI POTOM POZHALUSTA (Щит асс говно, удали потом пожалуйста)
//UMALYAU, SDELAI SCREENSHOT, SDELAI CHTO UGODNO, NO UDALI PEJE (Умоляю, сделай скриншот, сделай что угодно, но удали пж)
const float ZERO_ONE_SAMPLE_WAVELENGTH_MIN = 350.0;
const float ZERO_ONE_SAMPLE_WAVELENGTH_MAX = 750.0;

float gamma_correct_wavelength_value(float value){
	float result = 0.0;
	if(value <= 0.0031308){
		result = value * 12.92;
	}
	else if(value <= 1.0){
		result = (1.055 * pow(value, 0.41666666666)) - 0.055;
	}
	else{
		result = 1.0;
	}
	return result;
}

vec3 wavelength_to_rgb(float lambda){
	float xt_one = (lambda - 442.0) * (lambda < 442.0 ? 0.0624 : 0.0374);
	float xt_two = (lambda - 599.8) * (lambda < 599.8 ? 0.0264 : 0.0323);
	float xt_three = (lambda - 501.1) * (lambda < 501.1 ? 0.0490 : 0.0382);
	
	float x = (0.362 * exp(-0.5 * xt_one * xt_one)) + (1.056 * exp(-0.5 * xt_two * xt_two)) - (0.065 * exp(-0.5 * xt_three * xt_three));
	
	float yt_one = (lambda - 568.8) * (lambda < 568.8 ? 0.0213 : 0.0247);
	float yt_two = (lambda - 530.9) * (lambda < 530.9 ? 0.0613 : 0.0322);
	
	float y = (0.821 * exp(-0.5 * yt_one * yt_one)) + (0.286 * exp(-0.5 * yt_two * yt_two));
	
	float zt_one = (lambda - 437.0) * (lambda < 437.0 ? 0.0845 : 0.0278);
	float zt_two = (lambda - 459.0) * (lambda < 459.0 ? 0.0385 : 0.0725);
	
	float z = (1.217 * exp(-0.5 * zt_one * zt_one)) + (0.681 * exp(-0.5 * zt_two * zt_two));
	
	float r = 3.2406255 * x - 1.537208 * y - 0.4986286 * z;
	float g = -0.9689307 * x + 1.8757561 * y + 0.0415175 * z;
	float b = 0.0557101 * x - 0.2040211 * y + 1.0569959 * z;
	
	float corrected_r = gamma_correct_wavelength_value(r);
	float corrected_g = gamma_correct_wavelength_value(g);
	float corrected_b = gamma_correct_wavelength_value(b);
	
	vec3 rgb_color = vec3(corrected_r, corrected_g, corrected_b);
	return rgb_color;
}

vec3 sample_wavelength_rgb_zero_one(float factor){
	return(wavelength_to_rgb(mix(ZERO_ONE_SAMPLE_WAVELENGTH_MIN, ZERO_ONE_SAMPLE_WAVELENGTH_MAX, factor)));
}