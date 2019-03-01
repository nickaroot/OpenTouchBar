//
//  EdgeWindowControllerDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 27/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

@objc
protocol EdgeWindowControllerDelegate {
  
  @objc
  optional func edgeWindowController(_ controller: EdgeWindowController, mouseHoverAt point: NSPoint)
  
  func edgeWindowController(_ controller: EdgeWindowController, mouseClickAt point: NSPoint)
  
  func edgeWindowController(_ controller: EdgeWindowController, dragURLs urls: [URL],
                            atPoint point: NSPoint, operation: NSDragOperation) -> NSDragOperation
  
  func edgeWindowController(_ controller: EdgeWindowController, dropURLs urls: [URL],
                            atPoint point: NSPoint, operation: NSDragOperation) -> [String: Any]
  
}
