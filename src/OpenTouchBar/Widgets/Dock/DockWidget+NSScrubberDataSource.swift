//
//  DockWidget+NSScrubberDataSource.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 03/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension DockWidget: NSScrubberDataSource {
  
  func numberOfItems(for scrubber: NSScrubber) -> Int {
    
    return self.apps.count
    
  }
  
  func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
    
    let app = self.apps[index]
    
    let view = itemViews[app.key] ?? DockWidgetItemView(frame: .zero)
    
    itemViews[app.key] = view
    
    let showsRunningApps = UserDefaults.standard.bool(forKey: "showsRunningApps")
    
    view.appPath = app.path
    view.appIcon = app.icon
    
    view.appRunning = showsRunningApps ? app.pid != 0 : false
    view.appLaunching = showsRunningApps ? app.launching : false
    
    return view
    
  }
  
}
