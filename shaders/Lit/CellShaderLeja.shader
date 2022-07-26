Shader "Lejashaderi/CellShaderLeja"
{
	Properties
	{

		_Color("Color", Color) = (1,1,1,1)
		//_ColorShadow("_ColorShadow", Color) = (1,1,1,1)
		_Cos("_Cos",float) = 0
		_ColorIntensity("_ColorIntensity",float) = 1

		_Shade1("Shade1",float) = 0
		_Shade2("Shade2",float) = 1
		_MainTex("Texture", 2D) = "white" {}
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

				struct v2f
				{
					half diff : COLOR0;
					half4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					UNITY_SHADOW_COORDS(1)
				};

			
				fixed4 _Color;
				fixed4 _ColorShadow;
				fixed4 _GlobalColor;

				half _Shade1;
				half _Shade2;
				half _Cos;
				half _ColorIntensity;

				sampler2D _MainTex;
				float4 _MainTex_ST;

				struct appdata
				{
					float4 vertex : POSITION;
					float4 normal : NORMAL;
					float2 uv : TEXCOORD0;
					UNITY_SHADOW_COORDS(1)
				};

				v2f vert(appdata  v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					/*o.wpos = mul(unity_ObjectToWorld, v.vertex);
				*/ 
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					half3 worldNormal = UnityObjectToWorldNormal(v.normal);

					//half3 RadialVec1 = o.wpos.xyz - _Pos.xyz;

					half Dot = dot(worldNormal, _WorldSpaceLightPos0.xyz);

				
					o.diff =  (Dot > _Cos) ?  _Shade2 : _Shade1;

					 
				

					UNITY_TRANSFER_SHADOW(o,v.uv);
					return o;
				} 

				//fragment shader
				fixed4 frag(v2f i) : SV_Target
				{
					half shadow = SHADOW_ATTENUATION(i);
					fixed3 lighting = (i.diff)*shadow;
					fixed4 col;

					fixed4 col2 = tex2D(_MainTex, i.uv);
					//else
						col = _Color* _GlobalColor *col2;

						if (shadow < 1)
							col *= _ColorShadow;
						/*col = (length(i.wpos.xyz - _PosLight.xyz) <= _Radius) ? lerp(fixed4(1,1,1,1), col, length(i.wpos.xyz - _PosLight.xyz) / (_Radius)) : col ;
						col = (length(i.wpos.xyz - _PosDark.xyz) <= _Radius) ? lerp(fixed4(0,0,0,1), col, length(i.wpos.xyz - _PosDark.xyz) / (_Radius)) : col ;*/

					return col*half4(lighting,0)* _ColorIntensity;
					return fixed4(1, 1, 1, 1);
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
