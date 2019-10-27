// https://neort.io/createfromglsl/bmqr5a43p9f7m1g02kmg
precision highp float;

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
uniform sampler2D backbuffer;


// 回転行列
mat2 rot(float a) {
	float c = cos(a), s = sin(a);
	return mat2(c,s,-s,c);
}

// 円周率
const float pi = acos(-1.0);
const float pi2 = pi*2.;


float sdEllipsoid( in vec3 p, in vec3 r )
{
	float k0 = length(p/r);
	float k1 = length(p/(r*r));
	return k0*(k0-1.0)/k1;
}

float sdBox( vec3 p, vec3 b )
{
	vec3 q = abs(p) - b;
	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sakura(vec3 pos, float scale) {
	pos *= scale;
	float base = sdEllipsoid(pos, vec3(.4,.6,.2)) /1.5;
	pos.xy *= 5.;
	//pos.yz *= rot(.);
	pos.y -= 3.5;
	pos.xy *= rot(.75);
	float cut = sdBox(pos  , vec3(1.,1.,1.));
	float result = min(-base,cut) *2.;
	return result;
}

float sakura_set(vec3 pos) {
	vec3 pos_origin = pos;
	pos = pos_origin;
	pos .y -= .1;
	float sakura1 = sakura(pos,2.);
	pos = pos_origin;
	pos .x += .35;
	pos .y += .15;
	pos.xy *=   rot(.9);
	float sakura2 = sakura(pos,2.);
	pos = pos_origin;
	pos .x -= .35;
	pos .y += .15;
	pos.xy *=   rot(-.9);
	float sakura3 = sakura(pos,2.);	
	pos = pos_origin;
	pos .x += .225;
	pos .y += .6;
	pos.xy *=   rot(2.5);
	float sakura4 = sakura(pos,2.);	
	pos = pos_origin;
	pos .x -= .225;
	pos .y += .6;
	pos.xy *=   rot(-2.5);
	float sakura5 = sakura(pos,2.);	
	float result = max(max(max(max(sakura1,sakura2),sakura3),sakura4),sakura5);
	return result;
}

float map(vec3 pos) {
	vec3 pos_origin = pos;
	float sakura_set1 = sakura_set(pos);
	pos.x +=sin(time);
	pos.y +=sin(time);
	pos.z +=sin(time);
    pos.yz *= rot(sin(time * 2.));
	pos *= 1.5;
	float sakura_set2 = sakura_set(pos);
	pos = pos_origin;
	pos.x -=sin(time);
	pos.y -=sin(time);
	pos.z -=sin(time);
    pos.yz *= rot(sin(time * 2.));
	pos *= 1.5;
	float sakura_set3 = sakura_set(pos);
	pos = pos_origin;
	pos.x +=sin(time * 0.25);
	pos.y +=sin(time * 0.25);
	pos.z +=sin(time);
	pos.yz *= rot(sin(time));
	pos *= 1.5;
	float sakura_set4 = sakura_set(pos);
	pos = pos_origin;
	pos.x -=sin(time * 0.25);
	pos.y -=sin(time * 0.25);
	pos.z -=sin(time);
	pos.yz *= rot(sin(time));
	pos *= 1.5;
	float sakura_set5 = sakura_set(pos);
	
	//float result = sakura_set1;
	float result = max(max(max(max(sakura_set1,sakura_set2),sakura_set3),sakura_set4), sakura_set5);
	//float result = min(sakura1,sakura2);
	//float result = sakura2;

	return result;
}


void main( void ) {
	vec2 p = (gl_FragCoord.xy * 2. - resolution.xy) / min(resolution.x, resolution.y);
	vec3 ro = vec3(0.5, sin(time) * 2.  + 0.3 ,time * 2.);
	vec3 ray = normalize(vec3(p, 1.5));

	float t = 0.01;
	vec3 col = vec3(0.);
	float ac = 0.0;

	//p = p * rot(time);
	ro.xy  =ro.xy * rot(time/ 5.) * .1;
	ro.yz  =ro.yz * rot(time/ 5.) * 0.005;

	for (int i = 0; i < 99; i++){
		vec3 pos = ro + ray * t;
		pos = mod(pos-2., 4.) -2.;
		//float d = length(pos) - 0.5;
		pos.xy = pos.xy  * rot(time);
		//pos.x += sin(time);
		pos.yz = pos.yz  * rot(sin(time) /2.);
		//float d = sdMvBox(pos, 0.8);
		//pos.xy = pos.xy  * rot(time);

		float d = map(pos);


		// オブジェクト透過処理
		// 最短距離の絶対値を取り、進む距離が絶対に0にならないようにする。
		// 今回だとmaxで0.02以下にならないようにすることで、レイがオブジェクトを突き抜けてforループが終わるまで進み続ける。
		d = max(abs(d), 0.02);
		// 距離を適当な指数関数で減衰した値を密度としたボリューム累積
		ac += exp(-d*3.);

		t += d* 0.1;
	}

	col = vec3(ac * 0.02);
	vec3 finalColor = vec3 ( 0., 0., 0. );

	p *= 20.;
	col += smoothstep(0.5, 1.,sin(time)) * .15 * vec3 ( 1.0, 0.3, 0.5 );
	col += smoothstep(0.5, 1.,cos(time)) * .15 * vec3 ( .0, 0.3, 1.0 );
	float  v =  abs(8.0 / (sin( (p.x + p.y*sin(time*0.5) * 2.)* 0.5 ) *5.0)) ;
	//col*=(v);

	//col.x += + 0.125;
	col.z += + 0.54;
	col.y = col.y * abs(sin(time) / 4.) + 0.54;
	//col.x += p.x * sin(time) * cos(time) * 2.;
	//col.x += p.y * 2.;
	//col.z += ac;


	gl_FragColor = vec4(col ,1.0);
}
