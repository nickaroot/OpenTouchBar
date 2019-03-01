//
//  EscKeyWidgetButton.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class EscKeyWidgetButton: NSButton {
  
  override open var intrinsicContentSize: NSSize {
    
    var size = super.intrinsicContentSize
    
    size.width = min(size.width, 64)
    
    return size
    
  }
  
  override open class var cellClass: AnyClass? {
    
    get { return EscKeyWidgetButtonCell.self }
    
    set { }
    
  }
  
}
