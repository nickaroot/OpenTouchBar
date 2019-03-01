//
//  DockWidget+Handlers.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 04/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension DockWidget {
  
  @objc
  func persistentItemClick(_ sender: DockWidgetButton?) {
    
    guard let url = sender?.url else { return }
    
    guard let isDirVal = try? url.resourceValues(forKeys: [.isDirectoryKey]).allValues.first else { return }
    guard let isDir = isDirVal?.value as? Bool else { return }
    
    guard let isPkgVal = try? url.resourceValues(forKeys: [.isPackageKey]).allValues.first else { return }
    guard let isPkg = isPkgVal?.value as? Bool else { return }
    
    guard let isAppVal = try? url.resourceValues(forKeys: [.isApplicationKey]).allValues.first else { return }
    guard let isApp = isAppVal?.value as? Bool else { return }
    
    let open = !(UserDefaults.standard.bool(forKey: "showsFoldersInTouchBar"))
    
    if !isDir || isPkg || isApp || open {
      
      NSWorkspace.shared.open(url)
      
    } else {
      
      let isApplications = (url.path == "/Applications")
      let isDownloads = (url.path == "\(NSHomeDirectory())/Downloads")
      
      self.folderController.url = url
      self.folderController.includeDescendants = false // isApplications
      self.folderController.sortKey = isDownloads ? URLResourceKey.addedToDirectoryDateKey : nil
      self.folderController.imagePosition = isApplications ? .imageOnly : .imageLeft
      self.folderController.showsEmptyButton = false
      
      _ = self.folderController.present()
      
    }
    
  }
  
  @objc
  func trashNotify(_ notification: NSNotification) {
    
    guard let button = self.view.viewWithTag(Int("trsh".fcc)) as? DockWidgetButton else { return }
    
    button.regularImage = self.trashImage
    
    button.resetImage()
    
  }
  
  @objc
  func trashClick(_ sender: AnyObject?) {
    
    let open = !(UserDefaults.standard.bool(forKey: "showsFoldersInTouchBar"))
    
    if open {
      
      _ = NSWorkspace.shared.openTrash()
      
    } else {
      
      self.folderController.url = URL(fileURLWithPath: NSWorkspace.shared.trashPath)
      self.folderController.includeDescendants = false
      self.folderController.sortKey = nil
      self.folderController.imagePosition = NSControl.ImagePosition.imageLeft
      self.folderController.showsEmptyButton = true
      self.folderController.emptyButtonEnabled = NSWorkspace.shared.isTrashFull()
      
      _ = self.folderController.present()
      
    }
    
  }
  
}
