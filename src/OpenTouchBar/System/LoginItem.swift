//
//  LoginItem.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 31/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

extension System {
  
  fileprivate static func loginItem(at path: String) -> LSSharedFileListItem? {
    
    guard !path.isEmpty else { return nil }
    
    guard let sharedFileList = LSSharedFileListCreate(
      nil,
      kLSSharedFileListSessionLoginItems.takeRetainedValue(),
      nil
    ) else { return nil }
    
    let loginItemList = sharedFileList.takeRetainedValue()
    let url = URL(fileURLWithPath: path)
    let loginItemsListSnapshot: NSArray = LSSharedFileListCopySnapshot(loginItemList, nil).takeRetainedValue()
    
    guard let loginItems = loginItemsListSnapshot as? [LSSharedFileListItem] else { return nil }
    
    for loginItem in loginItems {
      
      guard let resolvedUrl = LSSharedFileListItemCopyResolvedURL(loginItem, 0, nil) else { continue }
      let itemUrl = resolvedUrl.takeRetainedValue() as URL
      
      guard url.absoluteString == itemUrl.absoluteString else { continue }
      
      return loginItem
      
    }
    return nil
  }
  
  public static func isExistLoginItems(at path: String = Bundle.main.bundlePath) -> Bool {
    
    return (loginItem(at: path) != nil)
    
  }
  
  @discardableResult
  public static func addLoginItems(at path: String = Bundle.main.bundlePath) -> Bool {
    
    guard !isExistLoginItems(at: path) else { return false }
    
    guard let sharedFileList = LSSharedFileListCreate(
      nil,
      kLSSharedFileListSessionLoginItems.takeRetainedValue(),
      nil
    ) else { return false }
    let loginItemList = sharedFileList.takeRetainedValue()
    let url = URL(fileURLWithPath: path)
    
    LSSharedFileListInsertItemURL(
      loginItemList,
      kLSSharedFileListItemBeforeFirst.takeRetainedValue(),
      nil,
      nil,
      url as CFURL,
      nil,
      nil
    )
    
    return true
    
  }
  
  @discardableResult
  public static func removeLoginItems(at path: String = Bundle.main.bundlePath) -> Bool {
    
    guard isExistLoginItems(at: path) else { return false }
    
    guard let sharedFileList = LSSharedFileListCreate(
      nil,
      kLSSharedFileListSessionLoginItems.takeRetainedValue(),
      nil
    ) else { return false }
    
    let loginItemList = sharedFileList.takeRetainedValue()
    let url = URL(fileURLWithPath: path)
    let loginItemsListSnapshot: NSArray = LSSharedFileListCopySnapshot(loginItemList, nil).takeRetainedValue()
    
    guard let loginItems = loginItemsListSnapshot as? [LSSharedFileListItem] else { return false }
    
    for loginItem in loginItems {
      
      guard let resolvedUrl = LSSharedFileListItemCopyResolvedURL(loginItem, 0, nil) else { continue }
      let itemUrl = resolvedUrl.takeRetainedValue() as URL
      
      guard url.absoluteString == itemUrl.absoluteString else { continue }
      
      LSSharedFileListItemRemove(loginItemList, loginItem)
    }
    
    return true
    
  }
  
}
