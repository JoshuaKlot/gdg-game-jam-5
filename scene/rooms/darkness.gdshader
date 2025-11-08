shader_type canvas_item;

const vec2 screen_size = vec2(256., 192.);
uniform float size = 50.;
uniform vec2 pos = vec2(0.0, 0.0);
uniform vec2 pos2 = vec2(-1.0, -1.0);
uniform int mode = 0;

void fragment() {
	switch (mode) {
		case 0: // circle
			if (pos2 == vec2(-1.0, -1.0)) {
				if (distance(UV * screen_size, pos) < size/2.) COLOR.a = 0.;
				vec2 v = UV * screen_size;
				if (int(v.x + v.y) % 2 == 0 && distance(UV * screen_size, pos) < size/2.*1.5) COLOR.a = 0.;
			} else {
				if (distance(UV * screen_size, pos) < size/2. || distance(UV * screen_size, pos2) < size) COLOR.a = 0.;
				vec2 v = UV * screen_size;
				if (int(v.x + v.y) % 2 == 0 && (distance(UV * screen_size, pos) < size/2.*1.5 || distance(UV * screen_size, pos2) < size*1.5)) COLOR.a = 0.;
			}
			break;
		case 1: // open/close horizontal
			if (abs(UV.x * screen_size.x - pos.x - 5.*sin(UV.y * screen_size.y/5.)) - 5. < size) COLOR.a = 0.;
			break;
		case 2: // open/close vertical
			if (abs(UV.y * screen_size.y - pos.y) < size) COLOR.a = 0.;
			break;
		case 3: // eye
			//if (distance(UV * screen_size, pos) < size) COLOR.a = 0.;
			vec2 shifted = UV - vec2(.5, .5);
			if (shifted.x*shifted.x + 1./size/size * shifted.y*shifted.y < .5) COLOR.a = 0.;
			break;
	}
}