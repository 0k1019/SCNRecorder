//
//  AppDelegate.swift
//  Example
//
//  Created by Vladislav Grigoryev on 12/03/2019.
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

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

  func application(
    _ application: UIApplication,
    willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    if #available(iOS 13.0, *) {
      #if compiler(>=5.1)
      let appearance = UINavigationBarAppearance()
      appearance.configureWithTransparentBackground()
      UINavigationBar.appearance().standardAppearance = appearance
      #endif
    } else {
      UINavigationBar.appearance().isTranslucent = true
      UINavigationBar.appearance().shadowImage = UIImage()
      UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    let mainViewController = MainViewController()
    let navigationController = UINavigationController(rootViewController: mainViewController)

    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()

    return true
  }
}
