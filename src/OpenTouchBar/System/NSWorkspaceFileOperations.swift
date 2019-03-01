//
//  NSWorkspaceFileOperations.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 27/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension NSWorkspace {
  
  func perform(anEventID eventID: AEEventID, forItemsAtURLs urls: [URL], toURL url: URL) -> Bool {
    
    let finder = NSAppleEventDescriptor(bundleIdentifier: "com.apple.finder")
    
    let event = NSAppleEventDescriptor(
      eventClass: kAECoreSuite,
      eventID: eventID,
      targetDescriptor: finder,
      returnID: AEReturnID(kAutoGenerateReturnID),
      transactionID: AETransactionID(kAnyTransactionID)
    )
    
    let list = NSAppleEventDescriptor(listDescriptor: ())
    
    for url in urls {
      
      guard let urldesc = NSAppleEventDescriptor(
        descriptorType: typeFileURL,
        data: url.absoluteString.data(using: .utf8)
      ) else { continue }
      
      list.insert(urldesc, at: 0)
      
    }
    
    event.setParam(list, forKeyword: keyDirectObject)
    
    guard let urldesc = NSAppleEventDescriptor(
      descriptorType: typeFileURL,
      data: url.absoluteString.data(using: .utf8)
    ) else { return false }
    
    event.setParam(urldesc, forKeyword: keyAEInsertHere)
    
    guard (try? event.sendEvent(
      options: NSAppleEventDescriptor.SendOptions.noReply,
      timeout: TimeInterval(kAEDefaultTimeout)
    )) != nil else { return false }
    
    return true
    
  }
  
  func copyItems(atURLs urls: [URL], toURL url: URL ) -> Bool {
    
    return self.perform(anEventID: kAEClone, forItemsAtURLs: urls, toURL: url)
    
  }
  
  func moveItems(atURLs urls: [URL], toURL url: URL ) -> Bool {
    
    return self.perform(anEventID: kAEMove, forItemsAtURLs: urls, toURL: url)
    
  }
  
  func aliasItems(atURLs urls: [URL], toURL url: URL ) -> Bool {
    
    let finder = NSAppleEventDescriptor(bundleIdentifier: "com.apple.finder")
    
    let event = NSAppleEventDescriptor(
      eventClass: kAECoreSuite,
      eventID: kAECreateElement,
      targetDescriptor: finder,
      returnID: AEReturnID(kAutoGenerateReturnID),
      transactionID: AETransactionID(kAnyTransactionID)
    )
    
    let cls = NSAppleEventDescriptor(typeCode: "alia".fcc)
    
    event.setParam(cls, forKeyword: keyAEObjectClass)
    
    let list = NSAppleEventDescriptor(listDescriptor: ())
    
    for url in urls {
      
      guard let urldesc = NSAppleEventDescriptor(
        descriptorType: typeFileURL,
        data: url.absoluteString.data(using: .utf8)
      ) else { continue }
      
      list.insert(urldesc, at: 0)
      
    }
    
    event.setParam(list, forKeyword: "to  ".fcc)
    
    guard let urldesc = NSAppleEventDescriptor(
      descriptorType: typeFileURL,
      data: url.absoluteString.data(using: .utf8)
    ) else { return false }
    
    event.setParam(urldesc, forKeyword: keyAEInsertHere)
    
    guard (try? event.sendEvent(
      options: .noReply,
      timeout: TimeInterval(kAEDefaultTimeout)
    )) != nil else { return false }
    
    return true
    
  }
  
}
