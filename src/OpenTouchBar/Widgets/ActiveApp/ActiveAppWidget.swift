//
//  ActiveAppWidget.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class ActiveAppWidget: CustomWidget {
  
  override func commonInit() {
    
    self.customizationLabel = "Active App"
    
    let label = FixedSizeLabel(labelWithString: "Active App")
    
    label.fixedSize = CGSize(width: 130, height: NSView.noIntrinsicMetric)
    label.wantsLayer = true
    label.layer?.cornerRadius = 8.0
    label.layer?.backgroundColor = NSColor(white: 0.0, alpha: 0.5).cgColor
    label.alignment = .center
    label.lineBreakMode = .byTruncatingTail
    label.isBezeled = false
    label.isEditable = false
    label.sizeToFit()
    
    self.setView(label)
    
  }
  
  deinit {
    
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    
  }
  
  override func viewWillAppear() {
    
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(didActivateApplication(_:)),
      name: NSWorkspace.didActivateApplicationNotification,
      object: nil
    )
    
    self.reset()
    
  }
  
  override func viewDidDisappear() {
    
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    
  }
  
  @objc
  func didActivateApplication(_ notification: NSNotification) {
    
    self.reset()
    
  }
  
  func reset() {
    
    if let app = NSWorkspace.shared.menuBarOwningApplication {
      
      guard let label = self.view as? NSTextField else { return }
      
      label.stringValue = app.localizedName ?? "Active App"
      
    }
    
  }
  
}
