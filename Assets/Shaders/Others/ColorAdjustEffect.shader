//Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ColorAdjustEffect" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Brightness ("Brightness", Float) = 1
		_Saturation ("Saturation",Float) = 1
		_Contrast ("Contrast",Float) = 1
	}
	SubShader {
		Pass{
			ZTest Always Cull Off ZWrite Off

			CGPROGRAM
			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"  

			//从vertex shader 传入pixel shader的参数
			struct v2f{
				float4 pos:SV_POSITION;
				half2 uv:TEXCOORD0; 
			};  

			//vertex shader
			//appdata_img;带有位置和一个纹理坐标的顶点着色器输入
			v2f vert(appdata_img v){
				v2f o;
				//从自身空间转向投影空间
				o.pos = UnityObjectToClipPos(v.vertex);
				//uv坐标赋值给output
				o.uv = v.texcoord;
				return o;
			}

			//fragment shader
			fixed4 frag(v2f i):SV_Target{
				//从MainTex 中根据uv坐标进行采样
				fixed4 renderTex = tex2D(_MainTex,i.uv);
				//brigtness亮度直接乘以一个系数，也就是RGB整体缩放，调整亮度
				fixed3 finalColor = renderTex * _Brightness;
				//saturation饱和度:首先根据公式计算同等亮度情况下饱和度最低的值;
				fixed gray = 0.2125* renderTex.r +0.7154* renderTex.g +0.0721*renderTex.b;
				fixed3 grayColor = fixed3(gray,gray,gray);
				//根据Saturation在饱和度最低的图像和原图之间差值
				finalColor =lerp(grayColor,finalColor,_Saturation);
				//contrast对比度:首先计算对比度最低的值
				fixed3 avgColor = fixed3(0.5,0.5,0.5);
				//根据Contrast在对比度最低的图像和原图之间差值
				finalColor = lerp(avgColor,finalColor,_Contrast);
				//返回结果，alpha通道不变
				return fixed4(finalColor,renderTex.a);
			}
			ENDCG 
		}
	}
	FallBack Off
}
