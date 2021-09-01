//
//  Quad.swift
//  SwiftUI_QuadSelection
//
//  Created by Simon Anderson on 6/08/21.
//

import Foundation


/// This is a simple Quad object
/// - It is a simple container
/// It is meant to hold the quad data, and id
class Quad {
    
    /// unique ID identifier for each quadd instance.
    /// - This ID will also be converted into the colorPickID
    let ID:Int
    
    /// The ID encoded into color, that will be used for pick selection
    let colorPickID:simd_float4
    
    /// positions in an array, that make up the 4 sides
    var positions:Array<simd_float2> = []
    
    /// Colour that will be used to fill the triangle
    var color:simd_float4 = [0,0,0,1]
    
    /// Scales the points
    var scale:Float = 50.0
    
    var offset:simd_float2 = [0,0]
    
    /// Stores all the vertex data, that will get passed to the GPU
    var _vertices : Array<Vertex> = []
    
    init( id:Int, offset:simd_float2 = [0, 0], color:simd_float4 = [0,0,0,1]) {
        ID = id
        
        // Convert the ID into a color
        colorPickID = colorVec4FromItemID(ID)
        
        self.color = color
     
        initPosition()
        updateVerts()
    }
    
    /// Initiate position that will be used to draw the polygon
    func initPosition() {
        positions = [[ 1, 1],
                     [-1, 1],
                     [-1,-1],
                     [ 1,-1]]
    }
    
    func setScale(_ size:Float) {
        scale = size
        updateVerts()
    }
    
    /// Brute force method to generate the vertices for the first time
    func updateVerts() {
        _vertices = [
            Vertex(position: positions[0]*scale + offset, color: color, colorID: colorPickID),
            Vertex(position: positions[1]*scale + offset, color: color, colorID: colorPickID),
            Vertex(position: positions[2]*scale + offset, color: color, colorID: colorPickID),
            Vertex(position: positions[2]*scale + offset, color: color, colorID: colorPickID),
            Vertex(position: positions[3]*scale + offset, color: color, colorID: colorPickID),
            Vertex(position: positions[0]*scale + offset, color: color, colorID: colorPickID)
        ]
    }
    
}

/// Stores the quad ID incrementation
private var _quadID : Int = 0

/// helper function used to create quads
func newQuad() -> Quad {
    _quadID += 1
    
    return Quad(id:_quadID)
}

/// Converts an ID to a unique color
func colorVec4FromItemID(_ itemID:Int) -> simd_float4
{
    if (itemID<0) {
        return [0.0, 0.0, 0.0, 1.0]
    }
    let r:Float = Float(itemID % 255)
    let g:Float = Float((itemID / 255) % 255)
    let b:Float = Float((itemID / (255 * 255)) % 255)
    return [r/255, g/255, b/255, 1.0]
}


// MARK:- Helper Functions


/// Initialises the quad data that will be used for the renderer
func setupQuad() -> Array<Quad> {
    var quads:Array<Quad> = []
    // Creates the new quads that will be drawn
    let q1 = newQuad()
    let q2 = newQuad()
    let q3 = newQuad()
    let q4 = newQuad()
    let q5 = newQuad()
    
    quads.append(q1)
    quads.append(q2)
    quads.append(q3)
    quads.append(q4)
    quads.append(q5)
    
    q1.offset = [-400,  300]
    q2.offset = [-200, -100]
    q3.offset = [   0,    0]
    q4.offset = [ 200,  100]
    q5.offset = [ 200, -100]
    
    q1.color = [0.4, 0.4, 0.4, 1]
    q2.color = [0.4, 0.4, 0.4, 1]
    q3.color = [0.4, 0.4, 0.4, 1]
    q4.color = [0.4, 0.4, 0.4, 1]
    q5.color = [0.4, 0.4, 0.4, 1]
    
    q1.setScale(200)
    
    q1.updateVerts()
    q2.updateVerts()
    q3.updateVerts()
    q4.updateVerts()
    q5.updateVerts()
    
    return quads
}
