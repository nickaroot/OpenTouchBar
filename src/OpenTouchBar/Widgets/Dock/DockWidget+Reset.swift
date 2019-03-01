//
//  DockWidget+Reset.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 04/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension DockWidget {
  
  func reset() {
    
    self.resetDrag()
    self.resetPersistentItems()
    self.resetDefaultApps()
    
  }
  
  func resetDrag() {
    
    if UserDefaults.standard.bool(forKey: "acceptsDraggedItems") {
      
      self.edgeWindowController = EdgeWindowController()
      self.edgeWindowController?.delegate = self
      
    } else {
      
      self.edgeWindowController = nil
      
    }
    
  }
  
  func resetDefaultApps() {
    
    guard let scrubber = self.view.viewWithTag(Int("dock".fcc)) as? DockWidgetScrubber else { return }
    
    self.defaultApps = nil
    
    scrubber.reloadData()
    
  }
  
  func resetPersistentItems() {
    
    var leftViews = [NSView]()
    var rightViews = [NSView]()
    
    self.enumerateDefaultAppsFolder { (url, gravity) in
      
      switch gravity {
        
      case .leading:
        if DockWidget.maxPersistentItemCount < leftViews.count { return }
        
      case .trailing:
        if DockWidget.maxPersistentItemCount < rightViews.count { return }
        
      default:
        return
        
      }
      
      let iconSize = NSSize(width: DockWidget.dockItemSize.height, height: DockWidget.dockItemSize.height)
      
      let iconRect = NSRect(
        x: DockWidget.dockDotHeight / 2,
        y: DockWidget.dockDotHeight,
        width: iconSize.height - DockWidget.dockDotHeight,
        height: iconSize.height - DockWidget.dockDotHeight
      )
      
      let image = self.makeImageWithSize(
        iconSize,
        drawImage: NSWorkspace.shared.icon(forFile: url.path),
        inRect: iconRect
      )
      
      let button = DockWidgetButton(with: image, target: self, action: #selector(self.persistentItemClick(_:)))
      
      button.translatesAutoresizingMaskIntoConstraints = false
      button.isBordered = false
      button.url = url
      button.resetImage()
      
      switch gravity {
        
      case .leading:
        leftViews.append(button)
        
      case .trailing:
        rightViews.append(button)
        
      default:
        break
        
      }
      
    }
    
    let showsTrash = UserDefaults.standard.bool(forKey: "showsTrash")
    
    self.view.viewWithTag(Int("sep ".fcc))?.isHidden = !(showsTrash || 0 < rightViews.count)
    self.view.viewWithTag(Int("trsh".fcc))?.isHidden = !showsTrash
    
    guard let view = self.view as? DockWidgetView else { return }
    
    guard let leftItemView = view.views[0] as? NSStackView else { return }
    guard let rightItemView = view.views[3] as? NSStackView else { return }
    
    leftItemView.setViews(leftViews, in: .trailing)
    rightItemView.setViews(rightViews, in: .trailing)
    
  }
  
  @objc
  func resetRunningApps(_ notification: NSNotification) {
    
    guard let scrubber = self.view.viewWithTag(Int("dock".fcc)) as? NSScrubber else { return }
    
    scrubber.performSequentialBatchUpdates {
      
      var oldApps = self.apps.map({ $0.copy() as! DockWidgetApplication }) // swiftlint:disable:this force_cast
      var oldPaths = _appsPaths(from: oldApps)
      
      self.runningApps = nil
      
      let newApps = self.apps
      var newPaths = _appsPaths(from: newApps)
      
      (oldApps, oldPaths, newPaths) = _resetTerminatingDefaultApps(oldApps, oldPaths, newPaths)
      
      var scrubberCount = scrubber.numberOfItems
      
      scrubberCount -= _removeTerminatedApps(oldApps, newPaths, in: scrubber)
      scrubberCount += _insertLaunchedApps(newApps, oldPaths, in: scrubber, with: scrubberCount)
      
      _reloadScrubberApps(oldApps, newPaths, in: scrubber)
      
    }
    
  }
  
  private func _appsPaths(from apps: DockWidgetApplications) -> DockWidgetApplicationPaths {
    
    var appsPaths: DockWidgetApplicationPaths = [:]
    
    for app in apps {
      
      appsPaths[app.path] = appsPaths[app.path] != nil ? appsPaths[app.path]! + [app] : [app]
      
    }
    
    return appsPaths
    
  }
  
  private func _resetTerminatingDefaultApps(
    _ apps: DockWidgetApplications,
    _ oldPaths: DockWidgetApplicationPaths,
    _ newPaths: DockWidgetApplicationPaths
    ) -> (DockWidgetApplications, DockWidgetApplicationPaths, DockWidgetApplicationPaths) {
    // swiftlint:disable:previous large_tuple
    var oldPaths = oldPaths
    var newPaths = newPaths
    
    for app in apps where app.isDefault {
      
      guard let newApps = newPaths[app.path] else { continue }
      guard let newApp = newApps.first else { continue }
      guard let oldApps = oldPaths[app.path] else { continue }
      
      for oldApp in oldApps where newApp.pid == oldApp.pid {
        
        let pid = app.pid
        
        app.pid = oldApp.pid
        oldApp.pid = pid
        
        let launching = app.launching
        
        app.launching = oldApp.launching
        oldApp.launching = launching
        
        break
        
      }
      
      newPaths[app.path] = newApps
      oldPaths[app.path] = oldApps
      
    }
    
    return (apps, oldPaths, newPaths)
    
  }
  
  private func _removeTerminatedApps(
    _ apps: DockWidgetApplications,
    _ newPaths: DockWidgetApplicationPaths,
    in scrubber: NSScrubber
    ) -> Int {
    
    var count = 0
    
    for (appIndex, app) in apps.reversed().enumerated() {
      
      let appIndex = apps.count - appIndex - 1
      
      guard let newApps = newPaths[app.path] else { continue }
      
      if newApps.first(where: { app.pid == 0 || $0.pid == 0 || app.pid == $0.pid }) == nil {
        
        scrubber.removeItems(at: [appIndex])
        
        count -= 1
        
      }
      
    }
    
    return count
    
  }
  
  private func _insertLaunchedApps(
    _ apps: DockWidgetApplications,
    _ oldPaths: DockWidgetApplicationPaths,
    in scrubber: NSScrubber,
    with count: Int
    ) -> Int {
    
    var scrubberCount = count
    
    for app in apps {
      
      guard let oldApps = oldPaths[app.path] else { continue }
      
      if oldApps.first(where: { app.pid == 0 || $0.pid == 0 || $0.pid == app.pid }) == nil {
        
        scrubber.insertItems(at: [scrubberCount])
        
        scrubberCount += 1
        
      }
      
    }
    
    return scrubberCount
    
  }
  
  private func _reloadScrubberApps(
    _ apps: DockWidgetApplications,
    _ newPaths: DockWidgetApplicationPaths,
    in scrubber: NSScrubber
    ) {
    
    for (appIndex, app) in apps.enumerated() {
      
      guard let newApps = newPaths[app.path] else { continue }
      
      if newApps.first(where: { app.pid == $0.pid }) == nil {
        
        guard let newApp = newApps.first else { continue }
        
        let view = itemViews[app.key] ?? itemViews[newApp.key]
        
        guard view != nil else {
          
          scrubber.reloadItems(at: [appIndex])
          
          continue
          
        }
        
        itemViews.removeValue(forKey: app.key)
        
        itemViews[newApp.key] = view
        
        let showsRunningApps = UserDefaults.standard.bool(forKey: "showsRunningApps")
        
        view!.appRunning = showsRunningApps ? newApp.pid != 0 : false
        view!.appLaunching = showsRunningApps ? newApp.launching : false
        
      }
      
    }
    
  }
  
}
