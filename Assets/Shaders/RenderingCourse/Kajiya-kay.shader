Shader "Kajiya-kay"
{
	Properties
	{
		_Color("_Color",Color) = (1,0.9,0.8,1)
		_MainTex ("_MainTex", 2D) = "white" {}
		[NoScaleOffset]_SpecSSM("_SpecSSM",2D) = "gray"{}

		_SpecCol1("_SpecCol1",Color) = (1,1,1,1)
		_SpecExp1("_SpecExp1",Range(32,265)) = 64
		_PrimaryShift1("_PrimaryShift",Range(-1,1)) = 0.0

		_SpecCol2("_SpecCol2",Color) = (1,0.8,0.6,1)
		_SpecExp2("_SpecExp2",Range(32,256)) = 64
		_SecondaryShift("_SecondaryShift",Range(-1,1))=-0.3
	}
	CGINCLUDE

	#include "UnityCG.cginc"
	#include "Lighting.cginc"

	float4 _Color;
	sampler2D _MainTex;
	float4 _MainTex_ST;
	sampler2D _SpecSSM;

	float4 _SpecCol1;
	float _SpecExp1;
	float _PrimaryShift;

	float4 _SpecCol2;
	float _SpecExp2;
	float _SecondaryShift;

	//各向异性
	half StrandSpecular(half3 T,half3 H,half exponent)
	{
		half ToH = clamp(dot(T,H),-1.0,1.0);//半角向量与切线的cos值，用clamp防止算出NaN
		half NoH = sqrt(1.0-ToH*ToH);//半角向量与切线的sin值
		half dirAtten = smoothstep(-1.0,0.0,ToH);//切线方向衰减，半角向量越靠近发根方向，由于头发构造导致粗糙度提高，从而高光减弱（猜测）
		return dirAtten * pow(NoH,exponent);//Blinn-Phong高光公式
	}

	//偏移切线
	half3 ShiftTangent(half3 T,half3 N,half shift)
	{
		return normalize(T + shift*N);
	}

	//头发光照
	half4 HairLighting(half3 tangent,half3 normal,half3 viewDir,half3 lightDir,half3 lightCol,half2 uv,half ao)
	{
		half NoL = saturate(dot(normal,lightDir));
		//高光
		half3 ssm = tex2D(_SpecSSM,uv).rgb;
		half specShift = ssm.g - 0.5;//切线偏移噪声
		half specMask = ssm.b;//第二层高光遮罩
		half3 t1 = ShiftTangent(tangent,normal,_PrimaryShift+specShift);//第一层高光切线
		half3 t2 = ShiftTangent(tangent,normal,_SecondaryShift +specShift);//第二层高光切线
		half3 H = normalize(viewDir + lightDir);//半角向量
		half spec = _SpecCol1.rgb* StrandSpecular(t1,H,_SpecExp1);//第一层高光
		spec += _SpecCol2.rgb * specMask * StrandSpecular(t2,H,_SpecExp2);//第二层高光
		spec *= smoothstep(0.0,0.15,NoL);//解决Blinn-Phong的背光问题
		//漫反射
		half4 baseCol = tex2D(_MainTex,uv)*_Color;
		half3 diff = baseCol.rgb * saturate(lerp(0.25,1.0,NoL));//漫反射光照，这里使用特殊的NoL,以表现头发的通透感
		//环境光
		half amb = baseCol.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb;
		//结果
		half3 col = ((diff+spec)*lightCol+amb)*ao;
		return half4(col,baseCol.a);
	}

	struct appdata
	{
		float4 vertex:POSITION;
		float3 normal:NORMAL0;
		float4 tangent:TANGENT0;
		float2 texcoord:TEXCOORD0;
	};

	struct v2f
	{
		float4 pos:SV_POSITION;
		float3 worldPos:TEXCOORD0;
		float3 normal:TEXCOORD1;
		float3 tangent:TEXCOORD2;
		float3 binormal:TEXCOORD3;
		float2 uv:TEXCOORD4;
	};

	v2f vert(appdata v)
	{
		v2f o;
		o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
		o.pos = UnityWorldToClipPos(float4(o.worldPos,1.0));
		o.normal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
		o.tangent = normalize(mul((float3x3)unity_ObjectToWorld,v.tangent.xyz));
		o.binormal = cross(o.normal,o.tangent)* v.tangent.w;
		o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
		return o;
	}

	half4 frag(v2f i):SV_Target
	{
		half3 normal = normalize(i.normal);
		half3 tangent = normalize(i.binormal);//模型切线垂直于发丝，所以用副切线，若模型切线平行于发丝则直接用切线
		half3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
		half3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		half4 res = HairLighting(tangent,normal,viewDir,lightDir,_LightColor0.rgb,i.uv,1.0);
		return res;
	}
	ENDCG

	SubShader
	{
		Tags{"Queue" = "Transparent"}
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			Cull Back
			ZWrite Off
			ZTest LEqual
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
