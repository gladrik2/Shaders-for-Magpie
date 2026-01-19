//Gaussian Blur by Ioxa
//Original source: https://github.com/crosire/reshade-shaders/blob/legacy/Shaders/GaussianBlur.fx

//Ported to MagpieFX

//!MAGPIE EFFECT
//!VERSION 4
//!USE _DYNAMIC

//====================
// Parameters
//====================

//!PARAMETER
//!LABEL Blur Radius
//!DEFAULT 1
//!MIN 0
//!MAX 4
//!STEP 1
int GaussianBlurRadius;

//!PARAMETER
//!LABEL Blur Offset
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float GaussianBlurOffset;

//!PARAMETER
//!LABEL Blur Strength
//!DEFAULT 0.3
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float GaussianBlurStrength;

//====================
// Textures
//====================

//!TEXTURE
Texture2D INPUT;

//!TEXTURE
//!FORMAT R16G16B16A16_FLOAT
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D BlurTex;

//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;

//====================
// Samplers
//====================

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;


//!PASS 1
//!DESC Horizontal Gaussian Blur
//!STYLE PS
//!IN INPUT
//!OUT BlurTex
float4 Pass1(float2 uv)
{
    float2 pt = GetInputPt();
    float3 color = INPUT.SampleLevel(SampleLinear, uv, 0).rgb;

    if (GaussianBlurRadius == 0)
    {
        float offset[4] = { 0.0, 1.1824255, 3.0293122, 5.0040701 };
        float weight[4] = { 0.39894, 0.29596, 0.00456565, 0.00000149 };

        color *= weight[0];
        [loop]
        for (int i = 1; i < 4; ++i)
        {
            float2 o = float2(offset[i] * pt.x, 0) * GaussianBlurOffset;
            color += INPUT.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += INPUT.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }

    if(GaussianBlurRadius == 1)	
    {
        float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
        float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
        
        color *= weight[0];
        
        [loop]
        for (int i = 1; i < 6; ++i)
        {
            float2 o = float2(offset[i] * pt.x, 0) * GaussianBlurOffset;
            color += INPUT.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += INPUT.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }	

    if(GaussianBlurRadius == 2)	
    {
        float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
        float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 11; ++i)
        {
            float2 o = float2(offset[i] * pt.x, 0) * GaussianBlurOffset;
            color += INPUT.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += INPUT.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }	

    if(GaussianBlurRadius == 3)	
    {
        float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
        float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 15; ++i)
        {
            float2 o = float2(offset[i] * pt.x, 0) * GaussianBlurOffset;
            color += INPUT.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += INPUT.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }	

    if(GaussianBlurRadius == 4)	
    {
        float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
        float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 18; ++i)
        {
            float2 o = float2(offset[i] * pt.x, 0) * GaussianBlurOffset;
            color += INPUT.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += INPUT.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }	

    return float4(saturate(color), 1.0);
}

//!PASS 2
//!DESC Vertical Gaussian Blur + Blend
//!STYLE PS
//!IN BlurTex, INPUT
//!OUT OUTPUT
float4 Pass2(float2 uv)
{
    float2 pt = GetInputPt();
    float3 color = BlurTex.SampleLevel(SampleLinear, uv, 0).rgb;

    if (GaussianBlurRadius == 0)
    {
        float offset[4] = { 0.0, 1.1824255, 3.0293122, 5.0040701 };
        float weight[4] = { 0.39894, 0.29596, 0.00456565, 0.00000149 };

        color *= weight[0];
        [loop]
        for (int i = 1; i < 4; ++i)
        {
            float2 o = float2(0, offset[i] * pt.y) * GaussianBlurOffset;
            color += BlurTex.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += BlurTex.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }

    if(GaussianBlurRadius == 1)	
    {
        float offset[6] = { 0.0, 1.4584295168, 3.40398480678, 5.3518057801, 7.302940716, 9.2581597095 };
        float weight[6] = { 0.13298, 0.23227575, 0.1353261595, 0.0511557427, 0.01253922, 0.0019913644 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 6; ++i)
        {
            float2 o = float2(0, offset[i] * pt.y) * GaussianBlurOffset;
            color += BlurTex.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += BlurTex.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }	

    if(GaussianBlurRadius == 2)	
    {
        float offset[11] = { 0.0, 1.4895848401, 3.4757135714, 5.4618796741, 7.4481042327, 9.4344079746, 11.420811147, 13.4073334, 15.3939936778, 17.3808101174, 19.3677999584 };
        float weight[11] = { 0.06649, 0.1284697563, 0.111918249, 0.0873132676, 0.0610011113, 0.0381655709, 0.0213835661, 0.0107290241, 0.0048206869, 0.0019396469, 0.0006988718 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 11; ++i)
        {
            float2 o = float2(0, offset[i] * pt.y) * GaussianBlurOffset;
            color += BlurTex.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += BlurTex.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }	

    if(GaussianBlurRadius == 3)	
    {
        float offset[15] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4401038149, 21.43402885, 23.4279736431, 25.4219399344, 27.4159294386 };
        float weight[15] = { 0.0443266667, 0.0872994708, 0.0820892038, 0.0734818355, 0.0626171681, 0.0507956191, 0.0392263968, 0.0288369812, 0.0201808877, 0.0134446557, 0.0085266392, 0.0051478359, 0.0029586248, 0.0016187257, 0.0008430913 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 15; ++i)
        {
            float2 o = float2(0, offset[i] * pt.y) * GaussianBlurOffset;
            color += BlurTex.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += BlurTex.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }

    if(GaussianBlurRadius == 4)	
    {
        float offset[18] = { 0.0, 1.4953705027, 3.4891992113, 5.4830312105, 7.4768683759, 9.4707125766, 11.4645656736, 13.4584295168, 15.4523059431, 17.4461967743, 19.4661974725, 21.4627427973, 23.4592916956, 25.455844494, 27.4524015179, 29.4489630909, 31.445529535, 33.4421011704 };
        float weight[18] = { 0.033245, 0.0659162217, 0.0636705814, 0.0598194658, 0.0546642566, 0.0485871646, 0.0420045997, 0.0353207015, 0.0288880982, 0.0229808311, 0.0177815511, 0.013382297, 0.0097960001, 0.0069746748, 0.0048301008, 0.0032534598, 0.0021315311, 0.0013582974 };
        
        color *= weight[0];
        
        [loop]
        for(int i = 1; i < 18; ++i)
        {
            float2 o = float2(0, offset[i] * pt.y) * GaussianBlurOffset;
            color += BlurTex.SampleLevel(SampleLinear, uv + o, 0).rgb * weight[i];
            color += BlurTex.SampleLevel(SampleLinear, uv - o, 0).rgb * weight[i];
        }
    }		

    float3 orig = INPUT.SampleLevel(SampleLinear, uv, 0).rgb;
    float3 finalColor = lerp(orig, color, GaussianBlurStrength);

    return float4(saturate(finalColor), 1.0);
}
