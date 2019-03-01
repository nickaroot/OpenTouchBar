//
//  FixedSizeLabelCell.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 08/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class FixedSizeLabelCell: NSTextFieldCell {
  
  func font() -> NSFont {
    
    let systemFont = NSFont.systemFont(ofSize: 0)
    
    guard let fixedSizeLabel = self.controlView as? FixedSizeLabel else { return systemFont }
    let fixedSize = fixedSizeLabel.fixedSize
    let titleSize = self.stringValue.size(withAttributes: [.font: systemFont])
    
    return fixedSize.width >= titleSize.width + 6 ? systemFont :
      .systemFont(ofSize: CGFloat(NSControl.ControlSize.small.rawValue))
    
  }
  
  override func drawingRect(forBounds rect: NSRect) -> NSRect {
    
    var drawingRect = super.drawingRect(forBounds: rect)
    
    let size = super.cellSize(forBounds: rect)
    
    if drawingRect.size.height > size.height {
      
      drawingRect.origin.y = (drawingRect.size.height - size.height) / 2
      
    }
    
    return drawingRect
    
  }
  
}
