Shader "Custom/MatrixLike"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha 
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            #define RAIN_SPEED .7 // Speed of rain droplets
            #define DROP_SIZE  0.4  // Higher value lowers, the size of individual droplets
            
            float rand(fixed2 co){
                return frac(sin(dot(co.xy ,fixed2(12.9898,78.233))) * 43758.5453);
            }
            
            float rchar(fixed2 outer, fixed2 inner, float globalTime) {
	            //return float(rand(floor(inner * 2.0) + outer) > 0.9);
            
	            fixed2 seed = floor(inner * 4.0) + outer.y;
	            if (rand(fixed2(outer.y, 23.0)) > 0.98) {
		            seed += floor((globalTime + rand(fixed2(outer.y, 49.0))) * 3.0);
	            }
            
	            return float(rand(seed) > 0.5);
            }


            fixed4 frag (v2f i) : SV_Target
            {
				// inspired by: https://www.shadertoy.com/view/lsXSDn
				//              http://glslsandbox.com/e#58452.0   
                fixed2 resolution = _ScreenParams;
				fixed2 position = (i.uv*resolution * 2. - _ScreenParams.xy) / min(resolution.x, resolution.y);
            	float color = 0.0;
            	fixed2 uv = fixed2(position.x, position.y);
                float time = _Time * 30;
	            float globalTime = time * RAIN_SPEED;
	            // マトリックス部分
	            position.x /= resolution.x / resolution.y;
	            fixed4 result = fixed4(0.0,0.0,0.0,0.0);
	            float scaledown = DROP_SIZE;
	            float rx = resolution.x / (40.0 * scaledown);
	            float mx = 40.0*scaledown*frac(position.x * 3.0 * scaledown);


	            if (mx >  12.0 * scaledown) {
		            result = fixed4(0.0,0.0,0.0,0.0);
	            } else {
        	        float x = floor(rx);
		            float r1x = floor(resolution.x / (15.0));
		            float ry = position.y*600.0 + rand(fixed2(x, x * 3.0)) * 100000.0 + globalTime* rand(fixed2(r1x, 23.0)) * 120.0;
		            float my = fmod(ry, 15.0);
		            if (my > 12.0 * scaledown) {
			            result = fixed4(0.0,0.0,0.0,0.0);
		            } else {
                    
			            float y = floor(ry / 15.0);

			            float b = rchar(fixed2(rx, floor((ry) / 15.0)), fixed2(mx, my) / 12.0, globalTime);
			            float col = max(fmod(-y, 24.0) - 4.0, 0.0) / 20.0;
			            //fixed3 c = col < 0.8 ? fixed3(0.0, col / 0.8, 0.0) : lerp(fixed3(0.0, 1.0, 0.0), fixed3(1.0,1.0,1.0), (col - 0.8) / 0.2);
                        fixed3 c = lerp(fixed3(0.0, 1.0, 0.0), fixed3(1.0,1.0,1.0), (col - 0.8) / 0.2);


			            //result = fixed4(c * b, 1.0)  ;
                        result = fixed4(c * b, 1.0) ;
                        //result = fixed4(1.0,1.0,1.0, 1.0) ;
		            }
	            }

	            position.x += 0.05;

	            scaledown = DROP_SIZE;
	            rx = resolution.x / (40.0 * scaledown);
	            mx = 40.0*scaledown*frac(position.x * 30.0 * scaledown);


	            if (mx > 12.0 * scaledown) {
		            result += fixed4(0.0,0.0,0.0,0.0);
	            } else {
        	        float x = floor(rx);
		            float r1x = floor(resolution.x / (12.0));


		            float ry = position.y*700.0 + rand(fixed2(x, x * 3.0)) * 100000.0 + globalTime* rand(fixed2(r1x, 23.0)) * 120.0;
		            float my = fmod(ry, 15.0);
		            if (my > 12.0 * scaledown) {
			            result += fixed4(0.0,0.0,0.0,0.0);
		            } else {
                    
			            float y = floor(ry / 15.0);

			            float b = rchar(fixed2(rx, floor((ry) / 15.0)), fixed2(mx, my) / 12.0, globalTime);
			            float col = max(fmod(-y, 24.0) - 4.0, 0.0) / 20.0;
			            fixed3 c = lerp(fixed3(0.0, 1.0, 0.0), fixed3(1.0,1.0,1.0), (col - 0.8) / 0.2);

			            result += fixed4(c * b, 1.0)  ;
		            }
	            }

	            position.x += 0.05;

	            scaledown = DROP_SIZE;
	            rx = resolution.x / (40.0 * scaledown);
	            mx = 40.0*scaledown*frac(position.x * 30.0 * scaledown);

	            if (mx > 12.0 * scaledown) {
		            result += fixed4(0.0,0.0,0.0,0.0);
	            } else {
        	        float x = floor(rx);
		            float r1x = floor(resolution.x / (9.0));


		            float ry = position.y*800.0 + rand(fixed2(x, x * 3.0)) * 100000.0 + globalTime* rand(fixed2(r1x, 23.0)) * 120.0;
		            float my = fmod(ry, 15.0);
		            if (my > 12.0 * scaledown) {
			            result += fixed4(0.0,0.0,0.0,0.0);
		            } else {
                    
			            float y = floor(ry / 15.0);

			            float b = rchar(fixed2(rx, floor((ry) / 15.0)), fixed2(mx, my) / 12.0, globalTime);
			            float col = max(fmod(-y, 24.0) - 4.0, 0.0) / 20.0;
			            fixed3 c = lerp(fixed3(0.0, 1.0, 0.0), fixed3(1.0,1.0,1.0), (col - 0.8) / 0.2);

			            result += fixed4(c * b, 1.0)  ;
		            }
	            }


	            if(result.b < 0.5)
	            result.b = result.g * 0.5 ;


	            // 色部分

	            // 赤セット
	            fixed3 rColor =fixed3(1.0,0.0,0.3);
	            // 青セット
	            fixed3 bColor =fixed3(0.0,0.20,1.0);
	            // 緑セット
	            fixed3 gColor =fixed3(0.0,0.20,0.3);

	            // 黄色
	            fixed3 yColor =fixed3(0.9,0.3,0.0);
	            // 紫色
	            fixed3 vColor =fixed3(0.5,0.0,0.5);
	            // 水色
	            fixed3 wColor =fixed3(0.0,1.0,1.0);

	            float x = sin(position.y * 2.0 + time * .05);
	            float bx = cos(position.x * 1.0 + time * .1);
	            float gx = sin(position.x * 1.4 + time * .15);
	            float yx = sin(position.y * 1.0 + time * .2);
	            float vx = sin(position.y * 2.0 + time * .4);
	            float wx = sin(position.y * 2.5 + time * .5);
	            float y = 0.1 / abs(position.x + x);
	            float by = .25 / abs(position.y + bx);
	            float gy = 0.025 / abs(position.y + gx);
	            float yy = 0.1 / abs(position.x + yx);
	            float vy = 0.3 / abs(position.x + vx);
	            float wy = 0.4 / abs(position.y + vy);

	            fixed4 destColor = fixed4(rColor * y, 0.1);
	            fixed4 destColor2 = fixed4(bColor * by, 0.1);
	            fixed4 destColor3 = fixed4(gColor * gy, 0.1);
	            fixed4 destColor4 = fixed4(yColor * yy, 0.1);
	            fixed4 destColor5 = fixed4(yColor * yy, 0.1);
	            fixed4 destColor6 = fixed4(yColor * yy, 0.1);

	            result += destColor + destColor2 + destColor3 + destColor4 + destColor5 + destColor6;
                
                return result;
            }
            ENDCG
        }
    }
}
