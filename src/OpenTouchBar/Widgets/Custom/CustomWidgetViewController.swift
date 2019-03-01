//
//  CustomWidgetViewController.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class CustomWidgetViewController: NSViewController {
  
  var widget: CustomWidget!
  
  override func viewWillAppear() {
    
    widget.viewWillAppear()
    
  }
  
  override func viewDidAppear() {
    
    widget.viewDidAppear()
    
  }
  
  override func viewWillDisappear() {
    
    widget.viewWillDisappear()
    
  }
  
  override func viewDidDisappear() {
    
    widget.viewDidDisappear()
    
  }
  
}
