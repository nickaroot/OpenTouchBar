//
//  FolderController.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 13/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import QuickLook

class FolderController: TouchBarController {
  
  static let smallItemSize = NSSize(width: 50, height: 30)
  static let largeItemSize = NSSize(width: 150, height: 30)
  static let maxFileCount = 100
  
  @IBOutlet var scrubber: NSScrubber!
  @IBOutlet var label: NSTextField!
  @IBOutlet var emptyButton: NSButton!
  @IBOutlet var openButton: NSButton!
  
  internal var contents: [FolderItem] = []
  internal var tooManyItems = false
  
  var url: URL?
  var includeDescendants = false
  var sortKey: URLResourceKey?
  var imagePosition: NSControl.ImagePosition?
  var showsEmptyButton = false
  var emptyButtonEnabled = false
  
  weak var delegate: FolderControllerDelegate!
  
  static func controller() -> FolderController? {
    
    let controller = self.init()
    var objects: NSArray?
    
    guard Bundle.main.loadNibNamed("FolderBar", owner: controller, topLevelObjects: &objects) else { return nil }
    
    return controller
    
  }
  
  override func awakeFromNib() {
    
    self.scrubber.register(FolderItemView.self, forItemIdentifier: NSUserInterfaceItemIdentifier("item"))
    
  }
  
  override func present(placement: Int) -> Bool { // TODO: Clean up ObjC-translated mess
    
    guard let enumeratorUrl = self.url else { return false }
    let enumeratorProperties: [URLResourceKey]? = self.sortKey != nil ?
      [.isDirectoryKey, .isApplicationKey, self.sortKey!] : nil
    
    let enumeratorOptions: FileManager.DirectoryEnumerationOptions = [self.includeDescendants ?
      .init(rawValue: 0) : .skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles]
    
    let enumerator = FileManager.default.enumerator(
      at: enumeratorUrl,
      includingPropertiesForKeys: enumeratorProperties,
      options: enumeratorOptions, errorHandler: nil
    )
    
    var urls = [URL]()
    var tooManyItems = false
    
    while let url = enumerator?.nextObject() as? URL {
      
      guard urls.count < FolderController.maxFileCount else {
        
        tooManyItems = true
        
        break
        
      }
      
      urls.append(url)
      
    }
    
    urls = self.sort(urls)
    
    self.contents = self.folderItems(from: urls)
    self.tooManyItems = tooManyItems
    
    guard let scrubberLayout = self.scrubber.scrubberLayout as? NSScrubberFlowLayout else { return false }
    
    scrubberLayout.itemSize = NSControl.ImagePosition.imageOnly != self.imagePosition ? FolderController.largeItemSize :
      FolderController.smallItemSize
    
    self.scrubber.reloadData()
    
    self.label.stringValue = "\(self.contents.count)" + "\(self.tooManyItems ? "+" : "") file" +
      "\(self.contents.count != 1 ? "s" : "")"
    
    var itemIdentifiers = self.appTouchBar.defaultItemIdentifiers
    
    itemIdentifiers.removeAll(where: { (identifier) -> Bool in return identifier.rawValue == "emptyButton"})
    
    if self.showsEmptyButton {
      
      guard let index = itemIdentifiers.index(of: NSTouchBarItem.Identifier(rawValue: "openButton"))
        else { return false }
      
      if index != NSNotFound {
        
        itemIdentifiers.insert(NSTouchBarItem.Identifier("emptyButton"), at: index)
        self.emptyButton.isEnabled = self.emptyButtonEnabled
        
      }
      
      self.appTouchBar.defaultItemIdentifiers = itemIdentifiers
      
      //            self.performSelector(inBackground: #selector(prepareIconsInBackground), with: urls)
      
      DispatchQueue.global(qos: .background).async {
        
        self.prepareIconsInBackground(urls: urls) // TODO: check if it need a copy
        
      }
      
      return super.present(placement: placement)
      
    }
    
    return false
    
  }
  
  func sort(_ urls: [URL]) -> [URL] {
    
    var urls = urls
    
    urls.sort { (url1, url2) -> Bool in // TODO: Bullsh......
      
      guard let sortKey = self.sortKey else { return false }
      
      guard let dateVal1 = try? url1.resourceValues(forKeys: [sortKey]).allValues.first else { return false }
      guard let date1 = dateVal1?.value as? Date else { return false }
      
      guard let dateVal2 = try? url2.resourceValues(forKeys: [sortKey]).allValues.first else { return false }
      guard let date2 = dateVal2?.value as? Date else { return false }
      
      return date2.compare(date1).rawValue != 0
      
    }
    
    return urls
    
  }
  
  func folderItems(from urls: [URL]) -> [FolderItem] {
    
    var folderItems = [FolderItem]()
    
    let appIcon = NSWorkspace.shared.icon(forFileType: ".app")
    let dirIcon = NSWorkspace.shared.icon(forFileType: "public.folder")
    let docIcon = NSWorkspace.shared.icon(forFileType: "public.content")
    
    for url in urls {
      
      guard let isDirVal = try? url.resourceValues(forKeys: [.isDirectoryKey]).allValues.first else { continue }
      guard let isDir = isDirVal?.value as? Bool else { continue }
      
      guard let isAppVal = try? url.resourceValues(forKeys: [.isApplicationKey]).allValues.first else { continue }
      guard let isApp = isAppVal?.value as? Bool else { continue }
      
      let item = FolderItem()
      
      item.url = url
      item.icon = isApp ? appIcon : (isDir ? dirIcon : docIcon)
      
      folderItems.append(item)
      
    }
    
    return folderItems
    
  }
  
  @objc
  func prepareIconsInBackground(urls: [URL]) {
    
    var icons = [URL: NSImage]()
    
    let size = NSSize(width: 60, height: 60)
    let options = [QuickLook.kQLThumbnailOptionIconModeKey: NSNumber(value: true)] as CFDictionary
    
    for url in urls {
      
      let icon: NSImage?
      let cfUrl = url as CFURL
      
      if let cgImage = QLThumbnailImageCreate(kCFAllocatorDefault, cfUrl, size, options) {
        
        icon = NSImage(cgImage: cgImage.takeUnretainedValue(), size: .zero)
        
      } else {
        
        icon = NSWorkspace.shared.icon(forFile: url.path)
        
      }
      
      if icon != nil {
        
        icons[url] = icon
        
      }
      
      if icons.count > 0 && icons.count % 4 == 0 {
        
        //                self.perform(#selector(updateIcons(icons:)), on: .main, with: icons, waitUntilDone: false)
        
        DispatchQueue.main.async {
          
          self.updateIcons(icons: icons)
          
        }
        
        icons.removeAll()
        
      }
      
    }
    
    if icons.count > 0 {
      
      //            self.perform(#selector(updateIcons(icons:)), on: .main, with: icons, waitUntilDone: false)
      
      DispatchQueue.main.async {
        
        self.updateIcons(icons: icons)
        
      }
      
    }
    
  }
  
  @objc
  func updateIcons(icons: [URL: NSImage]) {
    
    self.scrubber.performSequentialBatchUpdates {
      
      let contents = self.contents
      
      for url in icons {
        
        var index = 0
        
        for item in contents {
          
          if item.url == url.key {
            
            item.icon = url.value
            
            self.scrubber.reloadItems(at: [index])
            
            break
            
          }
          
          index += 1
          
        }
        
      }
      
    }
    
  }
  
  @IBAction func emptyButtonAction(_ sender: Any) {
    
    self.delegate.folderController(self, didClick: "emptyButton")
    
  }
  
  @IBAction func openButtonAction(_ sender: Any) {
    
    self.delegate.folderController(self, didClick: "openButton")
    
  }
  
}
