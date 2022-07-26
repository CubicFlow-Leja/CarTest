Shader "Lejashaderi/TreeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_HeightChangeTex("_HeightChangeTex", 2D) = "white" {}
        _Height ("_Height", Range(0.0,0.1)) = 0.01
        _Width ("_Width", Range(0.0,0.1)) = 0.01
        _CuttOff ("_CuttOff", Range(0.0,1.0)) = 0.42
        _WindFac ("_WindFac", Range(0.0,0.01)) = 0.0017
        _WindSpeed ("_WindSpeed", Range(0.0,5)) = 0.42
	    _Color("Color", Color) = (236,37,37,1)

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

			sampler2D _HeightChangeTex;
			half4 _HeightChangeTex_ST;

			half _CuttOff;
			half _Height;
			half _Width;
			half4 _WindDir;
			float _WindFac;
			float _WindSpeed;
			half4 _ViewDir;	
			
			fixed4 _ColorShadow;
			fixed4 _GlobalColor;
			fixed4 _Color;


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
				OUT.pos = UnityObjectToClipPos(v0 + perp );
				OUT.color = col;
				OUT.uv = float2(a, b);
				TRANSFER_SHADOW(OUT);
				return OUT;
			}

			[maxvertexcount(8)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
			{
				float HDelta = clamp(tex2Dlod(_HeightChangeTex, half4(IN[0].uv)).r + 0.5, 0.5, 1);
				float H = _Height;// clamp((GrowthRad - length(IN[0].wpos.xyz - GrowthCenter.xyz)) / 100, 0, _Height);
				float W = H * _Width / _Height;


				half3 ViewDir = normalize(_ViewDir);
				ViewDir.y = 0;
				ViewDir = normalize(ViewDir);
				
				half3 ViewTangent = normalize(cross(ViewDir, half3(0, 1, 0)));
				half3 ViewUpDir = -normalize(cross(ViewDir, ViewTangent));


				
				half3 Up = normalize(mul( unity_WorldToObject, ViewUpDir ));
				half3 Perp1 = normalize(mul(unity_WorldToObject, ViewTangent))*0.5*W;
				//half3 Perp1 = normalize(mul(unity_WorldToObject, ViewTangent + ViewDir))*0.5*W;
				half3 Perp2 = normalize(mul(unity_WorldToObject, ViewDir))*0.5*W;
				//half3 Perp3 = normalize(mul(unity_WorldToObject, ViewTangent - ViewDir))*0.5*W;

				half3 v0 = IN[0].vertex.xyz;
				half3 v1 = IN[0].vertex.xyz + Up * H+_WindFac*normalize(mul(unity_WorldToObject, _WindDir)) *sin(_Time.w*_WindSpeed +IN[0].vertex.x*25+ IN[0].vertex.y*55+ IN[0].vertex.z*100);
			
				g2f OUT;

				half3 col = _Color* _GlobalColor;
				
			
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

			/*	triStream.Append(MakeVertex(v0, Perp3, col*0.3, 1, 0));
				triStream.Append(MakeVertex(v0, -Perp3, col*0.3, 0, 0));
				triStream.Append(MakeVertex(v1, Perp3, col, 1, 1));
				triStream.Append(MakeVertex(v1, -Perp3, col, 0, 1));

				triStream.RestartStrip();*/


			}

            fixed4 frag (g2f i) : SV_Target
            {
				half shadow = SHADOW_ATTENUATION(i);
                fixed4 col = tex2D(_MainTex, i.uv);
				clip(-col.r + _CuttOff);

				/*if(shadow<1)
					return (fixed4(i.color, 1.0)) *_ColorShadow*_GlobalColor;*/

				return fixed4(i.color, 1.0);// *_GlobalColor;
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
				};

				struct g2f
				{
					half2 uv : TEXCOORD0;
					half4 pos : SV_POSITION;
				};

				sampler2D _MainTex;
				half4 _MainTex_ST;

				sampler2D _HeightChangeTex;
				half4 _HeightChangeTex_ST;

				half _CuttOff;
				half _Height;
				half _Width;
			
				half4 _ViewDir;

				half4 _WindDir;
				float _WindFac;
				float _WindSpeed;



				half4 GrowthCenter;
				half GrowthRad;


				v2g vert(appdata_full v)
				{
				
					v2g o;
					o.wpos = mul(unity_ObjectToWorld, v.vertex);
					o.vertex = v.vertex;
					return o;
				}


				g2f MakeVertex(float3 v0, float3 perp, int a, int b)
				{
					g2f OUT;
					OUT.uv = float2(a, b);
					OUT.pos = UnityObjectToClipPos(v0 + perp );
					//OUT.pos = UnityObjectToClipPos(v0 + perp * 0.5*_Width);
					return OUT;
				}



				[maxvertexcount(8)]
				void geom(point v2g IN[1], inout TriangleStream<g2f> triStream)
				{
					float HDelta = clamp(tex2Dlod(_HeightChangeTex, half4(IN[0].uv)).r + 0.5, 0.5, 1);
					//float H = clamp(GrowthRad - length(IN[0].wpos - GrowthCenter.xyz), 0, _Height);
					float H = _Height;//clamp((GrowthRad - length(IN[0].wpos.xyz - GrowthCenter.xyz) )/ 100, 0, _Height);
					float W = H * _Width / _Height;


					half3 ViewDir = normalize(_ViewDir);
					ViewDir.y = 0;
					ViewDir = normalize(ViewDir);
					
					half3 ViewTangent = normalize(cross(ViewDir, half3(0, 1, 0)));
					half3 ViewUpDir = -normalize(cross(ViewDir, ViewTangent));

					half3 Up = normalize(mul(unity_WorldToObject, ViewUpDir));
					half3 Perp1 = normalize(mul(unity_WorldToObject, ViewTangent))*0.5*W;
					//half3 Perp1 = normalize(mul(unity_WorldToObject, ViewTangent + ViewDir))*0.5*W;
					half3 Perp2 = normalize(mul(unity_WorldToObject, ViewDir))*0.5*W;
					//half3 Perp3 = normalize(mul(unity_WorldToObject, ViewTangent - ViewDir))*0.5*W;

					half3 v0 = IN[0].vertex.xyz;
					half3 v1 = IN[0].vertex.xyz + Up * H + _WindFac * normalize(mul(unity_WorldToObject, _WindDir)) *sin(_Time.w*_WindSpeed + IN[0].vertex.x * 25 + IN[0].vertex.y * 55 + IN[0].vertex.z * 100);
					g2f OUT;

				
					triStream.Append(MakeVertex(v0, -Perp1, 1, 0));
					triStream.Append(MakeVertex(v0, Perp1, 0, 0));
					triStream.Append(MakeVertex(v1, -Perp1,  1, 1));
					triStream.Append(MakeVertex(v1, Perp1,  0, 1));

					triStream.RestartStrip();

					triStream.Append(MakeVertex(v0, -Perp2, 1, 0));
					triStream.Append(MakeVertex(v0, Perp2,  0, 0));
					triStream.Append(MakeVertex(v1, -Perp2, 1, 1));
					triStream.Append(MakeVertex(v1, Perp2,  0, 1));

					triStream.RestartStrip();

				/*	triStream.Append(MakeVertex(v0, Perp3, 1, 0));
					triStream.Append(MakeVertex(v0, -Perp3, 0, 0));
					triStream.Append(MakeVertex(v1, Perp3,  1, 1));
					triStream.Append(MakeVertex(v1, -Perp3, 0, 1));

					triStream.RestartStrip();*/


				}

				float4 frag(g2f i) : SV_Target
				{
					fixed4 col = tex2D(_MainTex, i.uv);
					clip(-col.r + _CuttOff);
					SHADOW_CASTER_FRAGMENT(i)
				}

				ENDCG

			}
    }
	
}
