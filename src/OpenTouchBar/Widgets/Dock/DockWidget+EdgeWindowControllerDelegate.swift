//
//  DockWidget+EdgeWindowControllerDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 03/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension DockWidget: EdgeWindowControllerDelegate {
  
  func edgeWindowController(_ controller: EdgeWindowController, mouseHoverAt point: NSPoint) {
    
    if prominentView != nil && prominentView!.isKind(of: DockWidgetButton.self) {
      
      (prominentView as! DockWidgetButton).prominent = false
      
    }
    
    _resetMagnify()
    
    guard !point.x.isNaN &&
      !self.folderController.presented &&
      UserDefaults.standard.bool(forKey: "acceptsDraggedItems")
    else { return }
    
    guard let view = self.view as? DockWidgetView else { return }
    guard let dragView = view.dragViewAtPoint(point: point) else { return }
    
    let position = (point.x - 210 - view.window!.convertToScreen(dragView.frame).origin.x) / 50 - 0.5
    
    if dragView.isKind(of: DockWidgetItemView.self) {
      
      guard let dragViewItemView = dragView as? DockWidgetItemView else { return }
      
      _magnify(at: dragViewItemView, position)
      
    } else if dragView.isKind(of: DockWidgetButton.self) {
      
      guard let dragViewButton = dragView as? DockWidgetButton else { return }
      
      dragViewButton.prominent = true
      self.prominentView = dragViewButton
      
    }
    
  }
  
  private func _magnify(at view: DockWidgetItemView, _ position: CGFloat) { // TODO: Test around scale
    
    self.prominentView = view
    
    let apps = self.apps
    
    guard let key = (itemViews as NSDictionary).allKeys(for: view).first as? String else { return }
    guard let hoverIndex = apps.firstIndex(where: { $0.key == key }) else { return }
    
    let x = CGFloat(hoverIndex) + position
    
    for (appIndex, app) in apps.enumerated() {
      
      let scale = 1 - 0.85 * abs(x - CGFloat(appIndex))
      
      if scale >= 0 {
      
        guard let itemView = itemViews[app.key] else { continue }
        
        itemView.scale = scale
        itemView.scaled = true
        
        itemView.prominent = appIndex == hoverIndex
        
      }
      
    }
    
  }
  
  private func _resetMagnify() {
    
    let apps = self.apps
    
    for app in apps {
      
      guard let itemView = itemViews[app.key] else { continue }
      
      itemView.scale = 0
      itemView.scaled = false
      
      itemView.prominent = false
      
    }
    
  }
  
  func edgeWindowController(_ controller: EdgeWindowController, mouseClickAt point: NSPoint) {
    
    if self.prominentView != nil { // TODO
      
      if self.prominentView!.isKind(of: DockWidgetItemView.self) {
        
        _resetMagnify()
        
      } else if self.prominentView!.isKind(of: DockWidgetButton.self) {
        
        guard let prominentViewButton = prominentView as? DockWidgetButton else { return }
        
        prominentViewButton.prominent = false
        
      }
      
    }
    
    guard !self.folderController.presented && UserDefaults.standard.bool(forKey: "acceptsDraggedItems") else { return }
    
    guard let view = self.view as? DockWidgetView else { return }
    guard let dragView = view.dragViewAtPoint(point: point) else { return }
    
    if dragView.isKind(of: DockWidgetItemView.self) {
      
      guard let dragViewItemView = dragView as? DockWidgetItemView else { return }
      
      let appPath = dragViewItemView.appPath
      
      NSWorkspace.shared.openFile(appPath, withApplication: nil, andDeactivate: true)
      
    } else if dragView.isKind(of: DockWidgetButton.self) {
      
      guard let dragViewButton = dragView as? DockWidgetButton else { return }
      
      let url = dragViewButton.url
      
      _ = url != nil ? NSWorkspace.shared.open(url!) : NSWorkspace.shared.openTrash()
      
    }
    
  }
  
  func edgeWindowController(_ controller: EdgeWindowController, dragURLs urls: [URL],
                            atPoint point: NSPoint, operation: NSDragOperation) -> NSDragOperation {
    
    var retOperation = NSDragOperation(rawValue: 0)
    
    guard let view = self.view as? DockWidgetView else { return retOperation }
    
    guard !self.folderController.presented && UserDefaults.standard.bool(forKey: "acceptsDraggedItems") else {
      
      view.dragTargetView.isHidden = true
      
      return retOperation
      
    }
    
    guard let dragView = view.dragViewAtPoint(point: point) else { return retOperation }
    
    if dragView.isKind(of: DockWidgetItemView.self) {
      
      retOperation = urls.count > 0 ? .generic : retOperation
      
    } else if dragView.isKind(of: DockWidgetButton.self) {
      
      guard let dragViewButton = dragView as? DockWidgetButton else { return retOperation }
      
      let url = dragViewButton.url
      
      if url != nil {
        
        guard let isDirVal = try? url!.resourceValues(forKeys: [.isDirectoryKey]).allValues.first
          else { return retOperation }
        guard let isDir = isDirVal?.value as? Bool else { return retOperation }
        
        guard let isAppVal = try? url!.resourceValues(forKeys: [.isApplicationKey]).allValues.first
          else { return retOperation }
        guard let isApp = isAppVal?.value as? Bool else { return retOperation }
        
        if isApp {
          
          retOperation = urls.count > 0 ? .generic : retOperation
          
        } else if isDir {
          
          retOperation = .copy
          
          if urls.count > 0 {
            
            switch operation {
              
            case .copy, .link:
              retOperation = operation
              
            case NSDragOperation(rawValue: (NSDragOperation.copy.rawValue | NSDragOperation.generic.rawValue)):
              retOperation = .link
              
            default:
              retOperation = .generic
              
            }
            
          }
          
        }
        
      } else { // Trash
        
        retOperation = urls.count > 0 ? .generic : retOperation
        
      }
      
    }
    
    view.dragTargetView.frame = view.convert(dragView.visibleRect, from: dragView)
    view.dragTargetView.isHidden = (retOperation == NSDragOperation(rawValue: 0))
    
    return retOperation
    
  }
  
  func edgeWindowController(_ controller: EdgeWindowController, dropURLs urls: [URL],
                            atPoint point: NSPoint, operation: NSDragOperation) -> [String: Any] {
    
    var retDict: [String: Any] = ["success": false, "url": URL(string: "")!]
    
    guard let view = self.view as? DockWidgetView else { return retDict }
    
    guard !self.folderController.presented && UserDefaults.standard.bool(forKey: "acceptsDraggedItems") else {
      
      view.dragTargetView.isHidden = true
      
      return retDict
      
    }
    
    guard let dragView = view.dragViewAtPoint(point: point) else { return retDict }
    
    if dragView.isKind(of: DockWidgetItemView.self) {
      
      guard let dragViewItemView = dragView as? DockWidgetItemView else { return retDict }
      
      let appPath = dragViewItemView.appPath
      
      let open = try? NSWorkspace.shared.open(
        urls,
        withApplicationAt: URL(fileURLWithPath: appPath),
        options: .async,
        configuration: [:]
      )
      
      retDict["success"] = (urls.count > 0 && open != nil)
      
    } else if dragView.isKind(of: DockWidgetButton.self) {
      
      guard let dragViewButton = dragView as? DockWidgetButton else { return retDict }
      
      let url = dragViewButton.url
      
      if url != nil {
        
        guard let isDirVal = try? url!.resourceValues(forKeys: [.isDirectoryKey]).allValues.first
          else { return retDict }
        guard let isDir = isDirVal?.value as? Bool else { return retDict }
        
        guard let isAppVal = try? url!.resourceValues(forKeys: [.isApplicationKey]).allValues.first
          else { return retDict }
        guard let isApp = isAppVal?.value as? Bool else { return retDict }
        
        if isApp {
          
          let open = try? NSWorkspace.shared.open(urls, withApplicationAt: url!, options: .async, configuration: [:])
          
          retDict["success"] = (urls.count > 0 && open != nil)
          
        } else if isDir {
          
          if urls.count > 0 {
            
            switch operation {
              
            case .copy:
              retDict["success"] = NSWorkspace.shared.copyItems(atURLs: urls, toURL: url!)
              
            case .link, NSDragOperation(rawValue: (NSDragOperation.copy.rawValue | NSDragOperation.generic.rawValue)):
              retDict["success"] = NSWorkspace.shared.aliasItems(atURLs: urls, toURL: url!)
              
            default:
              retDict["success"] = NSWorkspace.shared.moveItems(atURLs: urls, toURL: url!)
              
            }
            
          } else {
            
            retDict["success"] = true
            retDict["url"] = url!
            
          }
          
        }
        
      } else {
        
        retDict["success"] = (urls.count > 0 && NSWorkspace.shared.moveItemsToTrash(urls: urls))
        
      }
      
    }
    
    view.dragTargetView.isHidden = true
    
    return retDict
    
  }
  
}
