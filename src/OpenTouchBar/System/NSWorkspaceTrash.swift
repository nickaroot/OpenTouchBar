//
//  NSWorkspaceTrash.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 28/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa
import CoreServices

extension NSWorkspace {
  
  var trashPath: String {
    
    return "\(NSHomeDirectory())/.Trash"
    
  }
  
  func openTrash() -> Bool {
    
    let finder = NSAppleEventDescriptor(bundleIdentifier: "com.apple.finder")
    
    let event = NSAppleEventDescriptor(
      eventClass: kCoreEventClass,
      eventID: kAEOpenDocuments,
      targetDescriptor: finder,
      returnID: AEReturnID(kAutoGenerateReturnID),
      transactionID: AETransactionID(kAnyTransactionID)
    )
    
    var specifier = NSAppleEventDescriptor.record()
    
    specifier.setDescriptor(
      NSAppleEventDescriptor(typeCode: typeProperty),
      forKeyword: AEKeyword(keyAEDesiredClass)
    )
    
    specifier.setDescriptor(
      NSAppleEventDescriptor.null(),
      forKeyword: AEKeyword(keyAEContainer)
    )
    
    specifier.setDescriptor(
      NSAppleEventDescriptor(enumCode: OSType(formPropertyID)),
      forKeyword: AEKeyword(keyAEKeyForm)
    )
    
    specifier.setDescriptor(
      NSAppleEventDescriptor(typeCode: "trsh".fcc),
      forKeyword: AEKeyword(keyAEKeyData)
    )
    
    specifier = specifier.coerce(toDescriptorType: typeObjectSpecifier)!
    
    event.setParam(specifier, forKeyword: AEKeyword(keyDirectObject))
    
    guard (
      try? event.sendEvent(
        options: NSAppleEventDescriptor.SendOptions.noReply,
        timeout: TimeInterval(kAEDefaultTimeout)
      )
    ) != nil else { return false }
    
    self.launchApplication(
      withBundleIdentifier: "com.apple.finder",
      options: .default,
      additionalEventParamDescriptor: nil,
      launchIdentifier: nil
    )
    
    return true
    
  }
  
  func emptyTrash() -> Bool {
    
    let finder = NSAppleEventDescriptor(bundleIdentifier: "com.apple.finder")
    
    let event = NSAppleEventDescriptor(
      eventClass: "fndr".fcc,
      eventID: AEEventID(kAEEmptyTrash),
      targetDescriptor: finder,
      returnID: AEReturnID(kAutoGenerateReturnID),
      transactionID: AETransactionID(kAnyTransactionID)
    )
    
    guard (
      try? event.sendEvent(
        options: NSAppleEventDescriptor.SendOptions.noReply,
        timeout: TimeInterval(kAEDefaultTimeout)
      )
    ) != nil else { return false }
    
    return true
    
  }
  
  func moveItemsToTrash(urls: [URL]) -> Bool {
    
    return self.perform(
      anEventID: AEEventID(kAEDelete),
      forItemsAtURLs: urls,
      toURL: URL(string: "")!
    ) // TODO: check nil as URL parameter
    
  }
  
  func isTrashFull() -> Bool {
    
    guard let direnum = FileManager.default.enumerator(atPath: self.trashPath) else { return false }
    
    while let name = direnum.nextObject() as? String {
      
      if name != ".DS_Store" { return true }
      
    }
    
    return false
    
  }
  
  static var NSWorkspaceTrashFSNotify: @convention(c) (
    UnsafePointer<Int8>?,
    UnsafeMutableRawPointer?
  ) -> Void = { (path, data) in
    
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NSWorkspaceTrash"), object: nil)
    
  }
  
  func addTrashObserver(_ observer: Any, selector sel: Selector) {
    
    DispatchQueue.main.async {
      
      FSNotifyStart(self.trashPath.cString(using: .utf8), NSWorkspace.NSWorkspaceTrashFSNotify, nil)
      
    }
    
    NotificationCenter.default.addObserver(
      observer,
      selector: sel,
      name: NSNotification.Name(rawValue: "NSWorkspaceTrash"),
      object: nil
    )
    
  }
  
  func removeTrashObserver(_ observer: Any) {
    
    NotificationCenter.default.removeObserver(
      observer,
      name: NSNotification.Name(rawValue: "NSWorkspaceTrash"),
      object: nil
    )
    
  }
  
}
