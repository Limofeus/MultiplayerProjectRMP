shader_type spatial;
render_mode unshaded;

uniform vec3 color : source_color = vec3(1.0);

void vertex() {
}

void fragment() {
	ALBEDO = color;
}
