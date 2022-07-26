Shader "Lejashaderi/LejaTransparent"
{
	Properties
	{

		_Color("Color", Color) = (1,1,1,1)
		_ColorStrength("_ColorStrength",float) = 1

	}
		SubShader
		{
			

			Tags { "RenderType" = "Transparent" }// "Queue" = "Overlay" }

			Pass
			{
				Tags {"LightMode" = "ForwardBase"}


				//Cull Off//FIXAT
				Cull Off
				//ZTest Always
				//ZWrite On
				//Blend SrcAlpha SrcColor
				//Blend DstAlpha SrcColor
				//Blend One One
				//Blend OneMinusDstColor One
				//Blend DstColor Zero
				//Blend DstColor SrcColor
				//Blend SrcAlpha OneMinusSrcAlpha
				//Blend One OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "AutoLight.cginc"

				struct v2f
				{
					half3 ambient : COLOR1;
					half4 pos : SV_POSITION;
				};

			
				fixed4 _Color;
			
				half _ColorStrength;


			
				v2f vert(appdata_base  v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.ambient = ShadeSH9(half4(half3(0,1,0), 1));
					return o;
				} 

			
				fixed4 frag(v2f i) : SV_Target
				{
					fixed3 lighting =  i.ambient;

					
					fixed4 col;

					col = _Color* _ColorStrength;

					return col*half4(lighting,1);
				}
				ENDCG
			}

		}


}
