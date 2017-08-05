// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter6/ BlinnPhong-UseBuildInFunction" {
Properties {
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase" }
			LOD 200
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f o;
				//Transform the vertex from object space to projection space
				o.pos = UnityObjectToClipPos(v.vertex);

				//Use the build-in function t compute the normal in world space 
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//Transform the vertex from object space to world space
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				//Get the ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				//Use the build-in function to compute the light direction in world space
				//Rember to normalize the result
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				//Get the reflect direction in world space
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				//Use the build-in function to compute the view direction in world space
				//Rember to normal the result
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//Get the half direction in world space 
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				//Compute specular term
				fixed3 specular = _LightColor0.rgb *_Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				return fixed4(ambient+diffuse+specular,1.0);
			}

			ENDCG
		}
	}
	FallBack "Specular"
}