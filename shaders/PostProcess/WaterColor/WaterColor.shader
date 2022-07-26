Shader "Hidden/WaterColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		//_Columns("Columns",int)= 256
		//_Rows("Rows",int)= 256

    }
    SubShader
    {
        
       // Cull Off ZWrite Off ZTest Always



        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			//sampler2D _TempTex;
			int _Columns;
			int _DownSample;
            float DownSampleStrength;

			int _Iterations;

            fixed4 frag (v2f i) : SV_Target
            {
				float2 uv = i.uv;


				/*uv.y *= _Rows;
				uv.x *= _Columns;
				uv.y = round(uv.y);
				uv.x = round(uv.x);
				uv.y /= _Rows;
				uv.x /= _Columns;*/

                //fixed4 col = tex2D(_MainTex, uv);
                fixed4 colm = tex2D(_MainTex, uv);



                
                fixed Temp = colm;
                for (int i = 0; i < _Iterations; i++)
                {
                    int Max = i + 1;
                   // int Max = i + 1;
                    //int Min = -1 - i;

                    fixed4 col1 = tex2D(_MainTex, uv + half2(-Max / _ScreenParams.x, Max / _ScreenParams.y));
                  //  fixed4 col1 = tex2D(_MainTex, uv + half2(-1 / _ScreenParams.x, 1 / _ScreenParams.y));
                    fixed4 col2 = tex2D(_MainTex, uv + half2(0 / _ScreenParams.x, Max / _ScreenParams.y));
                    fixed4 col3 = tex2D(_MainTex, uv + half2(Max / _ScreenParams.x, Max / _ScreenParams.y));

                    fixed4 col4 = tex2D(_MainTex, uv + half2(-Max / _ScreenParams.x, -Max / _ScreenParams.y));
                    fixed4 col5 = tex2D(_MainTex, uv + half2(0 / _ScreenParams.x, -Max / _ScreenParams.y));
                    fixed4 col6 = tex2D(_MainTex, uv + half2(Max / _ScreenParams.x, -Max / _ScreenParams.y));

                    fixed4 col7 = tex2D(_MainTex, uv + half2(-Max / _ScreenParams.x, 0));
                    fixed4 col8 = tex2D(_MainTex, uv + half2(Max / _ScreenParams.x, 0));
                    

                    colm = (colm+col1 + col2 + col3 + col4 + col5 + col6 + col7 + col8 ) / 9;
                }
               // return (col1 + col2 + col3 + col4 + col5 + col6 + col7 + col8 + 0*col9) / 8;
               //colm /= _Iterations;
               // colm = colm + Temp;
               // colm /= 2;

               /* int _DownSample;
                float DownSampleStrength;*/

                fixed4 TempCol = colm;
                colm *= _DownSample;
                colm = round(colm);
                colm /= _DownSample;

                return lerp(TempCol, colm, DownSampleStrength);
            }
            ENDCG
        }
    }
}
