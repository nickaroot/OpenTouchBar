//
//  EscKeyWidgetButtonCell.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 12/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class EscKeyWidgetButtonCell: NSButtonCell {
  
  override func titleRect(forBounds rect: NSRect) -> NSRect {
    
    var centerRect = super.titleRect(forBounds: rect)
    
    centerRect.origin.y = rect.origin.y + rect.size.height - (centerRect.size.height +
      (centerRect.origin.y - rect.origin.y)) - 1.5
    
    return centerRect
    
  }
  
}
