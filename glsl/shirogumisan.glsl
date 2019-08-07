#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

// reference
// https://qiita.com/doxas/items/a366eafc498c8269934c

uniform float time;
uniform vec2 resolution;

#define white vec3(1.0)
const vec3 red	 = vec3(1.0, 0.0, 0.0);
const vec3 green = vec3(0.0, 1.0, 0.0);
const vec3 blue	= vec3(0.0, 0.0, 1.0);

const float PI = 3.1415926;
const vec3 eyesColor = vec3(0.15, 0.05, 0.05);	// 目の色
const vec3 tohu = vec3(0.95, 0.95, 0.95);	// ハイライトの色
const vec3 lineColor = vec3(0.3, 0.2, 0.2);		 // ラインの色


// void なので戻り値なし
// ただしinout は引数を動的に書き換える
void rect(vec2 st, vec2 offset, float size, vec3 color, inout vec3 i){
	// ベクトルの長さ
	vec2 q = (st - offset) / size;
	if(abs(q.x) < 1.0 && abs(q.y) < 1.0){
		i = color;
	}
}

void ellipse(vec2 st, vec2 offset, vec2 prop, float size, vec3 color, inout vec3 i){
		vec2 q = (st - offset) / prop;
		if(length(q) < size){
				i = color;
		}
}

// 円形にラインを引く
void circleLine(vec2 st, vec2 offset, float iSize, float oSize, vec3 color, inout vec3 i){
	vec2 q = st - offset;
	float l = length(q);
	if(l > iSize && l < oSize){
		i = color;
	}
}

void arcLine(vec2 st, vec2 offset, float iSize, float oSize, float rad, float height, vec3 color, inout vec3 i){
	float s = sin(rad);
	float c = cos(rad);
	vec2 q = (st - offset) * mat2(c, -s, s, c);
	float l = length(q);
	if(l > iSize && l < oSize && q.y > height){
		i = color;
	}
}


void main(void){
	// 正規化
	vec2 st = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
	vec3 destColor = vec3(0.0, 1.0, 1.0);
	// おおもとの座標を回転させる
	float s = sin(sin(time * 2.0) * 0.75);
	float c = cos(sin(time * 2.0));
	vec2 q = st * mat2(c, -s, s, c) ;

	rect(q, vec2(0.0), 0.5, tohu, destColor);

	ellipse(q, vec2(0.15, 0.135), vec2(0.75, 1.0), 0.075, eyesColor, destColor);
	ellipse(q, vec2(-0.15, 0.135), vec2(0.75, 1.0), 0.075, eyesColor, destColor);
	arcLine(q * vec2(1.5, 1.0), vec2(0.35, 0.07), 0.125, 0.145, -0.3, 0.1, eyesColor, destColor);
	arcLine(q * vec2(1.5, 1.0), vec2(-0.35, 0.07), 0.125, 0.145, 0.3, 0.1, eyesColor, destColor);	
	arcLine(q * vec2(0.9, 1.0), vec2(0.0, -0.15), 0.2, 0.22, PI, 0.055, lineColor, destColor);
	gl_FragColor = vec4(destColor, 1.0);
}
