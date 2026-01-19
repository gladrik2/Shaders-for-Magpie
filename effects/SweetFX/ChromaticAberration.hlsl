/**
 * Chromatic Aberration
 * by Christian Cann Schuldt Jensen ~ CeeJay.dk
 *
 * Ported to Magpie by Eric Banker ~ Kourinn
 *
 * Distorts the image by shifting each color component, which creates color artifacts similar to those in a very cheap lens or a cheap sensor.
 */

//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL Shift X-axis
// Distance (X,Y) in pixels to shift the color components. For a slightly blurred look try fractional values (.5) between two pixels.
//!DEFAULT 2.5
//!MIN -10.0
//!MAX 10.0
//!STEP 0.1
float ShiftX;

//!PARAMETER
//!LABEL Shift Y-axis
// Distance (X,Y) in pixels to shift the color components. For a slightly blurred look try fractional values (.5) between two pixels.
//!DEFAULT -0.5
//!MIN -10.0
//!MAX 10.0
//!STEP 0.1
float ShiftY;

//!PARAMETER
//!LABEL Strength
//!DEFAULT 0.5
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

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;

//!PASS 1
//!DESC Distorts the image by shifting each color component, which creates color artifacts similar to those in a very cheap lens or a cheap sensor.
//!STYLE PS
//!IN INPUT
//!OUT OUTPUT
float4 Pass1(float2 texcoord) {
	float3 color, colorInput = INPUT.SampleLevel(SamplePoint, texcoord, 0).rgb;
	float2 pixSize = GetInputPt();
	float2 Shift = float2(ShiftX, ShiftY);
	// Sample the color components
	color.r = INPUT.SampleLevel(SampleLinear, texcoord + pixSize * Shift, 0).r;
	color.g = colorInput.g;
	color.b = INPUT.SampleLevel(SampleLinear, texcoord - pixSize * Shift, 0).b;

	// Adjust the strength of the effect
	return float4(lerp(colorInput, color, Strength), 1.0);
}
