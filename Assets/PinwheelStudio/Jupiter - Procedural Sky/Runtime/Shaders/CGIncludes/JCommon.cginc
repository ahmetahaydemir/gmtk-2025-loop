#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

float _JupiterTime;
sampler2D _NoiseTex;
sampler2D _CloudTex;

float NoiseTexFrag(float2 uv)
{
	return tex2D(_NoiseTex, uv).r*2 - 1;
}

float NoiseTexVert(float2 uv)
{
	return tex2Dlod(_NoiseTex, float4(uv.xy, 0, 0)).r*2 - 1;
}

float CloudTexFrag(float2 uv)
{
	return tex2D(_CloudTex, uv).r*2 - 1;
}

float CloudTexLod0(float2 uv)
{
	return tex2Dlod(_CloudTex, float4(uv.xy, 0, 0)).r*2 - 1;
}

float CloudTexVert(float2 uv)
{
	return CloudTexLod0(uv);
}

float2 GradientNoise_dir(float2 p)
{
	p = p % 289;
	float x = (34 * p.x + 1) * p.x % 289 + p.y;
	x = (34 * x + 1) * x % 289;
	x = frac(x / 41) * 2 - 1;
	return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float GradientNoise(float2 p)
{
	float2 ip = floor(p);
	float2 fp = frac(p);
	float d00 = dot(GradientNoise_dir(ip), fp);
	float d01 = dot(GradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
	float d10 = dot(GradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
	float d11 = dot(GradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
	fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
	return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float InverseLerpUnclamped(float a, float b, float value)
{
	//adding a==b check if needed
	return (value - a) / (b - a + 0.00000001);
}

float RandomValue(float seed)
{
	return frac(seed*23.456*(1+ceil(seed)*12.345));
}

float RandomValue(float3 seed)
{
	float3 value = frac(seed*23.456*(1+ceil(seed)*12.345));
	return max(value.x, min(value.y, value.z));
}

float2 VoronoiRandomVector (float2 UV, float offset)
{
    float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
}

float Voronoi(float2 UV, float AngleOffset, float CellDensity)
{
    float2 g = floor(UV * CellDensity);
    float2 f = frac(UV * CellDensity);
    float t = 8.0;
    float3 res = float3(8.0, 0.0, 0.0);
	float noiseValue = 0;

    for(int y=-1; y<=1; y++)
    {
        for(int x=-1; x<=1; x++)
        {
            float2 lattice = float2(x,y);
            float2 offset = VoronoiRandomVector(lattice + g, AngleOffset);
            float d = distance(lattice + offset, f);
            if(d < res.x)
            {
                res = float3(d, offset.x, offset.y);
                noiseValue = res.x;
            }
        }
    }

	return noiseValue;
}

float2 PanUV(float2 uv, float2 speed)
{
	return uv + _Time.y*speed;
}

half IsOrtho()
{
	return unity_OrthoParams.w;
}

half GetNearPlane()
{
	return _ProjectionParams.y;
}

half GetFarPlane()
{
	return _ProjectionParams.z;
}

float SqrDistance(float3 pt1, float3 pt2)
{
  float3 v = pt2 - pt1;
  return dot(v,v);
}

fixed SqrDistance(fixed pt1, fixed pt2)
{
  fixed v = pt2 - pt1;
  return dot(v,v);
}

float SqrMagnitude(float2 p)
{
	return p.x*p.x + p.y*p.y;
}

float SqrMagnitude(float3 p)
{
	return p.x*p.x + p.y*p.y + p.z*p.z;
}

float StepValue(float v, float count)
{
	float step = 1.0/count;
	return v-v%step;
}

float TriangleWave(float t)
{
	return 2.0 * abs( 2 * (t - floor(0.5 + t)) ) - 1.0;
}

fixed4 BlendOverlay(fixed4 src, fixed4 des)
{
	fixed4 result = src*src.a + des*(1-src.a);
	result.a = 1 - (1-src.a)*(1-des.a);
	return result;
}
#endif