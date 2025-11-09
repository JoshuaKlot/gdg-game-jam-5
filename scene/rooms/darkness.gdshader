shader_type canvas_item;

const vec2 screen_size = vec2(256., 192.);
uniform float size = 50.;
uniform vec2 pos = vec2(0.0, 0.0);
uniform vec2 lights[10];
uniform bool lights_on[10];

void fragment() {
	vec2 v = UV * screen_size;
	if (distance(UV * screen_size, pos) < size/2.) COLOR.a = 0.;
	if (int(v.x + v.y) % 2 == 0 && distance(UV * screen_size, pos) < size/2.*1.5) COLOR.a = 0.;
	for (int i = 0; i < lights.length(); i++) {
		if (!lights_on[i]) continue;
		if (distance(UV * screen_size, lights[i]) < size) COLOR.a = 0.;
		if (int(v.x + v.y) % 2 == 0 && distance(UV * screen_size, lights[i]) < size*1.5) COLOR.a = 0.;
	}
}