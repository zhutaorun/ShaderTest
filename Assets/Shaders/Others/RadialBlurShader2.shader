// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Others/Radial Blur Shader2" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurTex ("Blur Tex", 2D) = "white" {}
	}
	SubShader {
		CGINCLUDE
		uniform sampler2D _MainTex;
		uniform sampler2D _BlurTex;
		uniform float _BlurFactor;
		uniform float _LerpFactor; //插值的强度(0-1)
		uniform float4 _BlurCenter;
		float4 _MainTex_TexelSize;
		#include "UnityCG.cginc"
		#define SAMPLE_COUNT 6

		fixed4 frag_blur(v2f_img i):SV_Target{
			//模糊方向为模糊中点指向边缘(当前像素点),而越边缘该值越大,越模糊
			float2 dir = i.uv - _BlurCenter.xy;
			float4 outColor = 0;
			//采样SAMPLE_COUNT次
			for(int j=0;j<SAMPLE_COUNT;++j)
			{
				//计算采样uv值:正常uv值+从中间向边缘逐渐增加的采样距离
				float2 uv = i.uv + _BlurFactor*dir*j;
				outColor += tex2D(_MainTex,uv);
			}
			//取平均值
			outColor /= SAMPLE_COUNT;

			return  outColor;
		} 

		//定义最后插值使用的结构体
		struct v2f_lerp{
			float4 pos:SV_POSITION;
			float2 uv1:TEXCOORD0;
			float2 uv2:TEXCOORD1; 
		}; 

		v2f_lerp vert_lerp(appdata_img v){
			v2f_lerp o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv1 = v.texcoord.xy;
			o.uv2 = v.texcoord.xy;
			//dx中纹理从左上角为初始坐标,需要反向(在写rt的时候需要注意)
			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y<0)
				o.uv2.y = 1- o.uv2.y;
			#endif
			return  o;
		}

		fixed4 frag_lerp(v2f_lerp i):SV_Target{
			float2 dir = i.uv1 -_BlurCenter.xy;
			float dis = length(dir);
			fixed4 oriTex = tex2D(_MainTex,i.uv1);
			fixed4 blurTex = tex2D(_BlurTex,i.uv2);
			//按照距离乘以插值系数在原图和模糊图之间差值
			return lerp(oriTex,blurTex,_LerpFactor* dis);
		}
		ENDCG

		Pass {
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{Mode off}

			CGPROGRAM
			#pragma fragmentoption  ARB_precision_hint_fastest  
			#pragma vertex vert_img
			#pragma fragment frag_blur 
			ENDCG 
		}

		Pass{
			ZTest Always
			Cull Off
			ZWrite Off
			Fog{Mode off}
			CGPROGRAM
			
			#pragma fragmentoption  ARB_precision_hint_fastest 
			#pragma vertex vert_lerp
			#pragma fragment frag_lerp   
			ENDCG  
		}
	}
	FallBack off
}
