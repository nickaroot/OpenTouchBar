//
//  KeyEvent.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

import AppKit
import IOKit.hidsystem

extension System {
  
  static func postKeyPress(_ keyCode: CGKeyCode, _ flags: CGEventFlags?) {
    
    postKeyDown(keyCode, flags)
    
    postKeyUp(keyCode, flags)
    
  }
  
  static func postKeyDown(_ keyCode: CGKeyCode, _ flags: CGEventFlags?) {
    
    let src = CGEventSource(stateID: .hidSystemState)
    
    guard let keyDown = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: true) else { return }
    
    if let flags = flags {
      
      keyDown.flags = flags
      
    }
    
    keyDown.post(tap: .cghidEventTap)
    
  }
  
  static func postKeyUp(_ keyCode: CGKeyCode, _ flags: CGEventFlags?) {
    
    let src = CGEventSource(stateID: .hidSystemState)
    
    guard let keyUp = CGEvent(keyboardEventSource: src, virtualKey: keyCode, keyDown: false) else { return }
    
    if let flags = flags {
      
      keyUp.flags = flags
      
    }
    
    keyUp.post(tap: .cghidEventTap)
    
  }
  
  static func postAuxKeyPress(_ auxKeyCode: Int32) {
    
    let eventDown = NSEvent.otherEvent(
      with: .systemDefined,
      location: NSPoint.zero,
      modifierFlags: NSEvent.ModifierFlags(rawValue: 0xa00),
      timestamp: 0,
      windowNumber: 0,
      context: nil,
      subtype: Int16(NX_SUBTYPE_AUX_CONTROL_BUTTONS),
      data1: (Int((NX_KEYDOWN << 8 as Int32) | (auxKeyCode << 16 as Int32))),
      data2: -1
    )
    
    eventDown?.cgEvent?.post(tap: .cghidEventTap)
    
    let eventUp = NSEvent.otherEvent(
      with: .systemDefined,
      location: NSPoint.zero,
      modifierFlags: NSEvent.ModifierFlags(rawValue: 0xa00),
      timestamp: 0,
      windowNumber: 0,
      context: nil,
      subtype: Int16(NX_SUBTYPE_AUX_CONTROL_BUTTONS),
      data1: (Int((NX_KEYUP << 8 as Int32) | (auxKeyCode << 16 as Int32))),
      data2: -1
    )
    
    eventUp?.cgEvent?.post(tap: .cghidEventTap)
    
  }
  
}
