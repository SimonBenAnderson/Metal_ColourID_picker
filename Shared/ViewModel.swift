//
//  ViewModel.swift
//  SwiftUI_QuadSelection
//
//  Created by Simon Anderson on 8/08/21.
//

import Foundation
import Metal

#if os(OSX)
import AppKit
#elseif os(iOS)
import UIKit
#endif

/// ViewModel, should be a more descriptive name, but as this is for learning purposes I have kept it in name with the MVVM naming
/// Model, View, ViewModel

/// View Models have to be a class as they to have a reference pointer
class ViewModel {
    
    var renderer : Renderer!
    
    /// Texture buffer data that stores the colour picker data that was copied from the GPU
    /// eg. Row_0, Row_1, Row_2
    var colourID_buffer : [UInt8]?
    
    init() { }
    
    // When the user presses on the screen this is triggered
    func pressTriggered(_ pos:simd_int2) {
        let pixel_colour = getPixelFromBufferAtPosition(pos)
        print(pixel_colour)
    }
    
    #if os(OSX)
    /// Returns the pixel at the specified position
    func getPixelFromBufferAtPosition(_ pos:simd_int2) -> Array<Int> {
        // Gets the screen scale depending on the monitor settings
        let screenScale :Int = Int(NSScreen.main!.backingScaleFactor)
        
        /// As the y position starts at the bottom, but the data is serialised from the top of the screen we have to reverse the y values, which is why it has been subtracted from the size of the y axis.
        let texSpacePoint : (x:Int, y:Int) = (x: Int(pos.x) * screenScale,
                                              //y: Int(renderer.viewportSize.y) - Int(pos.y) * screenScale)
                                              y: Int(pos.y) * screenScale)
        
        // Takes the X, Y position and converts it into an index value, that will be used to retrieve the pixel position.
        //   4 = the number of Floats that make up the colour per a pixel
        let idx:Int = Int((texSpacePoint.y * Int(renderer.viewportSize.x) + texSpacePoint.x) * 4)
        
        let pixel_colour : Array<UInt8> = [colourID_buffer![idx],
                                           colourID_buffer![idx + 1],
                                           colourID_buffer![idx + 2],
                                           colourID_buffer![idx + 3]]
        
        return [ Int(pixel_colour[0]), Int(pixel_colour[1]), Int(pixel_colour[2]), Int(pixel_colour[3]) ]
    }
    
    #elseif os(iOS)
    /// Returns the pixel at the specified position
    func getPixelFromBufferAtPosition(_ pos:simd_int2) -> Array<Int> {
        
        // I was using the UI Scale amount, but it seems that the MTKView has its own scale amount.
        let CONTENT_SCALE = Float(renderer.view.contentScaleFactor.native)

        let screenScale :Int = Int(UIScreen.main.scale)
        
// Commented out for testing CONTENT SCALE
//        let texSpacePoint : (x:Int, y:Int) = (x: Int(pos.x) * screenScale,
//                                              y: Int(pos.y) * screenScale)
        let texSpacePoint : (x:Int, y:Int) = (x: Int(Float(pos.x) * CONTENT_SCALE),
                                              y: Int(Float(pos.y) * CONTENT_SCALE))

        
        // Takes the X, Y position and converts it into an index value, that will be used to retrieve the pixel position.
        //   4 = the number of Floats that make up the colour per a pixel
        let idx:Int = Int((texSpacePoint.y * Int(renderer.viewportSize.x) + texSpacePoint.x) * 4)
        
        let pixel_colour : Array<UInt8> = [colourID_buffer![idx],
                                           colourID_buffer![idx + 1],
                                           colourID_buffer![idx + 2],
                                           colourID_buffer![idx + 3]]
        
        return [ Int(pixel_colour[0]), Int(pixel_colour[1]), Int(pixel_colour[2]), Int(pixel_colour[3]) ]
    }
    #endif
    
    func setRenderer(_ renderer : Renderer) {
        self.renderer = renderer
    }
}
