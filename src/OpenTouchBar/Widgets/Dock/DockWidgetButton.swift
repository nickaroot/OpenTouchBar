//
//  DockWidgetButton.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 13/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class DockWidgetButton: NSButton {
  
  var url: URL?
  var appIconLayer: CALayer
  
  var regularImage: NSImage {
    
    get {
      
      guard let image = self.appIconLayer.contents as? NSImage else { return NSImage() }
      
      return image
      
    }
    
    set {
      
      self.appIconLayer.contents = newValue
      
    }
    
  }
  
  private var _prominent = false
  
  var prominent: Bool {
    
    get {
      
      return _prominent
      
    }
    
    set {
      
      guard _prominent != newValue else { return }
      
      _prominent = newValue
      
      self.resetImage()
      
    }
    
  }
  
  override open var intrinsicContentSize: NSSize {
    
    return DockWidget.dockItemSize
    
  }
  
  required init?(coder: NSCoder) {
    
    self.appIconLayer = CALayer()
    
    super.init(coder: coder)
    
    self.title = ""
    
  }
  
  init(with regularImage: NSImage, target: Any?, action: Selector?) {
    
    self.appIconLayer = CALayer()
    //        self.appIconLayer.backgroundColor = NSColor.white.cgColor
    self.appIconLayer.contentsGravity = .resizeAspect
    
    super.init(frame: NSRect(origin: .zero, size: DockWidget.dockItemSize))
    
    self.title = ""
    
    self.regularImage = regularImage
    
    self.layer = appIconLayer
    
    self.target = target as AnyObject
    self.action = action
    
  }
  
  func resetImage() {
    
    self.appIconLayer.contentsRect = _prominent ? NSRect(x: 0.05, y: 0.1, width: 0.9, height: 0.9) :
      NSRect(x: 0, y: 0, width: 1, height: 1)
    
    self.shadow = _prominent ?
      DockWidget.shadowWithOffset(shadowOffset: NSSize(width: 0, height: -DockWidget.dockDotHeight)) : nil
    
  }
  
}
