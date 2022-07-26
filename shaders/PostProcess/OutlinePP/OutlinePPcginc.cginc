#include "UnityCG.cginc"

/*
bool CheckDelta(float d1,float d2,float _Scale)
{
	if (abs(d1-d2)> _Scale)
	{
		return true;
	}
	else
	{
		return false;
	}
}*/

float Calc(float d1, float d2, float d3, float d4, float d,float _Scale)
{
	/*
	if(CheckDelta(d,d1, _Scale))
		return true;
	if (CheckDelta(d, d2, _Scale))
		return true;
	if (CheckDelta(d, d3, _Scale))
		return true;
	if (CheckDelta(d, d4, _Scale))
		return true;
	
	return false;
	*/
	/*
	float D1 = d1 - d3;
	float D2 = d2 - d4;
	return abs(D1 + D2) > _Scale;
	*/
	//float D = abs(d - d1) + abs(d - d2) + abs(d - d3) + abs(d - d4);

	float D = abs(4.0*d - d1  - d2  - d3 - d4);//puno mocnija metoda i optimiziranija

	return D *_Scale;
	
}


float CalculateOutline(sampler2D DepthTex,float2 PixelCoord,float4 _TexelSize,float _Scale,float Dist)
{
	//persp
	/*float d = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord)));
	float d1= LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(_TexelSize.x*Dist, _TexelSize.y*Dist))));
	float d2= LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(-_TexelSize.x*Dist, _TexelSize.y*Dist))));
	float d3= LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(_TexelSize.x*Dist, -_TexelSize.y*Dist))));
	float d4= LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(-_TexelSize.x*Dist,-_TexelSize.y*Dist))));*/

	
	float temp = 0;
	float d = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord)));
	for (int i = 1; i <= Dist; i++)
	{
		//persp
	/*	float d1= Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(_TexelSize.x*Dist, _TexelSize.y*Dist))));
		float d2= Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(-_TexelSize.x*Dist, _TexelSize.y*Dist))));
		float d3= Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(_TexelSize.x*Dist, -_TexelSize.y*Dist))));
		float d4= Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord+float2(-_TexelSize.x*Dist,-_TexelSize.y*Dist))));

		float d5 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(0, _TexelSize.y * Dist))));
		float d6 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(_TexelSize.x * Dist, 0))));
		float d7 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(0, -_TexelSize.y * Dist))));
		float d8 = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(-_TexelSize.x * Dist, 0))));*/

		////ortho
		float d = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord));
		float d1 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(_TexelSize.x*(i + 1), _TexelSize.y*(i + 1))));
		float d2 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(-_TexelSize.x*(i + 1), _TexelSize.y*(i + 1))));
		float d3 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(_TexelSize.x*(i + 1), -_TexelSize.y*(i + 1))));
		float d4 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(-_TexelSize.x*(i + 1), -_TexelSize.y*(i + 1))));
		temp+= Calc(d1, d2, d3, d4, d, _Scale);
		//temp+= Calc(d5, d6, d7, d8, d, _Scale);
	}
	/*float d = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord));
	float d1 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(_TexelSize.x*Dist, _TexelSize.y*Dist)));
	float d2 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(-_TexelSize.x*Dist, _TexelSize.y*Dist)));
	float d3 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(_TexelSize.x*Dist, -_TexelSize.y*Dist)));
	float d4 = UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord + float2(-_TexelSize.x*Dist, -_TexelSize.y*Dist)));*/
	
	//float z = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(DepthTex, PixelCoord)));
	//z /= 1.2f;
	//float viewDistance = z- _WorldSpaceCameraPos.z;*/
	//return Calc(d1,d2,d3,d4,d, _Scale);


	//float DistanceBased = 1-clamp( d+0.45,0,1);//0.5 triba bit threshold nekakav 

	//return temp* 1;
	return clamp( 1-temp,0,0.1);
}