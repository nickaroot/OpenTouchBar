//
//  DockWidgetItemView.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 12/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class DockWidgetItemView: NSScrubberItemView, NSAnimationDelegate {
  
  var appIconContainerView: NSView
  var appIconLayer: CALayer
  var appRunningView: NSImageView
  var appPath: String
  
  private var _appLaunching: Bool
  private var _prominent: Bool
  private var _scaled: Bool
  private var _scale: CGFloat
  
  var appIcon: NSImage {
    
    get {
      
      guard let image = self.appIconLayer.contents as? NSImage else { return NSImage() }
      
      return image
      
    }
    
    set {
      
      self.appIconLayer.contents = newValue
      
    }
    
  }
  
  var appRunning: Bool {
    
    get {
      
      return self.appRunningView.layer?.opacity != 0
      
    }
    
    set {
      
      NSAnimationContext.runAnimationGroup { (context) in
        
        context.duration = newValue ? 0 : 0.7
        
        self.appRunningView.animator().alphaValue = newValue ? 1 : 0
        
      }
      
    }
    
  }
  
  var appLaunching: Bool {
    
    get {
      
      return _appLaunching
      
    }
    
    set {
      
      guard _appLaunching != newValue else { return }
      
      _appLaunching = newValue
      
      self.bounce()
      
    }
    
  }
  
  var prominent: Bool {
    
    get {
      
      return _prominent
      
    }
    
    set {
      
      guard _prominent != newValue else { return }
      
      _prominent = newValue
      
      let shadow = DockWidget.shadowWithOffset(shadowOffset: NSSize(width: 0, height: -DockWidget.dockDotHeight))
      
      self.appIconContainerView.shadow = _prominent ? shadow : nil
      
    }
    
  }
  
  var scaled: Bool {
    
    get {
      
      return _scaled
      
    }
    
    set {
      
      guard _scaled != newValue else { return }
      
      _scaled = newValue
      
      self.zoom(with: scale)
      
    }
    
  }
  
  var scale: CGFloat {
    
    get {
      
      return _scale
      
    }
    
    set {
      
      _scale = newValue
      
    }
    
  }
  
  
  override init(frame frameRect: NSRect) {
    
    self.appIconContainerView = NSView(frame: frameRect)
    self.appIconContainerView.autoresizingMask = [.width, .height]
    
    self.appIconLayer = CALayer()
    self.appIconLayer.contentsGravity = .resizeAspect
    self.appIconLayer.contentsRect = NSRect(x: -0.075, y: -0.15, width: 1.15, height: 1.15)
    
    self.appRunningView = NSImageView(image: NSImage(named: "DockDot") ?? NSImage()) // TODO: Images List
    self.appRunningView.imageScaling = NSImageScaling.scaleProportionallyDown
    self.appRunningView.autoresizingMask = [.width, .height]
    self.appRunningView.alphaValue = 0
    
    self.appPath = ""
    self._appLaunching = false
    self._prominent = false
    self._scaled = false
    self._scale = 0
    
    super.init(frame: frameRect)
    
    self.appIconContainerView.layer = appIconLayer
    
    self.addSubview(self.appIconContainerView)
    self.addSubview(self.appRunningView)
    
  }
  
  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bounce() {
    
    guard _appLaunching else { return }
    
    let positionAnim = CAKeyframeAnimation(keyPath: "position.y")

    positionAnim.duration = 0.7

    positionAnim.values = [
      self.appIconLayer.position.y,
      self.appIconLayer.position.y + 10,
      self.appIconLayer.position.y,
    ]

    positionAnim.keyTimes = [
      0,
      0.5,
      1.0,
    ]

    positionAnim.timingFunctions = [
      CAMediaTimingFunction(name: .easeIn),
      CAMediaTimingFunction(name: .easeOut),
      CAMediaTimingFunction(name: .easeIn),
    ]



    positionAnim.repeatCount += 1

    
    self.appIconLayer.add(positionAnim, forKey: nil)
    
    Timer.scheduledTimer(withTimeInterval: positionAnim.duration, repeats: true) { (t) in
      
      if self.appLaunching {
        
        positionAnim.repeatCount += 1
        
      } else {
        
        t.invalidate()
        
        self.appIconLayer.removeAnimation(forKey: "position.y")
        
      }
      
    }
    
  }
  
  func zoom(with position: CGFloat) {
    
    let scaledSize = 0.25 * position
    let scaledX = -0.125 * position
    let scaledY = -0.05 * position
    
    let scaledRect = NSRect(x: -0.075 - scaledX, y: -0.15 - scaledY, width: 1.15 - scaledSize, height: 1.15 - scaledSize)
    let regularRect = NSRect(x: -0.075, y: -0.15, width: 1.15, height: 1.15)
    
    self.appIconLayer.contentsRect = _scaled ? scaledRect : regularRect
    
  }
  
}
