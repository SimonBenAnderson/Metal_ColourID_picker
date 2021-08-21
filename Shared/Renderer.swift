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
        view.sampleCount = 0
        // Clear to solid white
        view.clearColor = MTLClearColorMake(0.0, 0.35, 0.35, 1)
        // Use a BGRA 8-bit normalized texture for the drawable
//        view.colorPixelFormat = .bgra8Unorm
        // Use a 32-bit depth buffer
//        view.depthStencilPixelFormat = .depth32Float
        // Sets the view to try and render at 120fps
        view.preferredFramesPerSecond = 1
        
//        view.drawableSize = view.frame.size
        viewportSize.x = Float(view.frame.size.width)
        viewportSize.y = Float(view.frame.size.height)
        
        // needed for ZDepth
//        view.depthStencilPixelFormat = .depth32Float
        
        view.colorPixelFormat = .bgra8Unorm
        
        
        /// The view will use Textures to display what it shows, This allows you to write data into a texture, perform any manipulatin on the texture and then show it. For us we are currently not performing any manipulation.
        view.framebufferOnly = false
        
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
        
        /// Tells the pipelineState that there will be two colour attachments
        /// This reflects the colour(0), colour(1) you can see in the shader
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.colorAttachments[1].pixelFormat = view.colorPixelFormat
        
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
        let q3 = newQuad()
        let q4 = newQuad()
        let q5 = newQuad()
        
        quads.append(q1)
        quads.append(q2)
        quads.append(q3)
        quads.append(q4)
        quads.append(q5)
        
        q1.offset = [-200,  100]
        q2.offset = [-200, -100]
        q3.offset = [   0,    0]
        q4.offset = [ 200,  100]
        q5.offset = [ 200, -100]
        
        q1.color = [0.4, 0.4, 0.4, 1]
        q2.color = [0.4, 0.4, 0.4, 1]
        q3.color = [0.4, 0.4, 0.4, 1]
        q4.color = [0.4, 0.4, 0.4, 1]
        q5.color = [0.4, 0.4, 0.4, 1]
        
        q1.updateVerts()
        q2.updateVerts()
        q3.updateVerts()
        q4.updateVerts()
        q5.updateVerts()
        
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
        
        
        let tex0_desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                 width: Int(viewportSize.x),
                                                                 height: Int(viewportSize.y),
                                                                 mipmapped: false)
        let tex1_desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm,
                                                                 width: Int(viewportSize.x),
                                                                 height: Int(viewportSize.y),
                                                                 mipmapped: false)
        
        tex0_desc.usage = [.renderTarget]
        tex1_desc.usage = [.renderTarget]
        
        tex0_desc.storageMode = .private
        tex1_desc.storageMode = .shared
        
        let tex0 = device.makeTexture(descriptor: tex0_desc)
        let tex1 = device.makeTexture(descriptor: tex1_desc)
        
        renderPassDescriptor.colorAttachments[0].texture = tex0
        renderPassDescriptor.colorAttachments[1].texture = tex1
        
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[1].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[1].loadAction = .clear
        
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
        
        /// Setting up the different storage options for different devices
        var storageMode : MTLResourceOptions
        #if os(OSX)
        storageMode = MTLResourceOptions.storageModeManaged
        #elseif os(iOS)
        storageMode = MTLResourceOptions.storageModeShared
        #endif
        
        /// Creates a buffer that will be managed between the cpu and gpu
//        let buffer = device.makeBuffer(length: MemoryLayout<Vertex>.stride * (quadVerts.count), options: storageMode)
//        
//        let bufferStartPointer = buffer?.contents()
        
        
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
        
        
        // Create a Blit Command Encoder, which is used to copy data from one memory location to another using the GPU
        let blitEncoder = commandBuffer.makeBlitCommandEncoder()
        
        // Schedules a present once the framebuffer is complete using the current drawable.
        guard let drawable = view.currentDrawable else { return }
        
        // Copy's the data from tex0 to the view
        if tex0 != nil {
            blitEncoder?.copy(from: tex0!, to:drawable.texture)
            blitEncoder?.endEncoding()
        }
        
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
