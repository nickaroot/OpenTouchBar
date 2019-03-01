//
//  CustomMultiWidget.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class CustomMultiWidget: CustomWidget { // FOR TEST ONLY // TODO
  
  private(set) var widgets: [NSTouchBarItem] = []
  
  var activeIndex: Int {
    
    get {
      
      var index = 0
      
      for widget in widgets {
        
        if widget.view?.superview == self.view {
          
          return index
          
        }
        
        index += 1
        
      }
      
      return NSNotFound
      
    }
    
    set {
      
      if self.activeIndex != newValue {
        
        self.view.subviews.first?.removeFromSuperview()
        
        if newValue < widgets.count {
          
          guard let newView = widgets[newValue].view else { return }
          
          self.view.addSubview(newView)
          
        }
        
      }
      
    }
    
  }
  
}
