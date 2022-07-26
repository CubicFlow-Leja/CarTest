Shader "Lejashaderi/LambertishShaderLeja"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
	  //  _ColorShadow("ColorShadow", Color) = (1,1,1,1)
		_Shade1("Shade1",float) = 0
		_Shade2("Shade2",float) = 1
		_thresholdParam("_thresholdParam",float) = 2
		_DistParam("_DistParam",float) = 0.2
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			Cull back//FIXAT
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			#pragma target 5.0
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
				half diff : COLOR0;
				half4 pos : SV_POSITION;
				half3 wpos : TEXCOORD2;
				float2 uv : TEXCOORD0;
				float3 WorldNormal : TEXCOORD3;
				UNITY_SHADOW_COORDS(1)
			};


			fixed4 _Color;
			fixed4 _ColorShadow;
			fixed4 _GlobalColor;
			half _Shade1;
			half _Shade2;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			int RippleCount;
			float4 SoundRipples[25];
			float SoundRipplesStartingRadius[25];

			v2f vert(appdata  v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.wpos = mul(unity_ObjectToWorld, v.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				o.WorldNormal = worldNormal;
				worldNormal.y *= 0.3;
				half Dot = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));
				o.diff = Dot;

				UNITY_TRANSFER_SHADOW(o,v.uv);
				return o;
			}


			float _thresholdParam;
			float _DistParam;

			fixed4 frag(v2f i) : SV_Target
			{
				half shadow = SHADOW_ATTENUATION(i);
				half Diff = lerp(_Shade1, _Shade2, i.diff);
				fixed3 lighting = Diff * shadow;
				fixed4 col;
				fixed4 col2 = tex2D(_MainTex, i.uv);
				col = _Color* _GlobalColor * col2;
				if (shadow < 1)
					col *= _ColorShadow;

				float AlphaMax = 0;
				float RippleDist;
				float Radius = 1.5;
				if (dot(i.WorldNormal,float3(0,1,0)) > 0.5)
					for (int a = 0; a < RippleCount; a++)
					{
						RippleDist = length(SoundRipples[a].xyz - i.wpos);
						float RippleDistScaled = RippleDist / (SoundRipples[a].w * Radius* SoundRipplesStartingRadius[a]);
						RippleDistScaled = (RippleDistScaled > 1) ? 0 : RippleDistScaled;

						float FadeParam = (RippleDist) / (SoundRipplesStartingRadius[a]* Radius);
						float A = 1 - abs(RippleDistScaled * RippleDistScaled - 0.9) / 0.1;

						A *= clamp(1 - FadeParam, 0, 1);
						AlphaMax = (A > AlphaMax) ? A : AlphaMax;
					}

				col += fixed4(1, 1, 1, 0) * AlphaMax * 0.25;
				return col * half4(lighting,0);
			}
			ENDCG
		}


		Pass{
			Tags {"LightMode" = "ShadowCaster"}
			Cull back
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#pragma fragmentoption ARB_precision_hint_fastest
			#include "UnityCG.cginc"

			struct v2f {
			V2F_SHADOW_CASTER;
			half3 wpos : TEXCOORD2;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				o.wpos = mul(unity_ObjectToWorld, v.vertex);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float _thresholdParam;
			float _DistParam;

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}
	}


}
