//
//  CAMetalLayer+RecordableLayer.swift
//  SCNRecorder
//
//  Created by Vladislav Grigoryev on 30.12.2019.
//  Copyright © 2020 GORA Studio. All rights reserved.
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
import UIKit

#if !targetEnvironment(simulator)

private var lastFramebufferOnlyKey: UInt8 = 0
private var lastDrawableKey: UInt8 = 0
private var isRecordingKey: UInt8 = 0

extension CAMetalLayer {

  var lastFramebufferOnlyStorage: AssociatedStorage<Bool> {
    AssociatedStorage(object: self, key: &lastFramebufferOnlyKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  var lastDrawableStorage: AssociatedStorage<CAMetalDrawable> {
    AssociatedStorage(object: self, key: &lastDrawableKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }

  var isRecordingStorage: AssociatedStorage<Bool> {
    AssociatedStorage(object: self, key: &isRecordingKey, policy: .OBJC_ASSOCIATION_RETAIN)
  }
}

extension CAMetalLayer {

  static let swizzleNextDrawableImplementation: Void = {
      let aClass: AnyClass = CAMetalLayer.self

      guard let originalMethod = class_getInstanceMethod(aClass, #selector(nextDrawable)),
            let swizzledMethod = class_getInstanceMethod(aClass, #selector(swizzled_nextDrawable))
      else { return }

      method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static let swizzleSetFramebufferOnlyImplementation: Void = {
      let aClass: AnyClass = CAMetalLayer.self

      guard let originalMethod = class_getInstanceMethod(aClass, #selector(setter: framebufferOnly)),
            let swizzledMethod = class_getInstanceMethod(aClass, #selector(swizzled_setFramebufferOnly))
      else { return }

      method_exchangeImplementations(originalMethod, swizzledMethod)
  }()

  static func swizzle() {
    _ = swizzleNextDrawableImplementation
    _ = swizzleSetFramebufferOnlyImplementation
  }

  var _lastDrawable: CAMetalDrawable? {
    get { lastDrawableStorage.get() }
    set { lastDrawableStorage.set(newValue) }
  }

  var lastFramebufferOnly: Bool {
    get { lastFramebufferOnlyStorage.get() ?? framebufferOnly }
    set { lastFramebufferOnlyStorage.set(newValue) }
  }

  var isRecording: Bool {
    get { isRecordingStorage.get() ?? false }
    set { isRecordingStorage.set(newValue) }
  }

  func swizzle() { Self.swizzle() }

  @objc dynamic func swizzled_nextDrawable() -> CAMetalDrawable? {
    _lastDrawable = swizzled_nextDrawable()
    return _lastDrawable
  }

  @objc dynamic func swizzled_setFramebufferOnly(_ framebufferOnly: Bool) {
    if isRecording { lastFramebufferOnly = framebufferOnly }
    else { swizzled_setFramebufferOnly(framebufferOnly) }
  }
}

extension CAMetalLayer: RecordableLayer { }

#endif // !targetEnvironment(simulator)
