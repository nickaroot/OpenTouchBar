//
//  FolderItemView.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 13/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class FolderItemView: NSScrubberItemView {
  
  var imageTitleView: ImageTitleView!
  
  override init(frame frameRect: NSRect) {
    
    let imageTitleView = ImageTitleView(frame: NSRect.zero)
    
    imageTitleView.translatesAutoresizingMaskIntoConstraints = false
    imageTitleView.autoresizingMask = [.width, .height]
    imageTitleView.titleFont = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
    imageTitleView.titleLineBreakMode = .byTruncatingTail
    imageTitleView.layoutOptions = ImageTitleView.LayoutOptions.image | ImageTitleView.LayoutOptions.title
    
    self.imageTitleView = imageTitleView
    
    super.init(frame: frameRect)
    
    self.addSubview(self.imageTitleView)
    
  }
  
  required init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func removeFromSuperview() {
    
    self.isHidden = true
    
    super.removeFromSuperview()
    
  }
  
}
