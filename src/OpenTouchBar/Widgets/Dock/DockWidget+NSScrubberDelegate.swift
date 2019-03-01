//
//  DockWidget+NSScrubberDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 03/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension DockWidget: NSScrubberDelegate {
  
  func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
    
    let app = self.apps[selectedIndex]
    
    NSWorkspace.shared.openFile(app.path, withApplication: nil, andDeactivate: true)
    
    scrubber.selectedIndex = -1
    
  }
  
}
