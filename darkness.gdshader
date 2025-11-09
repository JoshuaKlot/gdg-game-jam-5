shader_type canvas_item;

const vec2 screen_size = vec2(256., 192.);
uniform float size = 50.;
uniform vec2 pos = vec2(0.0, 0.0);
uniform vec2 lights[10];
uniform bool lights_on[10];

const float bayer[64] = float[](
	 0., 32.,  8., 40.,  2., 34., 10., 42.,
	48., 16., 56., 24., 50., 18., 58., 26.,
	12., 44.,  4., 36., 14., 46.,  6., 38.,
	60., 28., 52., 20., 62., 30., 54., 22.,
	 3., 35., 11., 43.,  1., 33.,  9., 41.,
	51., 19., 59., 27., 49., 17., 57., 25.,
	15., 47.,  7., 39., 13., 45.,  5., 37.,
	63., 31., 55., 23., 61., 29., 53., 21.
);

void fragment() {
	vec2 v = UV * screen_size;
	float d = distance(v, pos);
	if (d < size/2.) COLOR.a = 0.;
	else if (d < size/2.*1.5 && (1.5-d/(size/2.))*2. * 64. > bayer[int(v.x) % 8 + int(v.y) % 8 * 8]) COLOR.a = 0.;
	for (int i = 0; i < lights.length(); i++) {
		if (!lights_on[i]) continue;
		d = distance(v, lights[i]);
		if (d < size) COLOR.a = 0.;
		else if (d < size*1.5 && (1.5-d/size)*2. * 64. > bayer[int(v.x) % 8 + int(v.y) % 8 * 8]) COLOR.a = 0.;
	}
}