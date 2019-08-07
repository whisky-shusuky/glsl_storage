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
const vec3 eyesColor = vec3(0.9, 0.15, 0.15);	// 目の色
const vec3 mouthColor = vec3(0.831, 0.568, 0.596	);	// 目の色
const vec3 body = vec3(0.95, 0.95, 0.95);	// ハイライトの色
const vec3 leg = vec3(0.8, 0.8, 0.8);	// ハイライトの色
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

void diagonalEllipse(vec2 st, vec2 offset, vec2 prop, float size, float rad, vec3 color, inout vec3 i){
	float s = sin(rad);
	float c = cos(rad);
	vec2 q = (st - offset)* mat2(c, -s, s, c) / prop;
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
	vec3 destColor = vec3(sin(time), sin(time), sin(time));
	// おおもとの座標を回転させる
	float s = sin(sin(time * 2.0) * 0.75);
	float c = cos(sin(time * 2.0));
	vec2 q = st * mat2(c, -s, s, c) ;
	//デバッグ用
	// ソーデスを止める
//	vec2 q = st;

	// 尻尾
	arcLine(q * vec2(1.0, 1.0), vec2(0.7, 0.), 0.1, 0.2, PI, -0., leg, destColor);

	// 足
	diagonalEllipse(q, vec2(0.35, -0.335), vec2(0.55, 1.2), 0.35, -0.5, leg, destColor);
	diagonalEllipse(q, vec2(-0.35, -0.335), vec2(0.55, 1.2), 0.35, 0.5, leg, destColor);

	// 耳
	diagonalEllipse(q, vec2(0.35, 0.335), vec2(0.55, 1.2), 0.35, .7, leg, destColor);
	diagonalEllipse(q, vec2(-0.35, 0.335), vec2(0.55, 1.2), 0.35, -.7, leg, destColor);
	arcLine(q * vec2(1.0, 1.0), vec2(0.45, 0.45), 0., 0.15, 0.6, 0., mouthColor, destColor);
	arcLine(q * vec2(1.0, 1.0), vec2(0.45, 0.45), 0., 0.15, 0.6, 0., mouthColor, destColor);
	arcLine(q * vec2(-1.0, 1.0), vec2(0.45, 0.45), 0., 0.15, 0.6, 0., mouthColor, destColor);	
	
	// 体
	ellipse(q, vec2(0., 0.), vec2(1.2, 1.0), 0.575, body, destColor);
//	arcLine(q * vec2(1., 1.0), vec2(0.0, 0.0), 0., 0.145, 0.5, 0., eyesColor, destColor);

	// 眉
	arcLine(q * vec2(0.95, 2.5), vec2(0.27, 0.39), 0.125, 0.2, 0.2, 0., lineColor, destColor);
	arcLine(q * vec2(-0.95, 2.5), vec2(0.27, 0.39), 0.125, 0.2, 0.2, 0., lineColor, destColor);
	//目
	ellipse(q, vec2(0.25, 0.131), vec2(2.5, 1.1), 0.075, eyesColor, destColor);
	ellipse(q, vec2(-0.25, 0.131), vec2(2.5, 1.1), 0.075, eyesColor, destColor);

	// 口
	ellipse(q, vec2(0., -0.3), vec2(2., 2.3), 0.05, mouthColor, destColor);
	arcLine(q * vec2(1.0, 1.0), vec2(0., -0.25), 0.1, 0.12, PI, -0., mouthColor, destColor);
	arcLine(q * vec2(0.9, 1.0), vec2(0.1, -0.14), 0.1, 0.12, PI, 0.05, lineColor, destColor);
	arcLine(q * vec2(-0.9, 1.0), vec2(0.1, -0.14), 0.1, 0.12, PI, 0.05, lineColor, destColor);
	arcLine(q * vec2(0.9, 1.0), vec2(0.1, -0.14), 0., 0.1, PI, -0.55, body, destColor);
	arcLine(q * vec2(-0.9, 1.0), vec2(0.1, -0.14), 0., 0.1, PI, -0., body, destColor);
	gl_FragColor = vec4(destColor, 1.0);
}
