Shader "LejaGPU/GPUParticleShader"//triba shadowcaster cisto da iman outline
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
	}
		SubShader
		{
			Tags{ "RenderType" = "Transparent" "Queue" = "Transparent"  }
			LOD 100
			Pass
			{
				ZWrite Off
				//Blend SrcAlpha OneMinusSrcAlpha
				CGPROGRAM

	
				#pragma vertex vert
				#pragma fragment frag

				#pragma multi_compile_instancing
				#pragma instancing_options procedural:vertInstancingSetup

				#include "UnityCG.cginc"
				#include "UnityStandardParticleInstancing.cginc"
				#include "AutoLight.cginc"
				#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
				struct appdata
				{
					float4 vertex : POSITION;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};
				struct v2f
				{
					float4 vertex : SV_POSITION;
					UNITY_SHADOW_COORDS(1)
					//half3 wpos : TEXCOORD1;
					
				};
			
				fixed4 _Color;

				//half4 _Pos;
				//half _Radius;

				fixed4 _ColorShadow;
				fixed4 _GlobalColor;

				v2f vert(appdata v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);

					//o.wpos = mul(unity_ObjectToWorld, v.vertex);

					o.vertex = UnityObjectToClipPos(v.vertex);
					UNITY_TRANSFER_SHADOW(o, v.uv);
					return o;
				}

				fixed4 frag(v2f i) : SV_Target
				{
					
					//float Length = length(i.wpos.xyz - _Pos.xyz);

					//fixed LenFac = (Length < _Radius) ? lerp(1, 0.3, Length / (_Radius)) : 0.05f;
					half shadow = SHADOW_ATTENUATION(i);
					fixed4 col = _Color * _GlobalColor;
					if (shadow < 1)
						col *= _ColorShadow;

						return col * shadow;// *LenFac;
					}

				ENDCG
			}
		}
}