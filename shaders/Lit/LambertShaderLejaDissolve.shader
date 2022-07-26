Shader "Lejashaderi/LambertShaderLejaDissolve"
{
	Properties
	{
		_DissolveTex("_DissolveTex", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_DissolveColor("_DissolveColor", Color) = (1,1,1,1)
		//_ColorShadow("_ColorShadow", Color) = (1,1,1,1)
		_Cos("_Cos",float) = 0

		_Shade1("Shade1",float) = 0
		_Shade2("Shade2",float) = 1
		_DissolveParam("_DissolveParam",float) = 0.25
		_DissolveFactor("_DissolveFactor",float) = 0.25
		_DissolveIntensity("_DissolveIntensity",float) =1

		_DistortionTex("Distortion", 2D) = "white" {}
		_DistortionAmount("DistortionAmount", Range(0, 1)) = 0.02
		_DisplacementSpeed("_DisplacementSpeed", Vector) = (0.005, 0.005, 0, 0)


	}
		SubShader
		{
			

			Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}

			Pass
			{
				Tags {"LightMode" = "ForwardBase"}


				Cull Off//FIXAT
				
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
					half diff : COLOR0;
					//half3 ambient : COLOR1;
					half4 pos : SV_POSITION;
					//half3 wpos : TEXCOORD1;
					float2 uv : TEXCOORD2;
					float2 distortUV : TEXCOORD3;
					UNITY_SHADOW_COORDS(1)
				};

				sampler2D _DissolveTex;
				float4 _DissolveTex_ST;

				fixed4 _Color;
				fixed4 _ColorShadow;
				fixed4 _GlobalColor;
				fixed4 _DissolveColor;
				half _Shade1;
				half _Shade2;
				half _Cos;
				half _DissolveFactor;
				half _DissolveParam;
				half _DissolveIntensity;


				//half4 _Pos;
				//half _Radius;
				//half _Intensity;
				
				sampler2D _DistortionTex;
				float4 _DistortionTex_ST;
				half _DistortionAmount;
				float4  _DisplacementSpeed;



				v2f vert(appdata  v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					//o.wpos = mul(unity_ObjectToWorld, v.vertex);
				
					//half3 worldNormal = UnityObjectToWorldNormal(v.normal);

					//half3 RadialVec1 = o.wpos.xyz - _Pos.xyz;
					half3 worldNormal = UnityObjectToWorldNormal(v.normal);
					worldNormal.y *= 0.3;
					half Dot = saturate(dot(worldNormal, _WorldSpaceLightPos0.xyz));

					o.diff = Dot;

					//half Dot = dot(worldNormal, _WorldSpaceLightPos0.xyz);

				
					//o.diff =  (Dot > _Cos) ?  _Shade2 : _Shade1;
					o.uv = TRANSFORM_TEX(v.uv, _DissolveTex);

					o.distortUV = TRANSFORM_TEX(v.uv, _DistortionTex);
					//ambient lighting
					//o.ambient = ShadeSH9(half4(worldNormal, 1));

					UNITY_TRANSFER_SHADOW(o,v.uv);
					return o;
				} 

				//fragment shader
				fixed4 frag(v2f i) : SV_Target
				{
					half shadow = SHADOW_ATTENUATION(i);
					half Diff = lerp(_Shade1, _Shade2, i.diff);
					fixed3 lighting = Diff *shadow;
					//fixed3 lighting = (i.diff)*shadow;
					
					
					
					fixed4 col;
					col = _Color* _GlobalColor;

					float2 distortSample = (tex2D(_DistortionTex, i.distortUV).xy * 2 - 1) *_DistortionAmount;
					float2 MainTexUv = float2(i.uv.x + _Time.y * _DisplacementSpeed.x + distortSample.x, i.uv.y + _Time.y * _DisplacementSpeed.y + distortSample.y);

					fixed4 DissColor = tex2D(_DissolveTex, MainTexUv);
					float dis = DissColor.r + DissColor.g + DissColor.b;
					if (DissColor.r + DissColor.g + DissColor.b > _DissolveFactor )
					{
						if (DissColor.r + DissColor.g + DissColor.b > _DissolveFactor + _DissolveParam)
							clip(-1);
							
						else
							col = _DissolveColor * _GlobalColor* _DissolveIntensity;
					}
					

						

					if (shadow < 1)
							col *= _ColorShadow;
					//col=((length(i.wpos.xyz - _Pos.xyz) < _Radius) ? lerp(_Intensity, 0, length(i.wpos.xyz - _Pos.xyz) / (_Radius)) : 0.0f)*_Color;
				
					return col*half4(lighting,0);
				}
				ENDCG
			}

			
			Pass{
				Tags {"LightMode" = "ShadowCaster"}
				Cull Off//FIXAT
				CGPROGRAM
					

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_shadowcaster
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float4 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};

				struct v2f {
				V2F_SHADOW_CASTER;
				float2 uv : TEXCOORD2;
				float2 distortUV : TEXCOORD3;
				};

				half _DissolveFactor;
				half _DissolveParam;
				sampler2D _DissolveTex;
				float4 _DissolveTex_ST;


				sampler2D _DistortionTex;
				float4 _DistortionTex_ST;
				half _DistortionAmount;
				float4  _DisplacementSpeed;

				v2f vert(appdata v)
				{
					v2f o;
					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
					o.uv = TRANSFORM_TEX(v.uv, _DissolveTex);
					o.distortUV = TRANSFORM_TEX(v.uv, _DistortionTex);
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					float2 distortSample = (tex2D(_DistortionTex, i.distortUV).xy * 2 - 1) *_DistortionAmount;
					float2 MainTexUv = float2(i.uv.x + _Time.y * _DisplacementSpeed.x + distortSample.x, i.uv.y + _Time.y * _DisplacementSpeed.y + distortSample.y);

					fixed4 DissColor = tex2D(_DissolveTex, MainTexUv);
					float dis = DissColor.r + DissColor.g + DissColor.b;

					if (DissColor.r + DissColor.g + DissColor.b > _DissolveFactor + _DissolveParam)
						clip(-1);
						
					SHADOW_CASTER_FRAGMENT(i)
				}

				ENDCG
			}
		}


}
