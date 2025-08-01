﻿Shader "Jupiter/Sky"
{
	Properties
	{
		_SkyColor("Sky Color", Color) = (0.15, 0.4, 0.65, 1)
		_HorizonColor("Horizon Color", Color) = (1, 1, 1, 1)
		_GroundColor("Ground Color", Color) = (0.4, 0.4, 0.4, 1)
		_HorizonThickness("Horizon Thickness", Range(0.0, 1.0)) = 0.3
		_HorizonExponent("Horizon Exponent", Float) = 1.0
		_HorizonStep("Horizon Step", Float) = 25
		_FogColor("Custom Fog Color", Color) = (0, 0, 0, 1)

		_StarsStartPosition("Stars Start", Float) = 0.3
		_StarsEndPosition("Stars End", Float) = 1
		_StarsOpacity("Stars Opacity", Float) = 1

		_StarsColor0("Stars Color 0", Color) = (1, 1, 1, 1)
		_StarsColor1("Stars Color 1", Color) = (1, 1, 1, 1)
		_StarsColor2("Stars Color 2", Color) = (1, 1, 1, 1)

		_StarsDensity0("Stars Density 0", Float) = 1
		_StarsDensity1("Stars Density 1", Float) = 1
		_StarsDensity2("Stars Density 2", Float) = 1

		_StarsSize0("Stars Size 0", Float) = 1
		_StarsSize1("Stars Size 1", Float) = 1
		_StarsSize2("Stars Size 2", Float) = 1

		_StarsGlow0("Stars Glow 0", Float) = 0
		_StarsGlow1("Stars Glow 1", Float) = 0
		_StarsGlow2("Stars Glow 2", Float) = 0

		_StarsTwinkle0("Stars Twinkle 0", Float) = 1
		_StarsTwinkle1("Stars Twinkle 1", Float) = 1
		_StarsTwinkle2("Stars Twinkle 2", Float) = 1

		_StarsCubemap("Stars Cubemap", CUBE) = "any" {}
		_StarsTwinkleMap("Stars Twinkle Map", 2D) = "white" {}

		_SunTex("Sun Texture", 2D) = "white" {}
		_SunColor("Sun Color", Color) = (1, 1, 1, 1)
		_SunSize("Sun Size", Float) = 0.1
		_SunSoftEdge("Sun Soft Edge", Float) = 0
		_SunGlow("Sun Glow", Float) = 0
		_SunDirection("Sun Direction", Vector) = (-1, -1, -1, 0)
		_SunCubemap("Sun Cubemap", CUBE) = "any" {}
		_SunLightColor("Sun Light Color", Color) = (1,1,1,1)
		_SunLightIntensity("Sun Light Intensity", Float) = 1

		_MoonTex("Moon Texture", 2D) = "white" {}
		_MoonColor("Moon Color", Color) = (1, 1, 1, 1)
		_MoonSize("Moon Size", Float) = 0.1
		_MoonSoftEdge("Moon Soft Edge", Float) = 0
		_MoonGlow("Moon Glow", Float) = 0
		_MoonDirection("Moon Direction", Vector) = (1, 1, 1, 0)
		_MoonCubemap("Moon Cubemap", CUBE) = "any" {}
		_MoonLightColor("Moon Light Color", Color) = (1,1,1,1)
		_MoonLightIntensity("Moon Light Intensity", Float) = 1

		_HorizonCloudColor("Horizon Cloud Color", Color) = (1, 1, 1, 0.5)
		_HorizonCloudStartPosition("Horizon Cloud Start", Float) = -0.1
		_HorizonCloudEndPosition("Horizon Cloud End", Float) = 0.5
		_HorizonCloudSize("Horizon Cloud Size", Float) = 10
		_HorizonCloudStep("Horizon Cloud Step", Float) = 25
		_HorizonCloudAnimationSpeed("Horizon Cloud Animation Speed", Float) = 1

		_OverheadCloudColor("Overhead Cloud Color", Color) = (1, 1, 1, 0.5)
		_OverheadCloudAltitude("Overhead Cloud Altitude", Float) = 1000
		_OverheadCloudSize("Overhead Cloud Size", Float) = 100
		_OverheadCloudStep("Overhead Cloud Step", Float) = 25
		_OverheadCloudAnimationSpeed("Overhead Cloud Animation Speed", Float) = 1
		_OverheadCloudFlowSpeed("Overhead Cloud Flow Speed", Float) = 1
		_OverheadCloudFlowDirectionX("Overhead Cloud Flow X", Float) = 1
		_OverheadCloudFlowDirectionZ("Overhead Cloud Flow X", Float) = 1
		_OverheadCloudRemapMin("Overhead Cloud Remap Min", Float) = 0
		_OverheadCloudRemapMax("Overhead Cloud Remap Max", Float) = 1

		_DetailOverlayTintColor("Detail Overlay Color", COLOR) = (1, 1, 1, 0.5)
		_DetailOverlayCubemap("Detail Overlay Cubemap", CUBE) = "any" {}
		_DetailOverlayLayer("Detail Overlay Layer", Float) = 0
		_DetailOverlayRotationSpeed("Detail Overlay Rotation Speed", Float) = 0

	}
	SubShader
	{
		Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
		Cull Off ZWrite Off
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing

			#pragma shader_feature_local STARS
			#pragma shader_feature_local STARS_LAYER_0
			#pragma shader_feature_local STARS_LAYER_1
			#pragma shader_feature_local STARS_LAYER_2
			#pragma shader_feature_local STARS_BAKED

			#pragma shader_feature_local SUN
			#pragma shader_feature_local SUN_USE_TEXTURE
			#pragma shader_feature_local SUN_BAKED

			#pragma shader_feature_local MOON
			#pragma shader_feature_local MOON_USE_TEXTURE
			#pragma shader_feature_local MOON_BAKED

			#pragma shader_feature_local HORIZON_CLOUD
			#pragma shader_feature_local OVERHEAD_CLOUD
			#pragma shader_feature_local DETAIL_OVERLAY
			#pragma shader_feature_local DETAIL_OVERLAY_ROTATION
			#pragma shader_feature_local ALLOW_STEP_EFFECT

			#include "UnityCG.cginc"
			#include "./CGIncludes/JCommon.cginc"
			#include "./CGIncludes/JSkyGradient.cginc"
			#include "./CGIncludes/JStars.cginc"
			#include "./CGIncludes/JSunMoon.cginc"			
			#include "./CGIncludes/JHorizonCloud.cginc"
			#include "./CGIncludes/JOverheadCloud.cginc"
			#include "./CGIncludes/JDetailOverlay.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 localPos : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform fixed4 _SkyColor;
			uniform fixed4 _HorizonColor;
			uniform fixed4 _GroundColor;
			uniform fixed _HorizonThickness;
			uniform fixed _HorizonExponent;
			uniform fixed _HorizonStep;
			uniform fixed4 _FogColor;

			#if STARS
				uniform fixed _StarsOpacity;
				#if STARS_BAKED
					uniform samplerCUBE _StarsCubemap;
					uniform sampler2D _StarsTwinkleMap;
				#else
					uniform float _StarsStartPosition;
					uniform float _StarsEndPosition;

					uniform fixed4 _StarsColor0;
					uniform fixed4 _StarsColor1;
					uniform fixed4 _StarsColor2;

					uniform float _StarsDensity0;
					uniform float _StarsDensity1;
					uniform float _StarsDensity2;

					uniform float _StarsSize0;
					uniform float _StarsSize1;
					uniform float _StarsSize2;

					uniform fixed _StarsGlow0;
					uniform fixed _StarsGlow1;
					uniform fixed _StarsGlow2;

					uniform fixed _StarsTwinkle0;
					uniform fixed _StarsTwinkle1;
					uniform fixed _StarsTwinkle2;
				#endif //STARS_BAKED
			#endif //STARS

			#if SUN
				#if SUN_BAKED
					uniform samplerCUBE _SunCubemap;
					uniform float4x4 _SunRotationMatrix;
				#else
					#if SUN_USE_TEXTURE
						uniform sampler2D _SunTex;
						uniform float4x4 _PositionToSunUV;
					#endif //SUN_USE_TEXTURE
					uniform fixed4 _SunColor;
					uniform float _SunSize;
					uniform fixed _SunSoftEdge;
					uniform fixed _SunGlow;
					uniform float4 _SunDirection;
					uniform float4 _SunLightColor;
					uniform float4 _SunLightIntensity;
				#endif //SUN_BAKED
			#endif //SUN

			#if MOON
				#if MOON_BAKED
					uniform samplerCUBE _MoonCubemap;
					uniform float4x4 _MoonRotationMatrix;
				#else
					#if MOON_USE_TEXTURE
						uniform sampler2D _MoonTex;
						uniform float4x4 _PositionToMoonUV;
					#endif //MOON_USE_TEXTURE
					uniform fixed4 _MoonColor;
					uniform float _MoonSize;
					uniform fixed _MoonSoftEdge;
					uniform fixed _MoonGlow;
					uniform float4 _MoonDirection;
					uniform float4 _MoonLightColor;
					uniform float4 _MoonLightIntensity;
				#endif //MOON_BAKED
			#endif //MOON

			#if HORIZON_CLOUD
				uniform fixed4 _HorizonCloudColor;
				uniform fixed _HorizonCloudStartPosition;
				uniform fixed _HorizonCloudEndPosition;
				uniform fixed _HorizonCloudSize;
				uniform fixed _HorizonCloudStep;
				uniform fixed _HorizonCloudAnimationSpeed;
			#endif //HORIZON_CLOUD

			#if OVERHEAD_CLOUD
				uniform fixed4 _OverheadCloudColor;
				uniform fixed _OverheadCloudAltitude;
				uniform fixed _OverheadCloudSize;
				uniform fixed _OverheadCloudStep;
				uniform fixed _OverheadCloudAnimationSpeed;
				uniform fixed _OverheadCloudFlowSpeed;
				uniform fixed _OverheadCloudFlowDirectionX;
				uniform fixed _OverheadCloudFlowDirectionZ;
				uniform fixed _OverheadCloudRemapMin;
				uniform fixed _OverheadCloudRemapMax;
			#endif //OVERHEAD_CLOUD

			#if DETAIL_OVERLAY
				uniform fixed4 _DetailOverlayTintColor;
				uniform samplerCUBE _DetailOverlayCubemap;
				uniform fixed _DetailOverlayLayer;
				uniform fixed _DetailOverlayRotationSpeed;
			#endif

			//uniform float4x4 _SkyTransform;

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.localPos = v.vertex;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float4 localPos = float4(i.localPos.xyz, 1);
				//localPos = mul(_SkyTransform, localPos);
				float4 normalizedLocalPos = float4(normalize(localPos.xyz), 1);
				fixed4 color = fixed4(0,0,0,0);

				fixed4 skyBlendColor;
				fixed4 horizonBlendColor;
				CalculateSkyGradientColor(
					normalizedLocalPos,
					_SkyColor, _HorizonColor, _GroundColor,
					_HorizonThickness, _HorizonExponent, _HorizonStep,
					skyBlendColor, horizonBlendColor);
				color = BlendOverlay(skyBlendColor, color);

				#if DETAIL_OVERLAY
					fixed4 detailOverlayColor;
					#if DETAIL_OVERLAY_ROTATION
						CalculateDetailOverlayColor(
							i.localPos,
							_DetailOverlayCubemap,
							_DetailOverlayTintColor,
							_DetailOverlayRotationSpeed,
							detailOverlayColor);
					#else
						CalculateDetailOverlayColor(
							i.localPos,
							_DetailOverlayCubemap,
							_DetailOverlayTintColor,
							detailOverlayColor);
					#endif //DETAIL_OVERLAY_ROTATION

					fixed isLayerEqual = _DetailOverlayLayer == 0;
					fixed4 overlay = detailOverlayColor;
					overlay.a *= isLayerEqual;
					color = BlendOverlay(overlay, color);
				#endif //DETAIL_OVERLAY

				#if STARS
					fixed4 starsColor;
					#if STARS_BAKED
						CalculateStarsColorBaked(
							normalizedLocalPos,
							_StarsCubemap,
							_StarsTwinkleMap,
							_StarsOpacity,
							starsColor);
					#else
						#if STARS_LAYER_0
							fixed4 starsColor0;
							CalculateStarsColor(
								normalizedLocalPos,
								_StarsStartPosition, _StarsEndPosition,
								_StarsColor0, _StarsOpacity,
								_StarsDensity0,
								_StarsSize0,
								_StarsGlow0,
								_StarsTwinkle0,
								starsColor0);
							starsColor = starsColor0;
						#endif //STARS_LAYER_0

						#if STARS_LAYER_1
							fixed4 starsColor1;
							CalculateStarsColor(
								normalizedLocalPos,
								_StarsStartPosition, _StarsEndPosition,
								_StarsColor1, _StarsOpacity,
								_StarsDensity1,
								_StarsSize1,
								_StarsGlow1,
								_StarsTwinkle1,
								starsColor1);
							starsColor = lerp(starsColor, starsColor1, starsColor1.a);
						#endif //STARS_LAYER_1

						#if STARS_LAYER_2
							fixed4 starsColor2;
							CalculateStarsColor(
								normalizedLocalPos,
								_StarsStartPosition, _StarsEndPosition,
								_StarsColor2, _StarsOpacity,
								_StarsDensity2,
								_StarsSize2,
								_StarsGlow2,
								_StarsTwinkle2,
								starsColor2);
							starsColor = lerp(starsColor, starsColor2, starsColor2.a);
						#endif //STARS_LAYER_2
					#endif //STARS_BAKED

					color = BlendOverlay(starsColor, color);
				#endif //STARS

				#if DETAIL_OVERLAY
					isLayerEqual = _DetailOverlayLayer == 1;
					overlay = detailOverlayColor;
					overlay.a *= isLayerEqual;
					color = BlendOverlay(overlay, color);
				#endif //DETAIL_OVERLAY

				#if SUN
					fixed4 sunColor;
					#if SUN_BAKED
						CalculateSunMoonColorBaked(
							normalizedLocalPos, _SunRotationMatrix,
							_SunCubemap,
							sunColor);
					#else
						#if SUN_USE_TEXTURE
							CalculateSunMoonColorTextured(
								normalizedLocalPos,
								_SunTex, _PositionToSunUV,
								_SunColor,
								_SunSize, _SunSoftEdge, _SunGlow,
								_SunDirection,
								sunColor);
						#else
							CalculateSunMoonColor(
								normalizedLocalPos,
								_SunColor,
								_SunSize, _SunSoftEdge, _SunGlow,
								_SunDirection,
								sunColor);
						#endif //SUN_USE_TEXTURE
					#endif //SUN_BAKED
					color = BlendOverlay(sunColor, color);
				#endif //SUN

				#if DETAIL_OVERLAY
					isLayerEqual = _DetailOverlayLayer == 2;
					overlay = detailOverlayColor;
					overlay.a *= isLayerEqual;
					color = BlendOverlay(overlay, color);
				#endif //DETAIL_OVERLAY

				#if MOON 
					fixed4 moonColor;
					#if MOON_BAKED
						CalculateSunMoonColorBaked(
							normalizedLocalPos, _MoonRotationMatrix,
							_MoonCubemap,
							moonColor);
					#else
						#if MOON_USE_TEXTURE
							CalculateSunMoonColorTextured(
								normalizedLocalPos,
								_MoonTex, _PositionToMoonUV,
								_MoonColor,
								_MoonSize, _MoonSoftEdge, _MoonGlow,
								_MoonDirection,
								moonColor);
						#else
							CalculateSunMoonColor(
								normalizedLocalPos,
								_MoonColor,
								_MoonSize, _MoonSoftEdge, _MoonGlow,
								_MoonDirection,
								moonColor);
						#endif //MOON_USE_TEXTURE
					#endif //MOON_BAKED
					color = BlendOverlay(moonColor, color);
				#endif //MOON

				#if DETAIL_OVERLAY
					isLayerEqual = _DetailOverlayLayer == 3;
					overlay = detailOverlayColor;
					overlay.a *= isLayerEqual;
					color = BlendOverlay(overlay, color);
				#endif

				#if HORIZON_CLOUD
					fixed4 horizonCloudColor;
					CalculateHorizonCloudColor(
						normalizedLocalPos,
						_HorizonCloudColor,
						_HorizonCloudStartPosition, _HorizonCloudEndPosition,
						_HorizonCloudSize, _HorizonCloudStep,
						_HorizonCloudAnimationSpeed,
						horizonCloudColor);
					color = BlendOverlay(horizonCloudColor, color);
				#endif

				#if DETAIL_OVERLAY
					isLayerEqual = _DetailOverlayLayer == 4;
					overlay = detailOverlayColor;
					overlay.a *= isLayerEqual;
					color = BlendOverlay(overlay, color);
				#endif

				#if OVERHEAD_CLOUD
					fixed4 overheadCloudColor;
					CalculateOverheadCloudColor(
						normalizedLocalPos, 
						_OverheadCloudColor,
						_OverheadCloudAltitude,
						_OverheadCloudSize,
						_OverheadCloudStep,
						_OverheadCloudAnimationSpeed,
						_OverheadCloudFlowSpeed,
						_OverheadCloudFlowDirectionX,
						_OverheadCloudFlowDirectionZ,
						_OverheadCloudRemapMin,
						_OverheadCloudRemapMax,
						overheadCloudColor);
					color = BlendOverlay(overheadCloudColor, color);
				#endif

				#if DETAIL_OVERLAY
					isLayerEqual = _DetailOverlayLayer == 5;
					overlay = detailOverlayColor;
					overlay.a *= isLayerEqual;
					color = BlendOverlay(overlay, color);
				#endif

				color = BlendOverlay(horizonBlendColor, color);

				//color = float4(localPos.xyz, 1);
				return color;
			}
			ENDCG
		}
	}
	Fallback "Unlit/Color"
}
