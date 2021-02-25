Shader "Custom/ShaderSquareToCircleSquare" {
	//参考 https://blog.csdn.net/u014361280/article/details/105256487
	Properties {
		_Color ("主颜色", Color) = (1,1,1,1)
		_MainTex ("主贴图", 2D) = "white" {}
		_CircleSuqareRadius("圆角半径",Range(0,0.5)) = 0.25 //UV的一半
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

		pass{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag 

		#include "UnityCG.cginc"

		sampler2D _MainTex;
		fixed _CircleSuqareRadius;
		fixed4 _Color;

		struct v2f {
			float4 pos:SV_POSITION;
			float2 srcUV:TEXCOORD0; 	//原本的uv
			float2 adaptUV:TEXCOORD1;  	//用来调整方便计算的UV
		};

		v2f vert( appdata_base v){
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.srcUV = v.texcoord;

			//调整uv(原本0，1)为-0.5到0.5，所以原点就在图中央点（未调整是左下角）
			o.adaptUV = v.texcoord - float2 (0.5,0.5);

			return o;
		}

		fixed4 frag(v2f i):COLOR
		{
			fixed4 col = fixed4(0,0,0,0);

			//首先绘制中间部分(在设置圆角半径里面的)(adaptUV x y 绝对值小于0.5- 圆角半径内的区域)
			if(abs(i.adaptUV).x<(0.5-_CircleSuqareRadius)|| abs(i.adaptUV).y<(0.5-_CircleSuqareRadius)){
				col = tex2D(_MainTex,i.srcUV);
			}
			else{
				//其次四个圆角部分(相当于以(0.5-圆角半径，0.5-圆角半径)为圆心，把uv在圆角半径内的uv绘制出来)
				//超出的部分忽略掉
				if(length(abs(i.adaptUV)-float2(0.5-_CircleSuqareRadius,0.5-_CircleSuqareRadius))<_CircleSuqareRadius){
					col = tex2D(_MainTex,i.srcUV);
				}else{
					discard;
				}
			}

			//混合主颜色，并返回
			return col*_Color;
		}
		ENDCG
	}
}
	FallBack "Diffuse"
}
