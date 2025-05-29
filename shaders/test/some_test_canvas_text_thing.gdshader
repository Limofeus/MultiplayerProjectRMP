shader_type canvas_item;

void vertex() {
	
}

void fragment() {
	COLOR.g = COLOR.a;
	COLOR.a = 1.0;
}