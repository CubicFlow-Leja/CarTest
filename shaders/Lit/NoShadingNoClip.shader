Shader "Lejashaderi/NoShadingNoClip"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		
	}
		SubShader
		{
			
			Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }

			Pass 
			{
				Tags {"LightMode" = "ForwardBase"}


				Cull Off
				ZWrite On
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

			
				struct appdata
				{
					float4 vertex : POSITION;
					float4 normal : NORMAL;
					float2 uv : TEXCOORD0;
					UNITY_SHADOW_COORDS(1)
				};

				struct v2f
				{
					half4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					half diff : COLOR0;
					UNITY_SHADOW_COORDS(1)
				};


				
				fixed4 _Color;
				fixed4 _ColorShadow;
				fixed4 _GlobalColor;
				sampler2D _MainTex;
				float4 _MainTex_ST;

				v2f vert(appdata  v)
				{
					v2f o;
					half3 worldNormal = UnityObjectToWorldNormal(v.normal);
					half Dot = dot(worldNormal, _WorldSpaceLightPos0.xyz);
					o.diff = Dot;

					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.pos = UnityObjectToClipPos(v.vertex);
					UNITY_TRANSFER_SHADOW(o, v.uv);
					return o;
				}

			
				fixed4 frag(v2f i) : SV_Target
				{
					half shadow = SHADOW_ATTENUATION(i);
					fixed4 col;
					fixed4 col2 = tex2D(_MainTex, i.uv);
					col = _Color * col2*_GlobalColor;
					if (i.diff > 0|| shadow<1)
						col *= _ColorShadow;
				/*	else
						col = _Color * col2*_GlobalColor;*/
					return col;
				}
				ENDCG
			}

			
			Pass{
				Tags {"LightMode" = "ShadowCaster"}
				
				Cull Off
				CGPROGRAM
				
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#include "UnityCG.cginc"

				struct v2f {
				V2F_SHADOW_CASTER;
				};

				v2f vert(appdata_base v)
				{
					v2f o;
					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					SHADOW_CASTER_FRAGMENT(i)
				}

				ENDCG
			}
		}


}
