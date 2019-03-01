//
//  EdgeWindowController.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 25/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa
// TODO: responds(to: Selector?) (in all classes)
class EdgeWindowController: NSWindowController, NSWindowDelegate, NSDraggingDestination {
  
  static let ScreenWidthInTouchBarUnits: CGFloat = 1400 // TODO: Check on 13", maybe 1252
  
  static let TouchBarWidthInTouchBarUnits: CGFloat = 1085
  
  private var _trackTag: NSView.TrackingRectTag?
  private var _trackTimer: Timer?
  private var _trackSentHover: Bool?
  
  weak var delegate: EdgeWindowControllerDelegate!
  
  var screenEdgeRect: NSRect {
    
    let frame = NSScreen.screens[0].frame
    
    let rect = NSRect(origin: .zero, size: CGSize(width: frame.size.width, height: 1))
    
    return rect
    
  }
  
  required init?(coder: NSCoder) {
    
    super.init(coder: coder)
    
  }
  
  init() {
    
    let window = NSWindow(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
    
    window.alphaValue = 0
    window.animationBehavior = .none
    window.canHide = false
    window.collectionBehavior = NSWindow.CollectionBehavior(rawValue:
      NSWindow.CollectionBehavior.canJoinAllSpaces.rawValue |
      NSWindow.CollectionBehavior.stationary.rawValue |
      NSWindow.CollectionBehavior.ignoresCycle.rawValue |
      NSWindow.CollectionBehavior.fullScreenAuxiliary.rawValue
    )
    
    window.hasShadow = false
    window.hidesOnDeactivate = false
    window.ignoresMouseEvents = false
    window.level = .mainMenu
    window.isOpaque = false
    window.isReleasedWhenClosed = true
    window.registerForDraggedTypes([.URL, .filePromise])
    
    super.init(window: window)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenChanged(_:)),
      name: NSApplication.didChangeScreenParametersNotification,
      object: nil
    )
    
    self.window?.delegate = self
    self.window?.orderFrontRegardless()
    
    self.snapToScreenEdge()
    
  }
  
  func snapToScreenEdge() {
    
    guard let windowContentView = self.window?.contentView else { return }
    
    if _trackTag != nil {
      
      windowContentView.removeTrackingRect(_trackTag!)
      
    }
    
    self.window?.setFrame(self.screenEdgeRect, display: true, animate: false)
    
    self._trackTag = windowContentView.addTrackingRect(
      windowContentView.bounds,
      owner: self,
      userData: nil,
      assumeInside: false
    )
    
  }
  
  func convertBaseToTouchBar(point oldPoint: NSPoint) -> NSPoint {
    
    let screenWidth = NSScreen.screens[0].frame.width
    guard let screenX = self.window?.convertToScreen(NSRect(origin: oldPoint, size: .zero)).origin.x
      else { return oldPoint }
    
    let screenRatio = EdgeWindowController.ScreenWidthInTouchBarUnits / screenWidth
    
    let touchBarPointX = screenX * screenRatio -
      (EdgeWindowController.ScreenWidthInTouchBarUnits - EdgeWindowController.TouchBarWidthInTouchBarUnits) / 2
    
    let touchBarPoint = NSPoint(x: touchBarPointX, y: 15)
    
    return touchBarPoint
    
  }
  
  @objc
  func screenChanged(_ notification: NSNotification) {
    
    self.snapToScreenEdge()
    
  }
  
  override func mouseEntered(with event: NSEvent) {
    
    _trackTimer = Timer.scheduledTimer(
      timeInterval: 0.05,
      target: self,
      selector: #selector(mouseUpdated(_:)),
      userInfo: nil,
      repeats: true
    )
    
  }
  
  @objc
  func mouseUpdated(_ timer: Timer) {
    
    guard self._trackTimer != nil else { return }
    
    guard let mouseLocation = self.window?.mouseLocationOutsideOfEventStream else { return }
    
    let point = self.convertBaseToTouchBar(point: mouseLocation)
    
    self.delegate.edgeWindowController!(self, mouseHoverAt: point)
    
  }
  
  override func mouseExited(with event: NSEvent) {
    
    guard let trackTimer = self._trackTimer else { return }
    
    trackTimer.invalidate()
    
    self._trackTimer = nil
    
    self._trackSentHover = false
    
    self.delegate.edgeWindowController!(self, mouseHoverAt: NSPoint(x: CGFloat.nan, y: CGFloat.nan))
    
  }
  
  override func mouseUp(with event: NSEvent) {
    
    guard self._trackTimer != nil else { return }
    
    let point = self.convertBaseToTouchBar(point: event.locationInWindow)
    
    self.delegate.edgeWindowController(self, mouseClickAt: point)
    
  }
  
  func wantsPeriodicDraggingUpdates() -> Bool {
    
    return true
    
  }
  
  func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    
    guard let trackTimer = self._trackTimer else { return [] }
    guard let trackSentHover = self._trackSentHover else { return [] }
    
    trackTimer.invalidate()
    
    self._trackTimer = nil
    
    if trackSentHover {
      
      _trackSentHover = false
      
      self.delegate.edgeWindowController!(self, mouseHoverAt: NSPoint(x: CGFloat.nan, y: CGFloat.nan))
      
    }
    
    return self.draggingUpdated(sender)
    
  }
  
  func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
    
    guard let pasteboardTypes = sender.draggingPasteboard.types else { return [] }
    
    let point = self.convertBaseToTouchBar(point: sender.draggingLocation)
    
    if pasteboardTypes.contains(NSPasteboard.PasteboardType.filePromise) {
      
      let dragOperation = self.delegate.edgeWindowController(
        self,
        dragURLs: [],
        atPoint: point,
        operation: sender.draggingSourceOperationMask
      )
      
      return dragOperation
      
    }
    
    guard let pasteboardURLs = sender.draggingPasteboard.readObjects(
      forClasses: [URL.ReferenceType.self],
      options: nil
    ) as? [URL] else { return [] }
    
    let dragOperation = self.delegate.edgeWindowController(
      self,
      dragURLs: pasteboardURLs,
      atPoint: point,
      operation: sender.draggingSourceOperationMask
    )
    
    return dragOperation
    
  }
  
  func draggingEnded(_ sender: NSDraggingInfo) {
    
    self.draggingExited(sender)
    
  }
  
  func draggingExited(_ sender: NSDraggingInfo?) {
    
    guard let sender = sender else { return }
    
    _ = self.delegate.edgeWindowController(
      self,
      dragURLs: [],
      atPoint: NSPoint.zero,
      operation: sender.draggingSourceOperationMask
    )
    
  }
  
  func performDragOperation(_ sender: NSDraggingInfo) -> Bool { // TODO: Clean up
    
    var urls = [URL]()
    
    guard let pasteboardTypes = sender.draggingPasteboard.types else { return false }
    
    let point = self.convertBaseToTouchBar(point: sender.draggingLocation)
    
    if !pasteboardTypes.contains(NSPasteboard.PasteboardType.filePromise) {
      
      guard let pasteboardURLs = sender.draggingPasteboard.readObjects(
        forClasses: [URL.ReferenceType.self],
        options: nil
      ) as? [URL] else { return false }
      
      urls = pasteboardURLs
      
    }
    
    let res = self.delegate.edgeWindowController(
      self,
      dropURLs: urls,
      atPoint: point,
      operation: sender.draggingSourceOperationMask
    )
    
    guard let success = res["success"] as? Bool else { return false }
    guard let url = res["url"] as? URL else { return false }
    
    if success {
      
      sender.namesOfPromisedFilesDropped(atDestination: url)
      
    }
    
    return success
    
  }
  
}
