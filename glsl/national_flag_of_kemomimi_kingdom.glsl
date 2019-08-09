#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

// reference
// https://qiita.com/doxas/items/b8221e92a2bfdc6fc211

uniform float time;
uniform vec2 resolution;


const float PI = 3.1415926;
const vec3 white = vec3(1.0);		                            // 白
const vec3 gray = vec3(0.8, 0.8, 0.8);		            // グレー
const vec3 pinkPurple = vec3(0.968, 0.258, 0.776); // ピンク紫
const vec3 yellow = vec3(0.960, 0.858, 0.2);	    // 黄色
const vec3 blueBlack = vec3(0., 0., 0.25);		    // 青黒
const vec3 deepGray = vec3(0.5, 0.5, 0.5);		    // 青黒


// void なので戻り値なし
// ただしinout は引数を動的に書き換える

void arcLine(vec2 st, vec2 offset, float iSize, float oSize, float rad, float height, vec3 color, inout vec3 i){
	float s = sin(rad);
	float c = cos(rad);
	vec2 q = (st - offset) * mat2(c, -s, s, c);
	float l = length(q);
	if(l > iSize && l < oSize && q.y > height){
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

void main(void){
	// 正規化
	vec2 st = (gl_FragCoord.xy * 2.0 - resolution) / min(resolution.x, resolution.y);
	vec3 destColor = vec3(sin(time), sin(time) , sin(time));
	// おおもとの座標を回転させる
	float s = sin(sin(time * 2.0) * 0.75);
	float c = cos(sin(time * 2.0));
	vec2 q = st * mat2(c, -s, s, c) ;
	//デバッグ用
	// 動きを止める
	//vec2 q = st;
	
	// base
	//void circleLine(vec2 st, vec2 offset, float iSize, float oSize, vec3 color, inout vec3 i){
	arcLine(q * vec2(1., 1.), vec2(0., -0.2), 0., 0.6, PI, -1., gray, destColor);
	arcLine(q * vec2(1., 1.), vec2(0., 0.35), 0., 0.35, PI, -1., gray, destColor);
	arcLine(q * vec2(1., 1.), vec2(0.45, 0.2), 0., 0.35, PI, -1., gray, destColor);
	arcLine(q * vec2(1., 1.), vec2(-0.45, 0.2), 0., 0.35, PI, -1., gray, destColor);
	
	// 肉球
	arcLine(q * vec2(1., 1.), vec2(0., 0.4), 0., 0.18, PI, -1., pinkPurple, destColor);
	arcLine(q * vec2(1., 1.), vec2(0.5, 0.25), 0., 0.18, PI, -1., pinkPurple, destColor);
	arcLine(q * vec2(1., 1.), vec2(-0.5, 0.25), 0., 0.18, PI, -1., pinkPurple, destColor);

	// 鈴
	arcLine(q * vec2(1., 1.), vec2(0., -0.25), 0., 0.45, PI, -1., blueBlack, destColor);
	arcLine(q * vec2(1., 1.), vec2(0., -0.25), 0., 0.38, PI, -1., yellow, destColor);
	arcLine(q * vec2(12., 8.), vec2(0., -5.), 0., 0.45, PI, -1., blueBlack, destColor);
	arcLine(q * vec2(6., 13.), vec2(0., -7.6), 0., 0.45, PI, -1., blueBlack, destColor);

	// 耳(外)
	arcLine(q * vec2(2., -.5), vec2(0.275, 0.27), 0., 0.28, PI, -0., blueBlack, destColor);
	arcLine(q * vec2(-2., -.5), vec2(0.275, 0.27), 0., 0.28, PI, -0., blueBlack, destColor);
	
	// 耳(内)
	arcLine(q * vec2(2.5, -.6), vec2(0.4, 0.3), 0., 0.24, PI, -0., pinkPurple, destColor);
	arcLine(q * vec2(2.5, -.6), vec2(-0.4, 0.3), 0., 0.24, PI, -0., pinkPurple, destColor);

	// 耳毛
	diagonalEllipse(q, vec2(0.1, -0.4), vec2(0.55, 1.5), 0.07, 0.0, white, destColor);	
	diagonalEllipse(q, vec2(0.125, -0.405), vec2(0.55, 1.5), 0.07, 0.5, white, destColor);	
	diagonalEllipse(q, vec2(0.155, -0.45), vec2(0.55, 1.5), 0.07, 1.0, white, destColor);	
	diagonalEllipse(q, vec2(-0.1, -0.4), vec2(0.55, 1.5), 0.07, 0.0, white, destColor);	
	diagonalEllipse(q, vec2(-0.125, -0.405), vec2(0.55, 1.5), 0.07, -0.5, white, destColor);	
	diagonalEllipse(q, vec2(-0.155, -0.45), vec2(0.55, 1.5), 0.07, -1.0, white, destColor);	
	
	// 光沢
	arcLine(q * vec2(0.84, 0.5), vec2(-0.35, -0.1), 0.1, 0.15, -1.8, 0.05, white, destColor);
	arcLine(q * vec2(0.89, 0.6), vec2(-0.55, 0.13), 0.1, 0.15, -1.2, 0.05, white, destColor);
	arcLine(q * vec2(0.6, 0.65), vec2(-0.02, 0.3), 0.12, 0.15, -0.84, 0.1, white, destColor);
	arcLine(q * vec2(0.9, 0.7), vec2(0.4, 0.23), 0.1, 0.15, -0.5, 0.1, white, destColor);

	// 光沢(肉球)
	arcLine(q * vec2(1.89, 1.6), vec2(-1.1, 0.43), 0.1, 0.15, -1.2, 0.09, white, destColor);
	arcLine(q * vec2(1.89, 1.6), vec2(-.1, 0.7), 0.1, 0.15, -1., 0.09, white, destColor);
	arcLine(q * vec2(1.89, 1.4), vec2(0.8, 0.4), 0.1, 0.15, -1.2, 0.09, white, destColor);
	
	// 影
	arcLine(q * vec2(0.75, 0.9), vec2(-0.34, 0.34), 0.1, 0.15, -.1, 0.1, deepGray, destColor);	
	arcLine(q * vec2(0.7, 0.9), vec2(0.04, 0.45), 0.1, 0.15, .7, 0.1, deepGray, destColor);	
	arcLine(q * vec2(0.7, 0.52), vec2(0.41, 0.1), 0.1, 0.15, 2.2, 0.06, deepGray, destColor);	
	arcLine(q * vec2(0.7, 0.52), vec2(0.25, -0.15), 0.1, 0.15, 2., 0.09, deepGray, destColor);	
	
	gl_FragColor = vec4(destColor, 1.0);
}
