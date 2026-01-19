//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL Tint Color (Red Component)
//!DEFAULT 140.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float TintRed;

//!PARAMETER
//!LABEL Tint Color (Green Component)
//!DEFAULT 110.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float TintGreen;

//!PARAMETER
//!LABEL Tint Color (Blue Component)
//!DEFAULT 107.0
//!MIN 0.0
//!MAX 255.0
//!STEP 1.0
float TintBlue;

//!PARAMETER
//!LABEL Strength
// Adjust the strength of the effect.
//!DEFAULT 0.58
//!MIN 0.0
//!MAX 1.0
//!STEP 0.01
float Strength;

//!TEXTURE
Texture2D INPUT;
//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;


//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!PASS 1
//!DESC Creates a color overlay to tint the screen.
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT
float4 Pass1(float2 texcoord) {
	float3 col = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float3 Tint = float3(TintRed, TintGreen, TintBlue) / 255.0;

	return float4(lerp(col, col * Tint * 2.55, Strength), 1.0);
}
