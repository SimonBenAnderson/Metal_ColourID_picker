//
//  Renderer.swift
//  CustomMetalView
//
//  Created by Simon Anderson on 8/01/21.
//

import Foundation
import MetalKit
import SwiftUI
import simd

// MARK:- COORDINATOR / RENDERER
struct Vertex
{
    var position: simd_float2
    var color: simd_float4
    /// Used for color id picking
    var colorID: simd_float4
}

class Renderer : NSObject, MTKViewDelegate {
    /// View that will be displaying what is rendered
    var parent: SwiftMTKView
    
    /// property that access the view. This view is the MTKView wraooed in the SwiftMTKView
    var view: MTKView!
    
    var device: MTLDevice!
    
    // The render pipeline generated from the vertex and fragment shader in the .metal shader file
    var renderPipelineState : MTLRenderPipelineState!
    
    // The command queue used to pass commands to the device
    var commandQueue: MTLCommandQueue!
    
    /// Holds all the compiled metal files
    var metalLibrary:MTLLibrary?
    
    // The current size of the view, used as an input to the vertex shader
    // Initialises the variable, as it will have its values populated on init
    var viewportSize: simd_float2 = simd_float2()
    
    /// List of quad objects that will be drawn on screen
    var quads:Array<Quad> = []
    
    /// SwiftMTKView is the wrapper to allow the MTKView to work in SwiftUI
    init(_ parent: SwiftMTKView, mtkView:MTKView) {
        print("Init Coordinator")
        
        /// sets the SwiftMTKView as the parent
        self.parent = parent
        self.view = mtkView
        
        // Use 4x MSAA multisampling
        view.sampleCount = 1
        // Clear to solid white
        view.clearColor = MTLClearColorMake(0.0, 0.35, 0.35, 1)
        // Use a BGRA 8-bit normalized texture for the drawable
//        view.colorPixelFormat = .bgra8Unorm
        // Use a 32-bit depth buffer
//        view.depthStencilPixelFormat = .depth32Float
        // Sets the view to try and render at 120fps
//        view.preferredFramesPerSecond = 120
        
//        view.drawableSize = view.frame.size
        viewportSize.x = Float(view.frame.size.width)
        viewportSize.y = Float(view.frame.size.height)
        
        // needed for ZDepth
//        view.depthStencilPixelFormat = .depth32Float
        
        view.colorPixelFormat = .bgra8Unorm
        
        // Ask for the default Metal device; this represents our GPU.
        if let defaultDevice = MTLCreateSystemDefaultDevice() {
            device = defaultDevice
        }
        else {
            print("Metal is not supported")
        }

        // Create the CommandQueue we will be using to submit work to the GPU
        commandQueue = device.makeCommandQueue()!
        
        /// Compiles all .metal files together into one
        metalLibrary = device.makeDefaultLibrary()
        
        super.init()
        
        let vertexFunction = metalLibrary!.makeFunction(name: "vertexShader")
        let fragmentFunction = metalLibrary!.makeFunction(name: "fragmentShader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Simple Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        
        do {
        try  renderPipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        }
        catch
        {
            print("Set Pipeline Sate Failed")
        }
        
        // Now that all of our members are initialized, set ourselves as the drawing delegate of the view
        view.delegate = self
        view.device = device
        
        setupQuad()
    }
    
    /// Initialises the quad data, 
    func setupQuad() {
        // Creates the new quads that will be drawn
        let q1 = newQuad()
        let q2 = newQuad()
        quads.append(q1)
        quads.append(q2)
        
        q1.offset = [-200, 0]
        q2.offset = [ 200, 0]
        
        q1.color = [0.4, 0.4, 0.4, 1]
        q2.color = [0.4, 0.4, 0.4, 1]
        
        q1.updateVerts()
        q2.updateVerts()
    }
    
    open func render(_ view: MTKView)
    {
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else
        {
            print("Command Buffer failed to initialise")
            return
        }
        
        draw(view, commandBuffer)
    }
    
    open func draw(_ view: MTKView, _ commandBuffer_: MTLCommandBuffer) {

        // Create a new command buffer for each render pass to the current drawable.
        let commandBuffer = commandQueue.makeCommandBuffer()!
        commandBuffer.label = "MyCommand"
        
        // Obtain a renderPassDescriptor generated from the view's drawable textures.
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        // Create a render command encoder.
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }

        renderEncoder.label = "MyRenderEncoder"
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0,
                                              originY: 0.0,
                                              width: Double(viewportSize.x),
                                              height: Double(viewportSize.y),
                                              znear: 0.0,
                                              zfar: 1.0))
        
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        var quadVerts:Array<Vertex> = []
        for quad in quads {
            quadVerts.append(contentsOf: quad._vertices)
        }
        
        // Pass in the parameter data.
        renderEncoder.setVertexBytes(quadVerts,
                                     length: MemoryLayout<Vertex>.stride * (quadVerts.count),
                                     index: 0)
        
        renderEncoder.setVertexBytes(&viewportSize,
                                     length: MemoryLayout<simd_uint2>.stride,
                                     index: 1)
        
        // Draw the buffer using triangles
        renderEncoder.drawPrimitives(type: .triangle,
                                     vertexStart: 0,
                                     vertexCount: quadVerts.count)
        
        renderEncoder.endEncoding()
        
        // Schedules a present once the framebuffer is complete using the current drawable.
        guard let drawable = view.currentDrawable else { return }
        commandBuffer.present(drawable)
        
        // Finalize rendering here and push the comand buffer to the GPU.
        commandBuffer.commit()
    }

    // [Built in]
    // Updates the view's contents upon receiving a change in layout, resolution, or size
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Save the size of the drawable to pass to the vertex shader.
        viewportSize.x = Float(size.width)
        viewportSize.y = Float(size.height)
    }
    
    // [Built in]
    func draw(in view: MTKView) {
        render(view)
    }
}
