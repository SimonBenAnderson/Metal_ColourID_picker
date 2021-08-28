//
//  ViewModel.swift
//  SwiftUI_QuadSelection
//
//  Created by Simon Anderson on 8/08/21.
//

import Foundation
import Metal

/// ViewModel, should be a more descriptive name, but as this is for learning purposes I have kept it in name with the MVVM naming
/// Model, View, ViewModel

/// View Models have to be a class as they to have a reference pointer
class ViewModel {
    
    var renderer : Renderer!
    
    /// Texture buffer data starts from the **top left** of the screen and is stored row first.
    /// eg. Row_0, Row_1, Row_2
    var colourID_buffer : [UInt8]?
    
    init() { }
    
    
    // When the user presses on the screen this is triggered
    func pressTriggered(_ pos:simd_int2) {
        print("Press Event Triggered > \(pos.x): \(pos.y)")
        
        let pixel_colour = getPixelFromBufferAtPosition(pos)
        print(pixel_colour)
    }
    
    
    /// Returns the pixel at the specified position
    func getPixelFromBufferAtPosition(_ pos:simd_int2) -> Array<Int> {
        
        // MAGIC NUMBERS!
        // There seems to be a weird bug in Gestures when getting the press location, it seems to return the press location value.
        let texSpacePoint : (x:Int, y:Int) = (x: Int(pos.x) * 2,
                                              y: Int(renderer.viewportSize.y) - Int(pos.y * 2))
                
        let idx:Int = Int((texSpacePoint.y * Int(renderer.viewportSize.x) + texSpacePoint.x) * 4)
        
        
        let pixel_colour : Array<UInt8> = [colourID_buffer![idx]    ,
                                       colourID_buffer![idx + 1],
                                       colourID_buffer![idx + 2],
                                       colourID_buffer![idx + 3]]
        
        return [ Int(pixel_colour[0]), Int(pixel_colour[1]), Int(pixel_colour[2]) ]
    }
    
    func setRenderer(_ renderer : Renderer) {
        self.renderer = renderer
    }
}
