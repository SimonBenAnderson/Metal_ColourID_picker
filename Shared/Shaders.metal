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
};

struct Vertex
{
    simd_float2 position;
    simd_float4 color;
};

vertex RasterizerData vertexShader( uint vertexID [[vertex_id]],
                                   constant Vertex *vertices [[buffer(0)]], // Index of vertices data
                                   constant vector_uint2 *viewportSizePointer [[buffer(1)]])
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
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // Return the interpolated color.
    return in.color;
}
