/**
 * Copyright (C) 2015 Ganossa (mediehawk@gmail.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software with restriction, including without limitation the rights to
 * use and/or sell copies of the Software, and to permit persons to whom the Software
 * is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and the permission notices (this and below) shall
 * be included in all copies or substantial portions of the Software.
 *
 * Permission needs to be specifically granted by the author of the software to any
 * person obtaining a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction, including without
 * limitation the rights to copy, modify, merge, publish, distribute, and/or
 * sublicense the Software, and subject to the following conditions:
 *
 * The above copyright notice and the permission notices (this and above) shall
 * be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

// -----------------------------------------------------------------------------
// Ported to Magpie FX
// Original shader by Ganossa (mediehawk@gmail.com)
// Original shader source:
// https://github.com/crosire/reshade-shaders/blob/legacy/Shaders/AmbientLight.fx
// -----------------------------------------------------------------------------
 

//!MAGPIE EFFECT
//!VERSION 4
//!USE _DYNAMIC

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------

//!PARAMETER
//!LABEL Debug
//!DEFAULT 0
//!MIN 0
//!MAX 1
//!STEP 1
float alDebug;

//!PARAMETER
//!LABEL Base Intensity
//!DEFAULT 10.15
//!MIN 0.0
//!MAX 20.0
//!STEP 0.05
float alInt;

//!PARAMETER
//!LABEL Threshold
//!DEFAULT 15.0
//!MIN 0.0
//!MAX 100.0
//!STEP 0.5
float alThreshold;

//!PARAMETER
//!LABEL Dither
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 1
float AL_Dither;

//!PARAMETER
//!LABEL Adaptation
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 1
float AL_Adaptation;

//!PARAMETER
//!LABEL Adapt Intensity
//!DEFAULT 0.7
//!MIN 0.0
//!MAX 4.0
//!STEP 0.05
float alAdapt;

//!PARAMETER
//!LABEL Adapt Base Mult
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 4.0
//!STEP 0.05
float alAdaptBaseMult;

//!PARAMETER
//!LABEL Adapt Base Black Level
//!DEFAULT 2
//!MIN 0
//!MAX 4
//!STEP 1
float alAdaptBaseBlackLvL;

//!PARAMETER
//!LABEL Lens Threshold
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float alLensThresh;

//!PARAMETER
//!LABEL Lens Intensity
//!DEFAULT 2.0
//!MIN 0.0
//!MAX 10.0
//!STEP 0.05
float alLensInt;


//------------------------------------------------------------------------------
// Textures & Samplers
//------------------------------------------------------------------------------

//!TEXTURE
Texture2D INPUT;


// Downscaled ping-pong chain 

//!TEXTURE
//!WIDTH INPUT_WIDTH / 16
//!HEIGHT INPUT_HEIGHT / 16
//!FORMAT R16G16B16A16_FLOAT
Texture2D AL_Tex0;

//!TEXTURE
//!WIDTH INPUT_WIDTH / 16
//!HEIGHT INPUT_HEIGHT / 16
//!FORMAT R16G16B16A16_FLOAT
Texture2D AL_H1;

//!TEXTURE
//!WIDTH INPUT_WIDTH / 16
//!HEIGHT INPUT_HEIGHT / 16
//!FORMAT R16G16B16A16_FLOAT
Texture2D AL_V1;

//!TEXTURE
//!WIDTH 32
//!HEIGHT 32
//!FORMAT R16G16B16A16_FLOAT
Texture2D DetectIntTex;

//!TEXTURE
//!WIDTH 1
//!HEIGHT 1
//!FORMAT R16G16B16A16_FLOAT
Texture2D DetectLowTex;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//!SAMPLER
//!FILTER LINEAR
SamplerState SampLinear;

//------------------------------------------------------------------------------
// Common helpers
//------------------------------------------------------------------------------

//!COMMON
static const float3 LUMA = float3(0.241, 0.691, 0.068);

float2 GEMFX_PIXEL_SIZE()
{
    return GetInputPt() * 16.0;
}

static const float sampleOffsets[5] =
{
    0.0, 2.4347826, 4.3478260, 6.2608695, 8.1739130
};

static const float sampleWeights[5] =
{
    0.16818994, 0.27276957, 0.111690125, 0.024067905, 0.0021112196
};


static const float AL_TIME_MAX = 6.28;
static const float AL_TIME_STEP = 0.1;

// Triangle-wave pingpong: 0 → max → 0
float ComputeALTime()
{
    float t = (__frameCount * AL_TIME_STEP);
    float period = AL_TIME_MAX * 2.0;
    float m = fmod(t, period);
    return (m <= AL_TIME_MAX) ? m : (period - m);
}

float4 BlurH(Texture2D tex, float2 uv)
{
    float2 px = GEMFX_PIXEL_SIZE();
    float stepMult = 1.08 + (ComputeALTime() / 100.0) * 0.02;

    float4 c = tex.SampleLevel(SampLinear, uv, 0) * sampleWeights[0];
    c.rgb = max(c.rgb - alThreshold, 0.0);

    [unroll]
    for (int i = 1; i < 5; i++)
    {
        c += tex.SampleLevel(SampLinear, uv + float2(sampleOffsets[i] * px.x, 0), 0) * sampleWeights[i] * stepMult;
        c += tex.SampleLevel(SampLinear, uv - float2(sampleOffsets[i] * px.x, 0), 0) * sampleWeights[i] * stepMult;
    }
    return c;
}

float4 BlurV(Texture2D tex, float2 uv)
{
    float2 px = GEMFX_PIXEL_SIZE();
    float stepMult = 1.08 + (ComputeALTime() / 100.0) * 0.02;

    float4 c = tex.SampleLevel(SampLinear, uv, 0) * sampleWeights[0];
    c.rgb = max(c.rgb - alThreshold, 0.0);

    [unroll]
    for (int i = 1; i < 5; i++)
    {
        c += tex.SampleLevel(SampLinear, uv + float2(0, sampleOffsets[i] * px.y), 0) * sampleWeights[i] * stepMult;
        c += tex.SampleLevel(SampLinear, uv - float2(0, sampleOffsets[i] * px.y), 0) * sampleWeights[i] * stepMult;
    }
    return c;
}


//------------------------------------------------------------------------------
// PASS 1 – Detect Intensity
//------------------------------------------------------------------------------

//!PASS 1
//!DESC Detect Intensity
//!STYLE PS
//!IN INPUT
//!OUT DetectIntTex

float4 Pass1(float2 uv)
{
    return INPUT.SampleLevel(SampLinear, uv, 0);
}

//------------------------------------------------------------------------------
// PASS 2 – Detect Low
//------------------------------------------------------------------------------

//!PASS 2
//!DESC Detect Low
//!STYLE PS
//!IN DetectIntTex
//!OUT DetectLowTex

float4 Pass2(float2 uv)
{
    // Only accumulate on center pixel
    if (abs(uv.x - 0.5) > 1e-6 || abs(uv.y - 0.5) > 1e-6)
        return float4(0.0, 0.0, 0.0, 1.0);

    float3 acc = 0.0;

    [loop]
    for (float i = 0.0; i <= 1.0; i += 0.03125)
    {
        [unroll]
        for (float j = 0.0; j <= 1.0; j += 0.03125)
        {
            acc += DetectIntTex.SampleLevel(SampLinear, float2(i, j), 0).rgb;
        }
    }

    acc /= (32.0 * 32.0);
    return float4(acc, 1.0);
}


//------------------------------------------------------------------------------
// PASS 3 – Detect High
//------------------------------------------------------------------------------

//!PASS 3
//!DESC Detect High
//!STYLE PS
//!IN INPUT
//!OUT AL_Tex0
float4 Pass3(float2 uv)
{
    float4 x = INPUT.SampleLevel(SampLinear, uv, 0);
    x.rgb *= pow(max(x.r, max(x.g, x.b)), 2.0);

    float base = dot(x.rgb, 1.0 / 3.0);

    float3 n = x.rgb * 2.0 - base;

    n = clamp(n, 0.0, 1.0);
    return float4(n, 1.0);
}

//!PASS 4
//!STYLE PS
//!IN AL_Tex0
//!OUT AL_H1
float4 Pass4(float2 uv) { return BlurH(AL_Tex0, uv); }

//!PASS 5
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass5(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 6
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass6(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 7
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass7(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 8
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass8(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 9
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass9(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 10
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass10(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 11
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass11(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 12
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass12(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 13
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass13(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 14
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass14(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 15
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass15(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 16
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass16(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 17
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass17(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 18
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass18(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 19
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass19(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 20
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass20(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 21
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass21(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 22
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass22(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 23
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass23(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 24
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass24(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 25
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass25(float2 uv) { return BlurV(AL_H1, uv); }

//!PASS 26
//!STYLE PS
//!IN AL_V1
//!OUT AL_H1
float4 Pass26(float2 uv) { return BlurH(AL_V1, uv); }

//!PASS 27
//!STYLE PS
//!IN AL_H1
//!OUT AL_V1
float4 Pass27(float2 uv) { return BlurV(AL_H1, uv); }


//------------------------------------------------------------------------------
// FINAL PASS – Magic
//------------------------------------------------------------------------------

//!PASS 28
//!DESC Ambient Light Composite
//!STYLE PS
//!IN INPUT, AL_V1, DetectLowTex
//!OUT OUTPUT

float4 Pass28(float2 uv)
{
    float4 base = INPUT.SampleLevel(SampLinear, uv, 0);
    float4 high = AL_V1.SampleLevel(SampLinear, uv, 0);

    float adapt = 0.0;

    if (AL_Adaptation > 0.5)
    {
        float3 dl = DetectLowTex.SampleLevel(SampLinear, float2(0.5,0.5), 0).rgb / 4.215;
        float low = sqrt(dot(dl * dl, LUMA));
        low = pow(low * 1.25, 2.0);
        adapt = low * (low + 1.0) * alAdapt * alInt * 5.0;
    }

    high = min(high, 0.0325) * 1.15;

    float dither = 0.0;
    if (AL_Dither > 0.5)
    {
        float d = 0.15 / (pow(2.0, 10.0) - 1.0);
        dither = lerp(2*d, -2*d, frac(dot(uv, float2(GetInputSize()) * float2(1.0/16.0,10.0/36.0))));
    }

    float4 mixv = 1.0 - ((1.0 - base) * (1.0 - high)) + dither;
    float4 outv = lerp(base, mixv, max(0.0, alInt - adapt));

    return float4(outv.rgb, 1.0);
}
