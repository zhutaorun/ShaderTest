Shader "Unlit/HalfLambert"
{
	Properties
	{
		_BaseColor ("_BaseColor",Color) = (1,1,1,1)
		_BaseMap ("_BaseMap", 2D) = "white" {}
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "Lighting.cginc"

	//===================================属性

	uniform float4 _BaseColor;//基础色
	uniform sampler2D  _BaseMap;//基础色贴图
	uniform float4 _BaseMap_ST;//UV变换参数

	//===================================着色器

	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float3 worldPos : TEXCOORD0;
		half3 normal : TEXCOORD1;
		float2 uv : TEXCOORD2;
	};

	v2f vert (appdata v)
	{
		v2f o;
		o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
		o.pos = UnityWorldToClipPos(o.worldPos);
		o.normal = normalize(mul(v.normal,unity_WorldToObject));
		o.uv = v.texcoord * _BaseMap_ST.xy + _BaseMap_ST.zw;
		return o;
	}
			
	half frag (v2f i) : SV_Target
	{
		//获取基础反射率
		half3 albedo = _BaseColor.rgb;
		albedo *= tex2D(_BaseMap,i.uv).rgb;

		//获取法线
		half3 normal = normalize(i.normal);

		//计算直接光照
		half3 lightDir = normalize(_WorldSpaceLightPos0.xyz-i.worldPos* _WorldSpaceLightPos0.w);//获取光线方向
		half NoL = dot(normal,lightDir) * 0.5 +0.5;//计算法线光线点积
		half3 directDiffuse = albedo * NoL* _LightColor0.rgb;//计算漫反射
		half3 directLight = directDiffuse;

		//计算间接光照
		half3 indirectLight = albedo * UNITY_LIGHTMODEL_AMBIENT.rgb;

		//计算最终结果
		half3 radianceOut = directLight + indirectLight;
		return half4(radianceOut,1);
	}

	ENDCG
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
