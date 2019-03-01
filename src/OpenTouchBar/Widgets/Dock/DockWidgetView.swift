//
//  DockWidgetView.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 13/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class DockWidgetView: NSStackView {
  
  let dragTargetView: NSView!
  
  override open var intrinsicContentSize: NSSize {
    
    return NSSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    
  }
  
  override init(frame frameRect: NSRect) {
    
    let imageView = NSImageView(image: NSImage(named: "DragTarget") ?? NSImage())
    
    imageView.wantsLayer = true
    imageView.layer?.opacity = 0.8
    imageView.layer?.cornerRadius = 4
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.autoresizingMask = .none
    imageView.isHidden = true
    
    self.dragTargetView = imageView
    
    super.init(frame: frameRect)
    
    self.addSubview(self.dragTargetView)
    
  }
  
  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func dragViewAtPoint(point: NSPoint) -> NSView? {
    
    let point = self.convert(point, from: nil)
    
    var view = self.hitTest(point)
    
    while view != nil {
      
      guard let currentView = view else { return nil }
      
      if currentView.isKind(of: DockWidgetItemView.self) || currentView.isKind(of: DockWidgetButton.self) { break }
      
      view = currentView.superview
      
    }
    
    return view
    
  }
  
}
