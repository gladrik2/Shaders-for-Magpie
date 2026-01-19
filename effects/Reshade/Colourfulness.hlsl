// Copyright (c) 2016-2018, bacondither
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer
//    in this position and unchanged.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// -----------------------------------------------------------------------------
// Ported to Magpie FX
// Original shader by bacondither
// Original shader source:
// https://github.com/crosire/reshade-shaders/blob/legacy/Shaders/Colourfulness.fx
// -----------------------------------------------------------------------------


//!MAGPIE EFFECT
//!VERSION 4

//------------------------------------------------------------------------------
// Parameters
//------------------------------------------------------------------------------

//!PARAMETER
//!LABEL Colourfulness
//!DEFAULT 0.4
//!MIN -1.0
//!MAX 2.0
//!STEP 0.01
float colourfulness;

//!PARAMETER
//!LABEL Luma Limit
//!DEFAULT 0.7
//!MIN 0.1
//!MAX 1.0
//!STEP 0.01
float lim_luma;

//!PARAMETER
//!LABEL Enable Dither
//!DEFAULT 0
//!MIN 0
//!MAX 1
//!STEP 1
float enable_dither;

//!PARAMETER
//!LABEL Coloured Noise
//!DEFAULT 1
//!MIN 0
//!MAX 1
//!STEP 1
float col_noise;

//!PARAMETER
//!LABEL Backbuffer Bit Depth
//!DEFAULT 8.0
//!MIN 1.0
//!MAX 32.0
//!STEP 1.0
float backbuffer_bits;

//------------------------------------------------------------------------------
// Textures & Samplers
//------------------------------------------------------------------------------

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;

//!COMMON
//------------------------------------------------------------------------------
// Defines (compile-time behavior switches)
//------------------------------------------------------------------------------

#define fast_luma 1
#define temporal_dither 0

//------------------------------------------------------------------------------
// Common helpers & constants
//------------------------------------------------------------------------------

// Sigmoid soft limiter
static float3 soft_lim(float3 v, float s)
{
    return (v * s) * rsqrt(s * s + v * v);
}

// Weighted power mean, p = 0.5
static float3 wpmean(float3 a, float3 b, float w)
{
    return pow(
        abs(w) * sqrt(abs(a)) +
        abs(1.0 - w) * sqrt(abs(b)),
        2.0
    );
}

static float maxRGB(float3 c)
{
    return max(c.r, max(c.g, c.b));
}

static float minRGB(float3 c)
{
    return min(c.r, min(c.g, c.b));
}

// Mean of Rec.709 & 601 luma coefficients
static const float3 lumacoeff = float3(0.2558, 0.6511, 0.0931);

//------------------------------------------------------------------------------
// Pass
//------------------------------------------------------------------------------

//!PASS 1
//!DESC Colourfulness
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT

float4 Pass1(float2 tex)
{
    float3 c0;
    float luma;

#if fast_luma == 1
    c0 = INPUT.SampleLevel(SampleLinear, tex, 0).rgb;
    luma = sqrt(dot(saturate(c0 * abs(c0)), lumacoeff));
    c0 = saturate(c0);
#else
    c0 = saturate(INPUT.SampleLevel(SampleLinear, tex, 0).rgb);
    luma = pow(dot(pow(c0 + 0.06, 2.4), lumacoeff), 1.0 / 2.4) - 0.06;
#endif

    // Saturation delta
    float3 diff_luma = c0 - luma;
    float3 c_diff = diff_luma * (colourfulness + 1.0) - diff_luma;

    if (colourfulness > 0.0)
    {
        // 120% clamped visible range
        float3 rlc_diff =
            clamp(c_diff * 1.2 + c0, -0.0001, 1.0001) - c0;

        float poslim =
            (1.0002 - luma) / (abs(maxRGB(diff_luma)) + 0.0001);
        float neglim =
            (luma + 0.0002) / (abs(minRGB(diff_luma)) + 0.0001);

        float3 diffmax =
            diff_luma * min(min(poslim, neglim), 32.0) - diff_luma;

        c_diff = soft_lim(
            c_diff,
            max(wpmean(diffmax, rlc_diff, lim_luma), 1e-7)
        );
    }

    if (enable_dither > 0.5)
    {
        // Interleaved gradient noise (Jorge Jimenez)
        const float3 magic = float3(0.06711056, 0.00583715, 52.9829189);

#if temporal_dither == 1
        float xy_magic =
            (tex.x * GetInputSize().x + __frameCount) * magic.x +
            (tex.y * GetInputSize().y + __frameCount) * magic.y;
#else
        float xy_magic =
            (tex.x * GetInputSize().x) * magic.x +
            (tex.y * GetInputSize().y) * magic.y;
#endif

        float noise =
            (frac(magic.z * frac(xy_magic)) - 0.5) /
            (exp2(backbuffer_bits) - 1.0);

        if (col_noise > 0.5)
            c_diff += float3(-noise, noise, -noise);
        else
            c_diff += noise;
    }

    return float4(saturate(c0 + c_diff), 1.0);
}
