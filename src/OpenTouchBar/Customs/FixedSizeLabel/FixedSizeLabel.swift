//
//  FixedSizeLabel.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 08/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class FixedSizeLabel: NSTextField {
  
  var fixedSize = NSSize.zero
  
  override init(frame frameRect: NSRect) {
    
    super.init(frame: frameRect)
    
    self.fixedSize = NSSize(width: 150, height: NSView.noIntrinsicMetric)
    
  }
  
  required init?(coder: NSCoder) {
    
    super.init(coder: coder)
    
    self.fixedSize = NSSize(width: 150, height: NSView.noIntrinsicMetric)
    
  }
  
  override open var intrinsicContentSize: NSSize {
    
    return self.fixedSize
    
  }
  
  override open class var cellClass: AnyClass? {
    
    get { return FixedSizeLabelCell.self }
    
    set { }
    
  }
  
}
