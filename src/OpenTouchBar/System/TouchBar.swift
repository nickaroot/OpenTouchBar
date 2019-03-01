//
//  TouchBar.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 31/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

import AppKit

@objc
protocol NSTouchBarItemPrivateProtocol {
  
  @objc
  optional static func addSystemTrayItem(_ item: NSTouchBarItem)
  
  @objc
  optional static func removeSystemTrayItem(_ item: NSTouchBarItem)
  
}

@objc
protocol NSTouchBarPrivateProtocol {
  
  @available(macOS 10.14, *)
  @objc
  optional static func presentSystemModalTouchBar(_ touchBar: NSTouchBar, placement: UInt64,
                                                  systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier)
  
  @available(macOS 10.14, *)
  @objc
  optional static func presentSystemModalTouchBar(_ touchBar: NSTouchBar,
                                                  systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier)
  
  @available(macOS 10.14, *)
  @objc
  optional static func dismissSystemModalTouchBar(_ touchBar: NSTouchBar)
  
  @available(macOS 10.14, *)
  @objc
  optional static func minimizeSystemModalTouchBar(_ touchBar: NSTouchBar)
  
  @available(macOS, deprecated: 10.14, renamed: "presentSystemModalTouchBar")
  @objc
  optional static func presentSystemModalFunctionBar(_ touchBar: NSTouchBar, placement: UInt64,
                                                     systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier)
  
  @available(macOS, deprecated: 10.14, renamed: "presentSystemModalTouchBar")
  @objc
  optional static func presentSystemModalFunctionBar(_ touchBar: NSTouchBar,
                                                     systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier)
  
  @available(macOS, deprecated: 10.14, renamed: "presentSystemModalTouchBar")
  @objc
  optional static func dismissSystemModalFunctionBar(_ touchBar: NSTouchBar)
  
  @available(macOS, deprecated: 10.14, renamed: "minimizeSystemModalTouchBar")
  @objc
  optional static func minimizeSystemModalFunctionBar(_ touchBar: NSTouchBar)
  
}

let libDFRFoundation = dlopen("/System/Library/PrivateFrameworks/DFRFoundation.framework/DFRFoundation", RTLD_NOW)

let DFRElementSetControlStripPresenceForIdentifier = unsafeBitCast(dlsym( // swiftlint:disable:this identifier_name
  libDFRFoundation,
  "DFRElementSetControlStripPresenceForIdentifier"
), to: (@convention (c) (NSTouchBarItem.Identifier, Bool) -> Void).self)

let DFRSystemModalShowsCloseBoxWhenFrontMost = unsafeBitCast(dlsym(
  libDFRFoundation,
  "DFRSystemModalShowsCloseBoxWhenFrontMost"
), to: (@convention (c) (Bool) -> Void).self)

extension NSTouchBar: NSTouchBarPrivateProtocol { }

let NSTouchBarClass: NSTouchBar.Type! = NSClassFromString("NSTouchBar") as? NSTouchBar.Type
let NSTouchBarPrivate: NSTouchBarPrivateProtocol.Type = NSTouchBarClass

extension NSTouchBarItem: NSTouchBarItemPrivateProtocol { }

let NSTouchBarItemClass: NSTouchBarItem.Type! = NSClassFromString("NSTouchBarItem") as? NSTouchBarItem.Type
let NSTouchBarItemPrivate: NSTouchBarItemPrivateProtocol.Type = NSTouchBarItemClass

extension System {
  
  static func presentSystemModal(_ touchBar: NSTouchBar, placement: UInt64,
                                 systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier) {
    
    if #available(macOS 10.14, *) {
      
      NSTouchBarPrivate.presentSystemModalTouchBar!(touchBar, placement: placement,
                                                    systemTrayItemIdentifier: identifier)
      
    } else {
      
      NSTouchBarPrivate.presentSystemModalFunctionBar!(touchBar, placement: placement,
                                                       systemTrayItemIdentifier: identifier)
      
    }
    
  }
  
  static func dismissSystemModal(_ touchBar: NSTouchBar) {
    
    if #available(macOS 10.14, *) {
      
      NSTouchBarPrivate.dismissSystemModalTouchBar!(touchBar)
      
    } else {
      
      NSTouchBarPrivate.dismissSystemModalFunctionBar!(touchBar)
      
    }
    
  }
  
}
