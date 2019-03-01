//
//  DockWidget.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 12/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class DockWidget: CustomWidget {
  
  static let dockItemSize = NSSize(width: 50, height: 30)
  static let dockDotHeight: CGFloat = 4
  static let dockItemBounce: CGFloat = 10
  static let maxPersistentItemCount: UInt = 8
  
  static func shadowWithOffset(shadowOffset: NSSize) -> NSShadow {
    
    let shadow = NSShadow()
    
    shadow.shadowBlurRadius = hypot(shadowOffset.width, shadowOffset.height)
    shadow.shadowOffset = NSSize(width: shadowOffset.width / 2, height: shadowOffset.height / 2)
    
    if #available(macOS 10.14, *) {
      
      shadow.shadowColor = .controlAccentColor
      
    } else {
      
      shadow.shadowColor = .systemBlue
      
    }
    
    return shadow
    
  }
  
  var defaultApps: DockWidgetApplications?
  var runningApps: DockWidgetApplications?
  
  var edgeWindowController: EdgeWindowController!
  var folderController: FolderController!
  
  var prominentView: NSView?
  var itemViews = [String: DockWidgetItemView]()
  
  override func commonInit() {
    
    itemViews = [String: DockWidgetItemView]()
    
    self.folderController = FolderController.controller()
    self.folderController.delegate = self
    
    self.customizationLabel = "Dock"
    
    let layout = NSScrubberFlowLayout()
    
    layout.itemSize = DockWidget.dockItemSize
    
    let scrubber = DockWidgetScrubber(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
    
    scrubber.translatesAutoresizingMaskIntoConstraints = false
    scrubber.dataSource = self
    scrubber.delegate = self
    scrubber.showsAdditionalContentIndicators = true
    scrubber.mode = .free
    scrubber.isContinuous = false
    scrubber.itemAlignment = .none
    scrubber.scrubberLayout = layout
    
    let leftItemView = NSStackView(views: [])
    
    leftItemView.userInterfaceLayoutDirection = .leftToRight
    leftItemView.orientation = .horizontal
    leftItemView.spacing = 0
    
    let rightItemView = NSStackView(views: [])
    
    rightItemView.userInterfaceLayoutDirection = .leftToRight
    rightItemView.orientation = .horizontal
    rightItemView.spacing = 0
    
    let dockSepImage = NSImage(named: "DockSep") ?? NSImage()
    let separator = NSImageView(image: dockSepImage)
    
    separator.translatesAutoresizingMaskIntoConstraints = false
    separator.tag = Int("sep ".fcc)
    
    let button = DockWidgetButton(with: self.trashImage, target: self, action: #selector(trashClick(_:)))
    
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isBordered = false
    button.tag = Int("trsh".fcc)
    button.resetImage()
    
    let view = DockWidgetView(views: [leftItemView, scrubber, separator, rightItemView, button])
    
    view.userInterfaceLayoutDirection = .leftToRight
    view.orientation = .horizontal
    view.spacing = 0
    
    self.setView(view)
    
  }
  
  override func viewWillAppear() {
    
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(resetRunningApps(_:)),
      name: NSWorkspace.willLaunchApplicationNotification, object: nil
    )
    
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(resetRunningApps(_:)),
      name: NSWorkspace.didLaunchApplicationNotification,
      object: nil
    )
    
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(resetRunningApps(_:)),
      name: NSWorkspace.didActivateApplicationNotification,
      object: nil
    )
    
    NSWorkspace.shared.notificationCenter.addObserver(
      self,
      selector: #selector(resetRunningApps(_:)),
      name: NSWorkspace.didTerminateApplicationNotification,
      object: nil
    )
    
    NSWorkspace.shared.addTrashObserver(self, selector: #selector(trashNotify(_:)))
    
    self.reset()
    
  }
  
  override func viewWillDisappear() {
    
    NSWorkspace.shared.removeTrashObserver(self)
    NSWorkspace.shared.notificationCenter.removeObserver(self)
    
    self.edgeWindowController = nil
    
  }
  
  var apps: DockWidgetApplications {
    
    var updateItemViews = false
    
    if self.defaultApps == nil {
      
      self.runningApps = nil
      
      var newDefaultApps = DockWidgetApplications()
      
      self.enumerateDefaultAppsFolder { (url, gravity) in
        
        guard gravity == .center else { return }
        
        let appName = url.lastPathComponent
        let appPath = url.path
        let appIcon = NSWorkspace.shared.icon(forFile: appPath)
        
        let app = DockWidgetApplication(default: appName, appPath, appIcon)
        
        newDefaultApps.append(app)
        
      }
      
      if newDefaultApps.count == 0 {
        
        let defaultApps = UserDefaults.standard.array(forKey: "defaultApps") as? [NSDictionary] ?? []
        
        for defaultApp in defaultApps {
          
          guard let appName = defaultApp["NSApplicationName"] as? String else { continue }
          guard let appPath = defaultApp["NSApplicationPath"] as? String else { continue }
          let appIcon = NSWorkspace.shared.icon(forFile: appPath)
          
          let app = DockWidgetApplication(default: appName, appPath, appIcon)
          
          newDefaultApps.append(app)
          
        }
        
      }
      
      self.defaultApps = newDefaultApps.map({ $0.copy() as! DockWidgetApplication })
      // swiftlint:disable:previous force_cast
      
      updateItemViews = true
      
    }
    
    if self.runningApps == nil {
      
      var defaultAppsDict = [String: DockWidgetApplication]()
      
      let defaultApps = self.defaultApps ?? []
      
      for app in defaultApps {
        
        app.pid = 0
        app.launching = false
        
        defaultAppsDict[app.path] = app
        
      }
      
      var newRunningApps = DockWidgetApplications()
      
      let runningApps = NSWorkspace.shared.runningApplications.filter { (app) -> Bool in
        
        return app.activationPolicy == .regular // Exclude all daemons, etc...
        
      }
      
      for runningApp in runningApps {
        
        guard let path = runningApp.bundleURL?.path else { continue }
        
        guard var app = defaultAppsDict[path] else { continue }
        
        if app.pid == 0 {
          
          guard let appIcon = runningApp.icon else { continue }
          let appPid = runningApp.processIdentifier
          let appLaunching = !runningApp.isFinishedLaunching
          
          app.icon = appIcon
          app.pid = appPid
          app.launching = appLaunching
          
          continue
          
        }
        
        guard let appName = runningApp.localizedName else { continue }
        guard let appPath = runningApp.bundleURL?.path else { continue }
        guard let appIcon = runningApp.icon else { continue }
        let appPid = runningApp.processIdentifier
        let appLaunching = !runningApp.isFinishedLaunching
        let appTerminated = runningApp.isTerminated
        
        app = DockWidgetApplication(with: appName, appPath, appIcon, false, appPid, appLaunching, appTerminated)
        
        newRunningApps.append(app)
        
      }
      
      self.runningApps = newRunningApps.map({ $0.copy() as! DockWidgetApplication })
      // swiftlint:disable:previous force_cast
      
      updateItemViews = true
      
    }
    
    let showsRunningApps = UserDefaults.standard.bool(forKey: "showsRunningApps")
    
    let defaultApps = self.defaultApps ?? []
    let runningApps = self.runningApps ?? []
    
    let apps = showsRunningApps ? (defaultApps + runningApps) : defaultApps
    
    if updateItemViews {
      
      let itemViews = self.itemViews
      
      for app in apps {
        
        let key = app.key
        guard let obj = itemViews[key] else { continue }
        
        self.itemViews[key] = obj
        
      }
      
      /* work around a problem in NSScrubber(?) */
      for (key, _) in itemViews where self.itemViews[key] == nil {
        
        guard let view = itemViews[key] else { continue }
        
        view.appPath = ""
        view.appIcon = NSImage()
        view.appRunning = false
        view.appLaunching = false
        view.prominent = false
        
      }
      
    }
    
    return apps
    
  }
  
  func enumerateDefaultAppsFolder(_ block: @escaping (_ url: URL, _ gravity: NSStackView.Gravity) -> Void) {
    
    guard let defaultAppsFolder = UserDefaults.standard.string(forKey: "defaultAppsFolder") else { return }
    
    guard var contents = try? FileManager.default.contentsOfDirectory(atPath: defaultAppsFolder) else { return }
    
    contents = contents.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
    
    for content in contents {
      
      if content.hasPrefix(".") { continue }
      
      guard let url = try? URL(
        resolvingAliasFileAt: URL(fileURLWithPath: defaultAppsFolder.appending(content)),
        options: [.withoutUI, .withoutMounting]
      ) else { continue }
      
      let gravity: NSStackView.Gravity!
      
      guard let isAppVal = try? url.resourceValues(forKeys: [URLResourceKey.isApplicationKey]).allValues.first
        else { continue }
      guard let isApp = isAppVal?.value as? Bool else { continue }
      
      if content.hasSuffix(".lpinned") {
        
        gravity = .leading
        
      } else if content.hasSuffix(".pinned") {
        
        gravity = .trailing
        
      } else if isApp {
        
        gravity = .center
        
      } else {
        
        gravity = .trailing
        
      }
      
      block(url, gravity)
      
    }
    
  }
  
  var trashImage: NSImage {
    
    guard let image = NSImage(named: NSWorkspace.shared.isTrashFull() ? "TrashFull" : "TrashEmpty")
      else { return NSImage() }
    
    return image
    
  }
  
  func makeImageWithSize(_ newSize: NSSize, drawImage oldImage: NSImage, inRect newRect: NSRect) -> NSImage {
    
    let oldSize = oldImage.size
    let oldRect = NSRect(origin: .zero, size: oldSize)
    let newImage = NSImage(size: newSize)
    
    newImage.lockFocus()
    
    NSGraphicsContext.current?.imageInterpolation = .high
    oldImage.draw(in: newRect, from: oldRect, operation: .sourceOver, fraction: 1)
    
    newImage.unlockFocus()
    
    return newImage
    
  }
  
}
