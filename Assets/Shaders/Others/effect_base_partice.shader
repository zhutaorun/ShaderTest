Shader "Effect/Base_Partice"{
	Properties{
		_NoAlpha ("NoAlpha", float ) = 0
		_OffsetFactor("OffsetFactor",Int) = 0
		_OffsetUnit("OffsetUnit",Int) = 0
		_MainTex("Main Tex", 2D) = "white" {}
		_FixColor("FixColor",COLOR) = (1,1,1,1)
		_Brightness("Brightness", Float) = 1
		_MianTexPannerX("Main Tex Panner X", Float) = 0
		_MianTexPannerY("Main Tex Panner Y", Float) = 0
		_ClipRect("ClipRect",Vector) = (0,0,0,0)
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
		[Enum(UnityEngine.Rendering.BlendMode)] SrcBlend ("SrcBlend", Float) = 5 //SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)] DstBlend ("DstBlend", Float) = 1 //One
	}
	SubShader {
		Tags {
			"IgnoreProjector" = "True"
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}

		Pass
		{
			Name "FORWARD"
			Tags { 
				"LightMode" = "FORWARDBase"
			}

			Offset[_OffsetFactor],[_OffsetUnit]
			Blend [SrcBlend] [DstBlend] 
			Cull Off
			ZWrite Off
			ZTest [_ZTest]

			CGPROGRAM
		    #pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase
			#pragma multi_compile __ ForUIUse
			#pragma multi_compile __ UI_CLIP

			//如果需要mask裁切请复制下述代码 begin
			#include "UnityUI.cginc" 
			//如果需要mask裁切请复制下述代码 end

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _FixColor;
			uniform float _Brightness;
			uniform float _MianTexPannerX;
			uniform float _MianTexPannerY;
			float4 _ClipRect;

			uniform float _NoAlpha;

			struct VertexInput {
				float4 vertex : POSITION;
				float2 textcoord0 : TEXCOORD0;
				float4 vertexColor : COLOR;
			};

			struct VertexOutput {
				float4 pos : POSITION;
				float2 uv0 : TEXCOORD0;
				float4 vertexColor : COLOR;
				#ifdef UI_CLIP
				float2 worldPosition : TEXCOORD2; //此处按需  
				#endif 	
			};

			VertexOutput vert (VertexInput v){
				VertexOutput o = (VertexOutput)0;
				o.uv0 = (TRANSFORM_TEX(v.textcoord0,_MainTex) + float2 (_MianTexPannerX,_MianTexPannerY)* _Time.y);
				o.vertexColor = v.vertexColor;
				o.pos = UnityObjectToClipPos(v.vertex );

				#ifdef UI_CLIP
				//如果需要mask裁切请复制下述代码 begin
				o.worldPosition = mul(unity_ObjectToWorld,v.vertex).xy;
				//如果需要mask裁切请复制下述代码 end
				#endif 

				return o;
			}

			float4 frag(VertexOutput i):SV_Target{
				float4 _MainTex_var = tex2D(_MainTex,i.uv0);
				float3 emissive = _Brightness * _MainTex_var.rgb * i.vertexColor.rgb * _FixColor.rgb;
				float a = 0;
				#ifdef ForUIUse
				a = i.vertexColor.a * _FixColor.a *(_NoAlpha >0.01? saturate(length(emissive)):_MainTex_var.a);
				#else
				a = i.vertexColor.a * _FixColor.a * _MainTex_var.a;
				#endif

				#ifdef UI_CLIP
				a *= UnityGet2DClipping(i.worldPosition.xy,_ClipRect);

				clip(a - 0.001);
				#endif

				return float4(emissive,a);
			}
			ENDCG  
		}
	}
}
