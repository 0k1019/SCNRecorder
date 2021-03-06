//
//  MetalViewRenderer.swift
//  Example
//
//  Created by Vladislav Grigoryev on 18.11.2020.
//  Copyright © 2020 GORA Studio. https://gora.studio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import Metal
import UIKit

@available(iOS 13.0, *)
final class SquadRenderer {

  static let red = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).vec3

  static let green = UIColor(displayP3Red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0).vec3

  static let blue = UIColor(displayP3Red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0).vec3

  static let magenta = UIColor(displayP3Red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0).vec3

  static let quadVertices = [
    MetalVertex(position: vector_float2(250, -250), color: red),
    MetalVertex(position: vector_float2(-250, -250), color: green),
    MetalVertex(position: vector_float2(-250, 250), color: blue),

    MetalVertex(position: vector_float2(250, -250), color: red),
    MetalVertex(position: vector_float2(-250, 250), color: blue),
    MetalVertex(position: vector_float2(250, 250), color: magenta)
  ]

  let device: MTLDevice

  let commandQueue: MTLCommandQueue

  let pipelineState: MTLRenderPipelineState

  let vertices: MTLBuffer

  let drawableRenderDescriptor: MTLRenderPassDescriptor

  var viewportSize = vector_uint2(0, 0)

  var frame = 0

  init?(device: MTLDevice, pixelFormat: MTLPixelFormat) {
    self.device = device

    guard let commandQueue = device.makeCommandQueue() else { return nil }
    self.commandQueue = commandQueue

    drawableRenderDescriptor = MTLRenderPassDescriptor()

    drawableRenderDescriptor.colorAttachments[0].loadAction = .clear
    drawableRenderDescriptor.colorAttachments[0].storeAction = .store
    drawableRenderDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 1, 1, 1)

    guard let vertices = device.makeBuffer(
      bytes: Self.quadVertices,
      length: MemoryLayout<MetalVertex>.stride * Self.quadVertices.count,
      options: .storageModeShared
    ) else {
      return nil
    }

    self.vertices = vertices
    self.vertices.label = "Quad"

    guard let library = device.makeDefaultLibrary(),
          let vertexProgram = library.makeFunction(name: "vertexShader"),
          let fragmentProgram = library.makeFunction(name: "fragmentShader")
    else { return nil }

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.label = "QuadPipeline"
    pipelineDescriptor.vertexFunction = vertexProgram
    pipelineDescriptor.fragmentFunction = fragmentProgram
    pipelineDescriptor.colorAttachments[0].pixelFormat = pixelFormat

    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }
    catch {
      print(error)
      return nil
    }
  }

  func renderToMetalLayer(_ metalLayer: CAMetalLayer) {
    autoreleasepool { _renderToMetalLayer(metalLayer) }
  }

  private func _renderToMetalLayer(_ metalLayer: CAMetalLayer) {
    frame += 1

    guard let currentDrawable = metalLayer.nextDrawable() else { return }
    drawableRenderDescriptor.colorAttachments[0].texture = currentDrawable.texture

    guard let commandBuffer = commandQueue.makeCommandBuffer(),
          let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: drawableRenderDescriptor
          )
    else { return }

    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(
      vertices,
      offset: 0,
      index: Int(MetalVertexInputIndexVertices.rawValue)
    )

    var uniforms = MetalUniforms(
      scale: 0.5 + (1.0 + 0.5 * sin(Float(frame) * 0.1)),
      viewportSize: viewportSize
    )
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<MetalUniforms>.size,
      index: Int(MetalVertexInputIndexUniforms.rawValue)
    )

    renderEncoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: Self.quadVertices.count
    )
    renderEncoder.endEncoding()

    commandBuffer.present(currentDrawable)
    commandBuffer.commit()
  }

  func drawableResize(_ size: CGSize) {
    viewportSize.x = UInt32(size.width)
    viewportSize.y = UInt32(size.height)
  }
}
