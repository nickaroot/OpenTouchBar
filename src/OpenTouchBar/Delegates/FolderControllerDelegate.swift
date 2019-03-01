//
//  FolderControllerDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 13/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

@objc
protocol FolderControllerDelegate {
  
  @objc
  optional func folderController(_ controller: FolderController, didSelectURL url: URL)
  
  func folderController(_ controller: FolderController, didClick identifier: String)
  
}
