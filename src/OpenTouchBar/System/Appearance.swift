//
//  Appearance.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

typealias NSGlobalPreferenceTransitionBlock = @convention(block) () -> Void

@objc
protocol NSGlobalPreferenceTransitionProtocol: NSObjectProtocol {
  
  static func transition() -> AnyObject
  
  func waitForTransitionWithCompletionHandler(_ arg1: @escaping NSGlobalPreferenceTransitionBlock)
  func postChangeNotification(_ arg1: UInt64, completionHandler arg2: @escaping NSGlobalPreferenceTransitionBlock)
  
}

let libSkyLight = dlopen("/System/Library/PrivateFrameworks/SkyLight.framework/Skylight", RTLD_LAZY)

let SLSGetAppearanceThemeLegacy = unsafeBitCast(dlsym(
  libSkyLight,
  "SLSGetAppearanceThemeLegacy"
), to: (@convention (c) () -> Bool).self)

let SLSSetAppearanceThemeLegacy = unsafeBitCast(dlsym(
  libSkyLight,
  "SLSSetAppearanceThemeLegacy"
), to: (@convention (c) (Bool) -> Void).self)

let SLSSetAppearanceThemeNotifying = unsafeBitCast(dlsym(
  libSkyLight,
  "SLSSetAppearanceThemeNotifying"
), to: (@convention (c) (Bool, Bool) -> Void).self)

let NSGlobalPreferenceTransition: AnyClass = NSClassFromString("NSGlobalPreferenceTransition")!

extension System {
  
  enum Appearance {
    case aqua, darkAqua
  }
  
  static var appearance: Appearance {
    
    get { return (SLSGetAppearanceThemeLegacy() ? .darkAqua : .aqua) }
    
    set {
      
      var theme: Bool
      
      switch newValue {
        
      case .aqua:
        theme = false
        
      case .darkAqua:
        theme = true
        
      }
      
      let transition: AnyObject? = NSGlobalPreferenceTransition.transition()
      
      SLSSetAppearanceThemeNotifying(theme, transition == nil)
      
      transition!.postChangeNotification(0, completionHandler: {})
      
    }
    
  }
  
}
