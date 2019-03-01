//
//  ImageTitleView.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 25/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

class ImageTitleView: NSView {
  
  struct LayoutOptions: OptionSet {
    
    let rawValue: Int
    
    static let image = ImageTitleView.LayoutOptions(rawValue: 1 << 0)
    static let title = ImageTitleView.LayoutOptions(rawValue: 1 << 1)
    static let subtitle = ImageTitleView.LayoutOptions(rawValue: 1 << 2)
    
    static func | (left: ImageTitleView.LayoutOptions,
                   right: ImageTitleView.LayoutOptions) -> ImageTitleView.LayoutOptions {
      
      return ImageTitleView.LayoutOptions(rawValue: left.rawValue | right.rawValue)
      
    }
    
    static func & (left: ImageTitleView.LayoutOptions,
                   right: ImageTitleView.LayoutOptions) -> ImageTitleView.LayoutOptions {
      
      return ImageTitleView.LayoutOptions(rawValue: left.rawValue & right.rawValue)
      
    }
    
  }
  
  static let DefaultSpacerWidth: CGFloat = 4
  
  private var imageView: NSImageView!
  private var titleView: NSTextField!
  private var subtitleView: NSTextField!
  
  private var _imageSize: NSSize
  private var _layoutOptions: ImageTitleView.LayoutOptions
  
  var image: NSImage {
    
    get {
      
      guard let image = self.imageView.image else { return NSImage() }
      
      return image
      
    }
    
    set {
      
      imageView.image = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var imageSize: NSSize {
    
    get {
      
      return _imageSize
      
    }
    
    set {
      
      if _imageSize.width == newValue.width && _imageSize.height == newValue.height { return }
      
      _imageSize = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var title: String {
    
    get {
      
      return titleView.stringValue
      
    }
    
    set {
      
      titleView.stringValue = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var titleFont: NSFont {
    
    get {
      
      guard let font = titleView.font else { return NSFont() }
      
      return font
      
    }
    
    set {
      
      titleView.font = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var titleLineBreakMode: NSLineBreakMode {
    
    get {
      
      return titleView.lineBreakMode
      
    }
    
    set {
      
      titleView.lineBreakMode = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var subtitle: String {
    
    get {
      
      return subtitleView.stringValue
      
    }
    
    set {
      
      self.subtitleView.stringValue = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var subtitleFont: NSFont {
    
    get {
      
      guard let font = subtitleView.font else { return NSFont() }
      
      return font
      
    }
    
    set {
      
      subtitleView.font = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var subtitleLineBreakMode: NSLineBreakMode {
    
    get {
      
      return subtitleView.lineBreakMode
      
    }
    
    set {
      
      subtitleView.lineBreakMode = newValue
      
      needsLayout = true
      
    }
    
  }
  
  var layoutOptions: ImageTitleView.LayoutOptions {
    
    get {
      
      return _layoutOptions
      
    }
    
    set {
      
      _layoutOptions = newValue
      
      needsLayout = true
      
    }
    
  }
  
  required init?(coder decoder: NSCoder) {
    
    _imageSize = NSSize(width: 30, height: 30)
    _layoutOptions = .init(rawValue: 0)
    
    super.init(coder: decoder)
    
  }
  
  override init(frame frameRect: NSRect) {
    
    _imageSize = NSSize(width: 30, height: 30)
    _layoutOptions = .init(rawValue: 0)
    
    super.init(frame: frameRect)
    
    imageView = NSImageView(frame: .zero)
    
    imageView.autoresizingMask = .none
    imageView.imageScaling = .scaleProportionallyDown
    
    titleView = NSTextField(string: "")
    
    titleView.autoresizingMask = .none
    titleView.alignment = .left
    
    subtitleView = NSTextField(string: "")
    
    subtitleView.autoresizingMask = .none
    subtitleView.alignment = .left
    
    self.addSubview(imageView)
    self.addSubview(titleView)
    self.addSubview(subtitleView)
    
  }
  
  override func layout() {
    
    super.layout()
    
    let bounds = self.bounds
    
    guard let showsImage = Bool(
      exactly: NSNumber(value: (_layoutOptions & ImageTitleView.LayoutOptions.image).rawValue)
    ) else { return }
    
    guard let showsTitle = Bool(
      exactly: NSNumber(value: (_layoutOptions & ImageTitleView.LayoutOptions.title).rawValue)
    ) else { return }
    
    guard let showsSubtitle = Bool(
      exactly: NSNumber(value: (_layoutOptions & ImageTitleView.LayoutOptions.subtitle).rawValue)
    ) else { return }
    
    let imageSize = showsImage ? _imageSize : .zero
    
    guard let titleViewCell = titleView.cell else { return }
    var titleSize = showsTitle ? titleViewCell.cellSize(forBounds: bounds) : .zero
    
    guard let subtitleViewCell = subtitleView.cell else { return }
    var subtitleSize = showsSubtitle ? subtitleViewCell.cellSize(forBounds: bounds) : .zero
    
    let spacerWidth = imageSize.width != 0 &&
      (titleSize.width != 0 || subtitleSize.width != 0) ? ImageTitleView.DefaultSpacerWidth : 0
    let imageSpacerWidth = imageSize.width + spacerWidth
    
    // Stop the labels from going out of bounds
    titleSize.width = min(titleSize.width, bounds.size.width - imageSpacerWidth)
    subtitleSize.width = min(subtitleSize.width, bounds.size.width - imageSpacerWidth)
    
    let totalWidth = imageSpacerWidth + max(titleSize.width, subtitleSize.width)
    
    let imageRectOrigin = CGPoint(
      x: round((bounds.size.width - totalWidth) / 2),
      y: round((bounds.size.height - imageSize.height) / 2)
    )
    
    let imageRect = NSRect(origin: imageRectOrigin, size: imageSize)
    
    let titleRectOrigin = CGPoint(
      x: round(imageRect.origin.x + imageSpacerWidth),
      y: round((bounds.size.height - titleSize.height + subtitleSize.height) / 2)
    )
    
    let titleRect = NSRect(origin: titleRectOrigin, size: titleSize)
    
    let subtitleRectOrigin = CGPoint(
      x: round(imageRect.origin.x + imageSpacerWidth),
      y: round((bounds.size.height - titleSize.height - subtitleSize.height) / 2)
    )
    
    let subtitleRect = NSRect(origin: subtitleRectOrigin, size: subtitleSize)
    
    imageView.frame = imageRect
    titleView.frame = titleRect
    subtitleView.frame = subtitleRect
    
  }
  
}
