Shader "Lejashaderi/GeometryGrassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("_NoiseTex", 2D) = "white" {}
        _HeightChangeTex ("_HeightChangeTex", 2D) = "white" {}
        _Height ("_Height", Range(0.0,10.0)) =5
        _Width ("_Width", Range(0.0,10.0)) = 3
        _CuttOff ("_CuttOff", Range(0.0,1.0)) = 0.4
	    _Color("Color", Color) = (0.44,0.0667,0.278,1)
	    _ColorDry("_ColorDry", Color) = (0.44,0.0667,0.278,1)

		_WetMap("_WetTex", 2D) = "white" {}

    }
    SubShader
    {
       
       
        Pass
        {
			Tags {"Queue" = "Geometry" "LightMode" = "ForwardBase"  }

			Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma geometry geom

			#pragma target 4.0
            #include "UnityCG.cginc"

			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#include "AutoLight.cginc"
			struct appdata
			{
				half4 vertex : POSITION;
				half4 uv : TEXCOORD0;
			};


            struct v2g
            {
				half4 vertex : POSITION;
				half4 uv : TEXCOORD0;
				float3 wpos : TEXCOORD2;
                
            };

			struct g2f
			{
				half4 pos : SV_POSITION;
				half2 uv : TEXCOORD0;
				half3 color:TEXCOORD1;
				SHADOW_COORDS(2)

			};

            sampler2D _MainTex;
			half4 _MainTex_ST;

			sampler2D _NoiseTex;
			half4 _NoiseTex_ST;

			sampler2D _HeightChangeTex;
			half4 _HeightChangeTex_ST;
			
		

			half _CuttOff;
			half _Height;
			half _Width;

		
			fixed4 _ColorShadow;
			fixed4 _GlobalColor;
			
			fixed4 _Color;
			fixed4 _ColorDry;

			half4 _WindDir;
			float _WindFac;
			float _WindSpeed;
			float _WindPosParam;

			sampler2D _WetMap;
			half4 _WetMap_ST;

			half4 GrowthCenter;
			half GrowthRad;

			v2g vert (appdata v)
            {
                v2g o;
				o.wpos = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = v.vertex;
				o.uv = v.uv;
                 
                return o;
            }


			g2f MakeVertex(float3 v0,float3 perp,float3 col,int a,int b)
			{
				g2f OUT;
				//OUT.pos = UnityObjectToClipPos(v0 + perp * 0.5*_Width);
				OUT.pos = UnityObjectToClipPos(v0 + perp);
				OUT.color = col;
				OUT.uv = float2(a, b);
				TRANSFER_SHADOW(OUT);
				return OUT;
			}

		

			[maxvertexcount(12)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
			{
				float Wetness = tex2Dlod(_WetMap, half4(IN[0].uv)).r;
				half3 DisLocation = tex2Dlod(_NoiseTex, half4(IN[0].uv)).rgb;
				
				float HDelta = clamp(tex2Dlod(_HeightChangeTex, half4(IN[0].uv)).r + 0.25, 0.25, 1);
			
				DisLocation.x = (DisLocation.x)*2 -1;
				DisLocation.z = (DisLocation.z)*2 -1;
				DisLocation.y =2;
				
				DisLocation = normalize(DisLocation);

				//float H= (length(IN[0].wpos-GrowthCenter.xyz) + _Height - GrowthRad);
				float H = clamp(GrowthRad - length(IN[0].wpos.xyz - GrowthCenter.xyz), 0, _Height * HDelta);
				float W=  _Width *(H / _Height) * (H / _Height);
				W = clamp(W, 0.25 * _Width, _Width);
				//float W= _Width;

				half3 Perp1 = half3(sin(IN[0].wpos.x * 5), 0, cos(IN[0].wpos.x)) * W * 0.5;
				half3 Perp2 = half3(sin(IN[0].wpos.x * 5 +2* 3.14 / 3), 0, cos(IN[0].wpos.x * 5 +2* 3.14 / 3)) * W * 0.5;
				half3 Perp3 = half3(sin(IN[0].wpos.x * 5 -2* 3.14 / 3), 0, cos(IN[0].wpos.x * 5 -2* 3.14 / 3)) * W * 0.5;

				half3 v0 = IN[0].vertex.xyz;
				//half3 v1 = IN[0].vertex.xyz +normalize( DisLocation +_WindFac * normalize(mul(unity_WorldToObject, _WindDir)) *sin(_Time.w * _WindSpeed + IN[0].vertex.x / _WindPosParam + IN[0].vertex.y / _WindPosParam + IN[0].vertex.z / _WindPosParam)) * _Height ;
				half3 v1 = IN[0].vertex.xyz +normalize( DisLocation +_WindFac * normalize(mul(unity_WorldToObject, _WindDir)) *sin(_Time.w * _WindSpeed + IN[0].vertex.x / _WindPosParam + IN[0].vertex.y / _WindPosParam + IN[0].vertex.z / _WindPosParam)) * H ;
			
				g2f OUT;

				
				half3 col = lerp(_ColorDry,_Color, Wetness);
				//half3 col = _Color;
				
			



				triStream.Append(MakeVertex(v0,Perp1, col*0.3,1,0));
				triStream.Append(MakeVertex(v0, -Perp1, col*0.3, 0, 0));
				triStream.Append(MakeVertex(v1, Perp1, col, 1, 1));
				triStream.Append(MakeVertex(v1, -Perp1, col, 0, 1));

				triStream.RestartStrip();

				triStream.Append(MakeVertex(v0, Perp2, col*0.3, 1, 0));
				triStream.Append(MakeVertex(v0, -Perp2, col*0.3, 0, 0));
				triStream.Append(MakeVertex(v1, Perp2, col, 1, 1));
				triStream.Append(MakeVertex(v1, -Perp2, col, 0, 1));

				triStream.RestartStrip();



				triStream.Append(MakeVertex(v0, Perp3, col*0.3, 1, 0));
				triStream.Append(MakeVertex(v0, -Perp3, col*0.3, 0, 0));
				triStream.Append(MakeVertex(v1, Perp3, col, 1, 1));
				triStream.Append(MakeVertex(v1, -Perp3, col, 0, 1));

				triStream.RestartStrip();
			


			}

            fixed4 frag (g2f i) : SV_Target
            {
				half shadow = SHADOW_ATTENUATION(i);
                fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.r - _CuttOff);

				if(shadow<1)
					return fixed4(i.color, 1.0) *_ColorShadow*_GlobalColor;
				return  fixed4(i.color, 1.0) *_GlobalColor;
            }
            ENDCG
        }

		//shadowcast pass koji realno smeta al aj 
			pass
			{
				Tags
				{ 
					"LightMode" = "ShadowCaster"
				}
					Cull Off
				CGPROGRAM
				#pragma vertex vert
				#pragma geometry geom
				#pragma fragment frag
				#pragma target 4.0
				#pragma multi_compile_shadowcaster
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				struct v2g
				{
					half4 vertex : POSITION;
					half4 uv : TEXCOORD0;
					float3 wpos : TEXCOORD2;
					half3 color:TEXCOORD1;
				};

				struct g2f
				{
					half2 uv : TEXCOORD0;
					half4 pos : SV_POSITION;
				};

				sampler2D _MainTex;
				half4 _MainTex_ST;

				sampler2D _NoiseTex;
				half4 _NoiseTex_ST;

				sampler2D _HeightChangeTex;
				half4 _HeightChangeTex_ST;

				half _CuttOff;
				half _Height;
				half _Width;
			
				half4 _WindDir;
				float _WindFac;
				float _WindSpeed;
				float _WindPosParam;
			
				half4 GrowthCenter;
				half GrowthRad;


				v2g vert(appdata_full v)
				{
					v2g o;
					o.vertex = v.vertex;
					o.wpos = mul(unity_ObjectToWorld, v.vertex);
					o.uv = v.texcoord;
					return o;
				}


				g2f MakeVertex(float3 v0, float3 perp, int a, int b)
				{
					g2f OUT;
					OUT.uv = float2(a, b);
					OUT.pos = UnityObjectToClipPos(v0 + perp );
					return OUT;
				}



				[maxvertexcount(12)]
				void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
				{
					half3 DisLocation = tex2Dlod(_NoiseTex, half4(IN[0].uv)).rgb;
					float HDelta = clamp(tex2Dlod(_HeightChangeTex, half4(IN[0].uv)).r+0.25, 0.25, 1);


					DisLocation.x = (DisLocation.x) * 2 - 1;
					DisLocation.z = (DisLocation.z) * 2 - 1;
					DisLocation.y = 2;
					DisLocation = normalize(DisLocation);

					float H = clamp(GrowthRad - length(IN[0].wpos.xyz - GrowthCenter.xyz), 0, _Height*HDelta);
					float W = _Width * (H / _Height) * (H / _Height);
					W = clamp(W, 0.25 * _Width, _Width);
					//float W = _Width;


					half3 Perp1 = half3(sin(IN[0].wpos.x * 5), 0, cos(IN[0].wpos.x)) * W * 0.5;
					half3 Perp2 = half3(sin(IN[0].wpos.x * 5 + 2 * 3.14 / 3), 0, cos(IN[0].wpos.x * 5 + 2 * 3.14 / 3)) * W * 0.5;
					half3 Perp3 = half3(sin(IN[0].wpos.x * 5 - 2 * 3.14 / 3), 0, cos(IN[0].wpos.x * 5 - 2 * 3.14 / 3)) * W * 0.5;

					/*half3 Perp1 = half3(1, 0, 0)*W*0.5;
					half3 Perp2 = half3(0.3, 0, 0.95)*W*0.5;
					half3 Perp3 = half3(0.3, 0, -0.95)*W*0.5;*/

					half3 v0 = IN[0].vertex.xyz;
					//half3 v1 = IN[0].vertex.xyz +normalize( DisLocation +_WindFac * normalize(mul(unity_WorldToObject, _WindDir)) *sin(_Time.w * _WindSpeed + IN[0].vertex.x / _WindPosParam + IN[0].vertex.y / _WindPosParam + IN[0].vertex.z / _WindPosParam)) * _Height ;
					half3 v1 = IN[0].vertex.xyz + normalize(DisLocation + _WindFac * normalize(mul(unity_WorldToObject, _WindDir)) *sin(_Time.w * _WindSpeed + IN[0].vertex.x / _WindPosParam + IN[0].vertex.y / _WindPosParam + IN[0].vertex.z / _WindPosParam)) * H;

					g2f OUT;

					triStream.Append(MakeVertex(v0, Perp1, 1, 0));
					triStream.Append(MakeVertex(v0, -Perp1, 0, 0));
					triStream.Append(MakeVertex(v1, Perp1, 1, 1));
					triStream.Append(MakeVertex(v1, -Perp1, 0, 1));

					triStream.RestartStrip();

					triStream.Append(MakeVertex(v0, Perp2, 1, 0));
					triStream.Append(MakeVertex(v0, -Perp2, 0, 0));
					triStream.Append(MakeVertex(v1, Perp2, 1, 1));
					triStream.Append(MakeVertex(v1, -Perp2, 0, 1));

					triStream.RestartStrip();



					triStream.Append(MakeVertex(v0, Perp3, 1, 0));
					triStream.Append(MakeVertex(v0, -Perp3, 0, 0));
					triStream.Append(MakeVertex(v1, Perp3, 1, 1));
					triStream.Append(MakeVertex(v1, -Perp3, 0, 1));

					triStream.RestartStrip();



				}
				float4 frag(g2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					clip(col.r - _CuttOff);
					SHADOW_CASTER_FRAGMENT(i)
				}

				ENDCG

			}
    }
	
}
