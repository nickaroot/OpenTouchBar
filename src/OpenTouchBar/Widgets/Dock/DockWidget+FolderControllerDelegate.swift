//
//  DockWidget+FolderControllerDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 03/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension DockWidget: FolderControllerDelegate {
  
  func folderController(_ controller: FolderController, didSelectURL url: URL) {
    
    if !url.path.hasPrefix(NSWorkspace.shared.trashPath) {
      
      NSWorkspace.shared.open(url)
      
      controller.dismiss()
      
    }
    
  }
  
  func folderController(_ controller: FolderController, didClick identifier: String) {
    
    if identifier == "openButton" {
      
      guard let url = controller.url else { return }
      
      if !url.path.hasPrefix(NSWorkspace.shared.trashPath) {
        
        NSWorkspace.shared.open(url)
        
      } else {
        
        _ = NSWorkspace.shared.openTrash()
        
      }
      
    } else if identifier == "emptuButton" {
      
      _ = NSWorkspace.shared.emptyTrash()
      
      controller.dismiss()
      
    }
    
  }
  
}
