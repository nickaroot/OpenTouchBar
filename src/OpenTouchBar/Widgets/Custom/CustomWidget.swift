//
//  CustomWidget.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

/**
 
 A wrapper for OpenTouchBar widget.
 
 - important:
 
 * Any subclass **must** be named with `Widget` postfix.
 
 * Override **commonInit()** function instead of `init(identifier:)`
 
 */

class CustomWidget: NSCustomTouchBarItem {
  
  static let shortPressDuration = 0.25
  static let longPressDuration = 0.75
  
  /// Auto-generated widget identifier
  static var widgetIdentifier: NSTouchBarItem.Identifier {
    
    var name = className()
    
    name = name.components(separatedBy: ".")[1]
    
    name = name.hasSuffix("Widget") ? name.components(separatedBy: "Widget")[0] : ""
    
    let identifier = NSTouchBarItem.Identifier(name)
    
    if TouchBarDelegate.widgets[identifier] == nil {
      
      let item = TouchBarDelegate.WidgetItem(class: self, object: nil)
      
      TouchBarDelegate.widgets[identifier] = item
      
    }
    
    return identifier
    
  }
  
  override init(identifier: NSTouchBarItem.Identifier) {
    
    super.init(identifier: identifier)
    
    self.commonInit_()
    
  }
  
  required init?(coder: NSCoder) {
    
    super.init(coder: coder)
    
    self.commonInit_()
    
  }
  
  private func commonInit_() {
    
    let controller = CustomWidgetViewController()
    controller.widget = self
    viewController = controller
    
    commonInit()
    
  }
  
  /**
   
   Custom Widget `init`.
   
   - important:
   
   Override **this** function instead of `init(identifier:)`
   
   */
  
  func commonInit() { }
  
  func viewWillAppear() { }
  
  func viewDidAppear() { }
  
  func viewWillDisappear() { }
  
  func viewDidDisappear() { }
  
  func setView(_ view: NSView) {
    
    self.viewController?.view = view
    
  }
  
}
