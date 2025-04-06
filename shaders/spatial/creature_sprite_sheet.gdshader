shader_type spatial;
render_mode blend_mix;

uniform vec4 base_color : source_color = vec4(1.0);
uniform float roughness = 1.0;

uniform sampler2D sprite_sheet;
uniform vec2 sprite_sheet_pos = vec2(0.0, 0.0);

uniform int sprite_sheet_rows = 1;
uniform int sprite_sheet_columns = 1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;

	vec2 column_row_vector = vec2(float(sprite_sheet_columns), float(sprite_sheet_rows));

	uv /= column_row_vector;

	uv += sprite_sheet_pos / column_row_vector;

	vec4 sampled_color = texture(sprite_sheet, uv);

	ROUGHNESS = roughness;
	ALBEDO = base_color.rgb;
	ALPHA = sampled_color.a;
	NORMAL_MAP = sampled_color.rgb;

	//EMISSION = vec3(0.0);
}