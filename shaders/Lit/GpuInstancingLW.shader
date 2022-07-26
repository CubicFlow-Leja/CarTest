// Upgrade NOTE: upgraded instancing buffer 'InstanceProperties' to new syntax.

// Upgrade NOTE: upgraded instancing buffer 'InstanceProperties' to new syntax.

Shader "Lejashaderi/GpuInstancingLW"
{
    Properties
    {
		_MainColor("Color", Color) = (1,1,1,1)
       // _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags {"LightMode" = "ForwardBase"}


			Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
			#pragma multi_compile_instancing
			//#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"

            struct appdata
            {
		        UNITY_VERTEX_INPUT_INSTANCE_ID
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				UNITY_VERTEX_INPUT_INSTANCE_ID
                //float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;
			UNITY_INSTANCING_BUFFER_START(InstanceProperties)
				//	float4 _Color;
				UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr InstanceProperties
				UNITY_INSTANCING_BUFFER_END(InstanceProperties)
				fixed4 _MainColor;
            v2f vert (appdata v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                o.vertex = UnityObjectToClipPos(v.vertex);

				
				UNITY_TRANSFER_INSTANCE_ID(v, o);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
                return o;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				float3 Color = UNITY_ACCESS_INSTANCED_PROP(InstanceProperties, _Color).rgb;
                fixed4 col = _MainColor * half4(Color,1);
               
                return col;
            }
            ENDCG
        }

		Pass
		{
				Tags {"LightMode" = "ShadowCaster"}
				Cull Off//FIXAT
				CGPROGRAM


				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_instancing
				#pragma multi_compile_shadowcaster
				#pragma fragmentoption ARB_precision_hint_fastest
				#include "UnityCG.cginc"

				struct appdata
				{
					UNITY_VERTEX_INPUT_INSTANCE_ID
					float4 vertex : POSITION;
					//float2 uv : TEXCOORD0;
				};

				struct v2f {
				UNITY_VERTEX_INPUT_INSTANCE_ID
				V2F_SHADOW_CASTER;
				};


				v2f vert(appdata_base v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
						UNITY_TRANSFER_INSTANCE_ID(v, o);
					return o;
				}

				float4 frag(v2f i) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(i);
					SHADOW_CASTER_FRAGMENT(i)
				}

				ENDCG
		}
    }
}
