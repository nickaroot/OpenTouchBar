//
//  DockWidgetScrubber.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 13/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class DockWidgetScrubber: NSScrubber {
  
  override var tag: Int {
    
    return Int("dock".fcc)
    
  }
  
}
