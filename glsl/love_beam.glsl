// https://qiita.com/kaneta1992/items/21149c78159bd27e0860

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

// 回転行列
mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

float sdEllipsoid( in vec3 p, in vec3 r )
{
	float k0 = length(p/r);
	float k1 = length(p/(r*r));
	return k0*(k0-1.0)/k1;
}

float steel(vec3 pos) {
	vec3 pos_origin  = pos;
	pos.x = pos.x - 0.3;
	pos.xy = pos.xy * rot(1.) ;
	float side1 = sdEllipsoid(pos, vec3(1.,.7,1.));
	pos = pos_origin;
	pos.x =  pos.x + 0.3;
	pos.xy = pos.xy * rot(-1.);
	float side2 =sdEllipsoid(pos, vec3(1.,.7,1.));
	
	return min(side1,side2)/ .3;
}

void main( void ) {
	vec2 p = (gl_FragCoord.xy * 2. - resolution.xy) / min(resolution.x, resolution.y);
	vec3 ro = vec3(0., 0. , 0. + time * 8.);
	vec3 ray = normalize(vec3(p, 2.5));
        ray.xy = ray.xy * rot(sin(time * .5) * .1);
        ray.yz = ray.yz * rot(sin(time * .5) * .1);
	float t = 5.;
	vec3 col = vec3(0.);
	float ac = 0.0;

	for (int i = 0; i < 180; i++){
		vec3 pos = ro + ray * t;
		pos = mod(pos-2., 4.) -2.;
		float d = steel(pos);

		d = max(abs(d), 0.2);
		ac += exp(-d*3.);

		t += d* 0.1;
	}
	col = vec3(ac * 0.01);
        col.x += col.x * abs(sin(time * 0.1)) * 2.7 + 0.2;
        col.y +=  0.2;
        col.z += col.z * sin(time * 0.1) * 0.4 + 0.4;
	gl_FragColor = vec4(col ,1.0);
}
