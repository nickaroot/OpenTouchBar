//
//  AppDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  @IBOutlet weak var window: NSWindow!
  @IBOutlet weak var touchBarController: TouchBarController!
  
  var standardDefaultAppsFolder: String!
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    
    guard let defaultsPath = Bundle.main.path(forResource: "Defaults", ofType: "plist") else { return }
    guard var defaults = NSDictionary(contentsOfFile: defaultsPath) as? [String: Any] else { return }

    guard let standardDefaultAppsFolder = defaults["defaultAppsFolder"] as? NSString else { return }
    
    self.standardDefaultAppsFolder = standardDefaultAppsFolder.expandingTildeInPath
    
    defaults[self.standardDefaultAppsFolder] = self.standardDefaultAppsFolder
    UserDefaults.standard.register(defaults: defaults)
    
    resetFromDock()
    
    guard touchBarController.present() else { fatalError() }
    
  }
  
  func resetFromDock() {
    
    try? FileManager.default.createDirectory(
      atPath: self.standardDefaultAppsFolder,
      withIntermediateDirectories: true,
      attributes: nil
    )
    
    var itemCount = 0
    
    guard let files = try? FileManager.default.contentsOfDirectory(atPath: self.standardDefaultAppsFolder)
      else { return }
    
    for file in files {
      
      guard !file.hasPrefix(".") else { continue }
      
      itemCount += 1
      
    }
    
    for file in files {
      
      guard !file.hasPrefix(".") else { continue }
      
      try? FileManager.default.removeItem(atPath: self.standardDefaultAppsFolder)
      
    }
    
    guard let defaultApps = UserDefaults.standard.object(forKey: "defaultApps") as? [[String: String]] else { return }
    
    let finderPath = URL(fileURLWithPath: defaultApps[0]["NSApplicationPath"]!).absoluteString
    let finderDict = ["tile-data": ["file-label": "Finder", "file-data": ["_CFURLString": finderPath]]]
    
    guard let dockDefaults = UserDefaults(suiteName: "com.apple.dock") else { return }
    
    let someApps = dockDefaults.object(forKey: "persistent-apps")
    
    guard let persistentApps = dockDefaults.object(forKey: "persistent-apps") as? [[String: Any]] else { return }
    guard let persistentOthers = dockDefaults.object(forKey: "persistent-others") as? [[String: Any]] else { return }
    
    let dockItems = [finderDict] + persistentApps + persistentOthers
    
    var order = 0
    
    for dockItem in dockItems {

      guard let item = dockItem["tile-data"] as? [String: Any] else { continue }

      guard var name = item["file-label"] as? String else { continue }
      guard let data = item["file-data"] as? [String: Any] else { continue }

      name = String(format: "%02u-%@", UInt(order), name)

      guard let urlString = data["_CFURLString"] as? String else { continue }
      guard let url = URL(string: urlString) else { continue }

      guard let urlData = try? url.bookmarkData(
        options: .suitableForBookmarkFile,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      ) else { continue }

      try? URL.writeBookmarkData(
        urlData,
        to: URL(fileURLWithPath: self.standardDefaultAppsFolder).appendingPathComponent(name)
      )

      order += 10

    }
    
    UserDefaults.standard.set(self.standardDefaultAppsFolder, forKey: "defaultAppsFolder")
    
//    [[self.touchBarController.touchBar itemForIdentifier:@"Dock"] reset]
    
  }
  
}
