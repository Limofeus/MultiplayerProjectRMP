shader_type canvas_item;

uniform float grid_scale = 1.0;

//Maybe replace the hash function with MurmurHash later idk
vec2 random_vec2(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float sample_perlin2D(vec2 uv){
	
	vec2 grid_index = floor(uv);
	vec2 grid_fract = fract(uv);
	vec2 smooth_fract = smoothstep(0.0, 1.0, grid_fract);
	
	vec2 grid_tl = grid_index + vec2(0.0, 0.0);
	vec2 grid_bl = grid_index + vec2(0.0, 1.0);
	vec2 grid_tr = grid_index + vec2(1.0, 0.0);
	vec2 grid_br = grid_index + vec2(1.0, 1.0);
	
	vec2 grad_tl = random_vec2(grid_tl);
	vec2 grad_bl = random_vec2(grid_bl);
	vec2 grad_tr = random_vec2(grid_tr);
	vec2 grad_br = random_vec2(grid_br);
	
	vec2 dist_tl = grid_fract - vec2(0.0, 0.0);
	vec2 dist_bl = grid_fract - vec2(0.0, 1.0);
	vec2 dist_tr = grid_fract - vec2(1.0, 0.0);
	vec2 dist_br = grid_fract - vec2(1.0, 1.0);
	
	float dot_tl = dot(grad_tl, dist_tl);
	float dot_bl = dot(grad_bl, dist_bl);
	float dot_tr = dot(grad_tr, dist_tr);
	float dot_br = dot(grad_br, dist_br);
	
	return mix(mix(dot_tl, dot_tr, smooth_fract.x), mix(dot_bl, dot_br, smooth_fract.x), smooth_fract.y);
}

void fragment() {
	
	vec2 uv = UV * grid_scale;
	
	float sampled_noise = sample_perlin2D(uv) + 0.5;
	
	COLOR = vec4(sampled_noise, 0.0, 0.0, 1.0);
	
	if(sampled_noise >= 1.0){
		COLOR.y = 1.0;
	}
	
}