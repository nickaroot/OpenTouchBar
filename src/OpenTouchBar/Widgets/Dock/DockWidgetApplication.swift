//
//  DockWidgetApplication.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 12/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class DockWidgetApplication: NSObject, NSCopying {
  
  var name: String
  var path: String
  var icon: NSImage
  var isDefault: Bool
  var pid: pid_t
  var launching: Bool
  var terminated: Bool
  
  var key: String {
    
    return "\(pid):\(self.path)"
    
  }
  
  var defaultKey: String {
    
    return "0:\(self.path)"
    
  }
  
  init(
    with name: String,
    _ path: String,
    _ icon: NSImage,
    _ isDefault: Bool,
    _ pid: pid_t,
    _ launching: Bool,
    _ terminated: Bool
  ) {
    
    self.name = name
    self.path = path
    self.icon = icon
    self.isDefault = isDefault
    self.pid = pid
    self.launching = launching
    self.terminated = terminated
    
  }
  
  init(default name: String, _ path: String, _ icon: NSImage) {
    
    self.name = name
    self.path = path
    self.icon = icon
    self.isDefault = true
    self.pid = 0
    self.launching = false
    self.terminated = false
    
  }
  
  func copy(with zone: NSZone? = nil) -> Any {
    
    let copy = DockWidgetApplication(
      with: self.name,
      self.path,
      self.icon,
      self.isDefault,
      self.pid,
      self.launching,
      self.terminated
    )
    
    return copy
    
  }
  
}

typealias DockWidgetApplications = [DockWidgetApplication]
typealias DockWidgetApplicationPaths = [String: DockWidgetApplications]
