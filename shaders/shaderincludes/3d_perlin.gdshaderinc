//Maybe replace the hash function with MurmurHash later idk
vec3 random_vec3(vec3 uvw){
    uvw = vec3( dot(uvw, vec3(127.1,311.7, 513.7) ),
               dot(uvw, vec3(269.5,183.3, 396.5) ),
			   dot(uvw, vec3(421.3,314.1, 119.7) ) );
			
    return -1.0 + 2.0 * fract(sin(uvw) * 43758.5453123);
}

float sample_perlin3D(vec3 uvw){
	
	//Third component: f - forward (out of the screen), b - backward - in to the screen
	
	vec3 grid_index = floor(uvw);
	vec3 grid_fract = fract(uvw);
	vec3 smooth_fract = smoothstep(0.0, 1.0, grid_fract);
	
	vec3 grid_tlb = grid_index + vec3(0.0, 0.0, 0.0);
	vec3 grid_blb = grid_index + vec3(0.0, 1.0, 0.0);
	vec3 grid_trb = grid_index + vec3(1.0, 0.0, 0.0);
	vec3 grid_brb = grid_index + vec3(1.0, 1.0, 0.0);
	vec3 grid_tlf = grid_index + vec3(0.0, 0.0, 1.0);
	vec3 grid_blf = grid_index + vec3(0.0, 1.0, 1.0);
	vec3 grid_trf = grid_index + vec3(1.0, 0.0, 1.0);
	vec3 grid_brf = grid_index + vec3(1.0, 1.0, 1.0);
	
	vec3 grad_tlb = random_vec3(grid_tlb);
	vec3 grad_blb = random_vec3(grid_blb);
	vec3 grad_trb = random_vec3(grid_trb);
	vec3 grad_brb = random_vec3(grid_brb);
	vec3 grad_tlf = random_vec3(grid_tlf);
	vec3 grad_blf = random_vec3(grid_blf);
	vec3 grad_trf = random_vec3(grid_trf);
	vec3 grad_brf = random_vec3(grid_brf);
	
	vec3 dist_tlb = grid_fract - vec3(0.0, 0.0, 0.0);
	vec3 dist_blb = grid_fract - vec3(0.0, 1.0, 0.0);
	vec3 dist_trb = grid_fract - vec3(1.0, 0.0, 0.0);
	vec3 dist_brb = grid_fract - vec3(1.0, 1.0, 0.0);
	vec3 dist_tlf = grid_fract - vec3(0.0, 0.0, 1.0);
	vec3 dist_blf = grid_fract - vec3(0.0, 1.0, 1.0);
	vec3 dist_trf = grid_fract - vec3(1.0, 0.0, 1.0);
	vec3 dist_brf = grid_fract - vec3(1.0, 1.0, 1.0);
	
	
	float dot_tlb = dot(grad_tlb, dist_tlb);
	float dot_blb = dot(grad_blb, dist_blb);
	float dot_trb = dot(grad_trb, dist_trb);
	float dot_brb = dot(grad_brb, dist_brb);
	float dot_tlf = dot(grad_tlf, dist_tlf);
	float dot_blf = dot(grad_blf, dist_blf);
	float dot_trf = dot(grad_trf, dist_trf);
	float dot_brf = dot(grad_brf, dist_brf);
	
	float b_mixed = mix(mix(dot_tlb, dot_trb, smooth_fract.x), mix(dot_blb, dot_brb, smooth_fract.x), smooth_fract.y);
	float f_mixed = mix(mix(dot_tlf, dot_trf, smooth_fract.x), mix(dot_blf, dot_brf, smooth_fract.x), smooth_fract.y);

	return mix(b_mixed, f_mixed, smooth_fract.z);
}

float sample_repeating_perlin3D(vec3 uvw, vec3 repeat){
	
	//Third component: f - forward (out of the screen), b - backward - in to the screen
	
	vec3 grid_index = floor(uvw);
	vec3 grid_fract = fract(uvw);
	vec3 smooth_fract = smoothstep(0.0, 1.0, grid_fract);
	
	vec3 grid_tlb = grid_index + vec3(0.0, 0.0, 0.0);
	grid_tlb = mod(grid_tlb, repeat);
	vec3 grid_blb = grid_index + vec3(0.0, 1.0, 0.0);
	grid_blb = mod(grid_blb, repeat);
	vec3 grid_trb = grid_index + vec3(1.0, 0.0, 0.0);
	grid_trb = mod(grid_trb, repeat);
	vec3 grid_brb = grid_index + vec3(1.0, 1.0, 0.0);
	grid_brb = mod(grid_brb, repeat);
	vec3 grid_tlf = grid_index + vec3(0.0, 0.0, 1.0);
	grid_tlf = mod(grid_tlf, repeat);
	vec3 grid_blf = grid_index + vec3(0.0, 1.0, 1.0);
	grid_blf = mod(grid_blf, repeat);
	vec3 grid_trf = grid_index + vec3(1.0, 0.0, 1.0);
	grid_trf = mod(grid_trf, repeat);
	vec3 grid_brf = grid_index + vec3(1.0, 1.0, 1.0);
	grid_brf = mod(grid_brf, repeat);
	
	vec3 grad_tlb = random_vec3(grid_tlb);
	vec3 grad_blb = random_vec3(grid_blb);
	vec3 grad_trb = random_vec3(grid_trb);
	vec3 grad_brb = random_vec3(grid_brb);
	vec3 grad_tlf = random_vec3(grid_tlf);
	vec3 grad_blf = random_vec3(grid_blf);
	vec3 grad_trf = random_vec3(grid_trf);
	vec3 grad_brf = random_vec3(grid_brf);
	
	vec3 dist_tlb = grid_fract - vec3(0.0, 0.0, 0.0);
	vec3 dist_blb = grid_fract - vec3(0.0, 1.0, 0.0);
	vec3 dist_trb = grid_fract - vec3(1.0, 0.0, 0.0);
	vec3 dist_brb = grid_fract - vec3(1.0, 1.0, 0.0);
	vec3 dist_tlf = grid_fract - vec3(0.0, 0.0, 1.0);
	vec3 dist_blf = grid_fract - vec3(0.0, 1.0, 1.0);
	vec3 dist_trf = grid_fract - vec3(1.0, 0.0, 1.0);
	vec3 dist_brf = grid_fract - vec3(1.0, 1.0, 1.0);
	
	
	float dot_tlb = dot(grad_tlb, dist_tlb);
	float dot_blb = dot(grad_blb, dist_blb);
	float dot_trb = dot(grad_trb, dist_trb);
	float dot_brb = dot(grad_brb, dist_brb);
	float dot_tlf = dot(grad_tlf, dist_tlf);
	float dot_blf = dot(grad_blf, dist_blf);
	float dot_trf = dot(grad_trf, dist_trf);
	float dot_brf = dot(grad_brf, dist_brf);
	
	float b_mixed = mix(mix(dot_tlb, dot_trb, smooth_fract.x), mix(dot_blb, dot_brb, smooth_fract.x), smooth_fract.y);
	float f_mixed = mix(mix(dot_tlf, dot_trf, smooth_fract.x), mix(dot_blf, dot_brf, smooth_fract.x), smooth_fract.y);

	return mix(b_mixed, f_mixed, smooth_fract.z);
}