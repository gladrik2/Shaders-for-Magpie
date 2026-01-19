/*------------------.
| :: Description :: |
'-------------------/

    Layer (version 0.2)

    Author: CeeJay.dk
    License: MIT

    About:
    Blends an image with the game.
    The idea is to give users with graphics skills the ability to create effects using a layer just like in an image editor.
    Maybe they could use this to create custom CRT effects, custom vignettes, logos, custom hud elements, toggable help screens and crafting tables or something I haven't thought of.

    Ideas for future improvement:
    * More blend modes
    * Tiling control
    * A default Layer texture with something useful in it

    History:
    (*) Feature (+) Improvement (x) Bugfix (-) Information (!) Compatibility

    Version 0.2 by seri14 & Marot Satil
    * Added the ability to scale and move the layer around on XY axis
*/

//!MAGPIE EFFECT
//!VERSION 4

//!PARAMETER
//!LABEL Position X-axis
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.005
float Layer_Pos_X;

//!PARAMETER
//!LABEL Position Y-axis
//!DEFAULT 0.5
//!MIN 0.0
//!MAX 1.0
//!STEP 0.005
float Layer_Pos_Y;

//!PARAMETER
//!LABEL Scale
//!DEFAULT 1.0
//!MIN 0.01
//!MAX 4.0
//!STEP 0.005
float Layer_Scale;

//!PARAMETER
//!LABEL Blend
// How much to blend layer with the original image
//!DEFAULT 1.0
//!MIN 0.0
//!MAX 1.0
//!STEP 0.005
float Layer_Blend;

//!TEXTURE
Texture2D INPUT;
//!TEXTURE
//!WIDTH INPUT_WIDTH
//!HEIGHT INPUT_HEIGHT
Texture2D OUTPUT;


//!SAMPLER
//!FILTER POINT
SamplerState SamplePoint;

//!TEXTURE
//!SOURCE Layer.png
Texture2D Layer;

//!SAMPLER
//!FILTER LINEAR
SamplerState SampleLinear;

//!PASS 1
//!DESC Blends an image with the game.
//!STYLE PS
//!IN INPUT, Layer
//!OUT OUTPUT
float4 Pass1(float2 texCoord) {
    const float4 backColor = INPUT.SampleLevel(SamplePoint, texCoord, 0);
    const float2 ScreenSize = float2(GetInputSize());
    const float2 Layer_Pos = float2(Layer_Pos_X, Layer_Pos_Y);
    
    uint LayerSizeX, LayerSizeY;
    Layer.GetDimensions(LayerSizeX, LayerSizeY);
    
    const float2 pixelSize = 1.0 / (float2(LayerSizeX, LayerSizeY) * Layer_Scale / ScreenSize);
    const float4 layer = Layer.SampleLevel(SampleLinear, texCoord * pixelSize + Layer_Pos * (1.0 - pixelSize), 0);

    return float4(lerp(backColor.rgb, layer.rgb, layer.a * Layer_Blend), backColor.a);
}