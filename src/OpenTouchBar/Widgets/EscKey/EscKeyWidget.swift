//
//  EscKeyWidget.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class EscKeyWidget: CustomWidget {
  
  override func commonInit() {
    
    self.customizationLabel = "Esc Key"
    
    let button = EscKeyWidgetButton(title: "esc", target: self, action: #selector(click(_:)))
    
    self.setView(button)
    
  }
  
  @objc
  func click(_ sender: AnyObject) {
    
    System.postKeyPress(0x35, nil)
    
  }
  
}
