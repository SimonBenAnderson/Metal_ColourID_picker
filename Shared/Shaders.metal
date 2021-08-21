//
//  Shader.metal
//  SwiftUI_HelloTriangle
//
//  Created by Simon Anderson on 17/01/21.
//

#include <metal_stdlib>
#include <simd/simd.h>
//#include "Bridging_Header.h"

using namespace metal;


// The Vertex shader output and fragment shader input
struct RasterizerData
{
    // the [[position]] attribute of this member indicates that this value
    // is the clip space position of the vertex when this structure is
    // returned from the vertex function.
    simd_float4 position [[position]];
    
    // Since this member does have a special attribute, the rasterizer
    // interpolates its values with the values of the other trianglle vertices
    // and then passes the interpolated value to the fragment shader for each
    // fragment in the triangle.
    simd_float4 color;
    
    simd_float4 pickID; // colour of the pick ID rasterized
};

struct Vertex
{
    simd_float2 position;
    simd_float4 color;
    simd_float4 colorID;
};

// This will hold both passes colour pass information
//
// color() = The input value read from a color attachment. The index indicates which color attachment to read from.
//
// reference: https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
//
struct RenderPasses
{
    simd_float4 beautyPass   [[ color(0) ]]; // This is the default render output
    simd_float4 colourIDPass [[ color(1) ]]; // Pass that will store the colourID
};

vertex RasterizerData vertexShader( uint vertexID [[vertex_id]],
                                   constant Vertex *vertices [[buffer(0)]], // Index of vertices data
                                   constant vector_float2 *viewportSizePointer [[buffer(1)]])
{
    RasterizerData out;
    
    // Index into the array of positions to get the current vertex.
    // The positions are specified in pixel dimensions (i.e. a value of 100
    // is 100 pixels from the origin).
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    // Get the viewport size and cast to float.
    simd_float2 viewportSize = simd_float2(*viewportSizePointer);
    
    // To convert from positions in pixel space to positions in clip-space,
    // divide the pixel coordinates by half the size of the viewport.
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    // Pass the input color directly to the rasterizer.
    out.color = vertices[vertexID].color;
    
    // Pass the pick id colour to the rasterizer object
    out.pickID = vertices[vertexID].colorID;
    
    return out;
}

fragment RenderPasses fragmentShader(RasterizerData in [[stage_in]])
{
    // Instantiates the output object that will hold both beauty and pickID pass
    RenderPasses passOut;
    
    // Sets the beauty pass, which is the data we will write to the viewport
    passOut.beautyPass = in.color;
    
    // Sets the colour ID, which will be draw offscreen, and we will query
    passOut.colourIDPass = in.pickID;
    
    return passOut;
}
