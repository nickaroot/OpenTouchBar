//
//  TouchBarController.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

class TouchBarController: NSViewController {
  
  @IBOutlet var appTouchBar: NSTouchBar!
  
  var presented: Bool = false
  
  static func controller(nibNamed name: NSNib.Name) -> TouchBarController? {
    
    let controller = self.init()
    
    var objects: NSArray?
    
    guard Bundle.main.loadNibNamed(name, owner: controller, topLevelObjects: &objects) else { return nil }
    
    return controller
    
  }
  
  deinit {
    
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    
    self.appTouchBar = nil
    
  }
  
  func present() -> Bool {
    
    return present(placement: 1)
    
  }
  
  func present(placement: Int) -> Bool {
    
    if !self.presented {
      
      System.presentSystemModal(self.appTouchBar, placement: UInt64(placement), systemTrayItemIdentifier: .init(""))
      
      self.presented = true
      
      return true
      
    }
    
    return false
    
  }
  
  func dismiss() {
    
    if self.presented {
      
      System.dismissSystemModal(self.appTouchBar)
      
      self.presented = false
      
    }
    
  }
  
  @IBAction func close(_ sender: Any) {
    
    self.dismiss()
    
  }
  
  @IBAction func customize(_ sender: Any) {
    
    NSApp.touchBar = self.appTouchBar
    
    self.perform(#selector(delayedCustomize), with: nil, afterDelay: 0)
    
  }
  
  @objc
  func delayedCustomize() {
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.willEnterCustomization(_:)),
      name: NSNotification.Name("NSTouchBarWillEnterCustomization"),
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.didExitCustomization(_:)),
      name: NSNotification.Name("NSTouchBarDidExitCustomization"),
      object: nil
    )
    
    NSApp.toggleTouchBarCustomizationPalette(self)
    
  }
  
  @objc
  func willEnterCustomization(_ notification: NSNotification) {
    
    self.dismiss()
    
  }
  
  @objc
  func didExitCustomization(_ notification: NSNotification) {
    
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name("NSTouchBarWillEnterCustomization"),
      object: nil
    )
    
    NotificationCenter.default.removeObserver(
      self,
      name: NSNotification.Name("NSTouchBarDidExitCustomization"),
      object: nil
    )
    
    NSApp.touchBar = nil
    
    _ = self.present()
    
  }
  
}
