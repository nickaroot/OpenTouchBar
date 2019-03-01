//
//  FolderController+NSScrubberDataSource.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 02/02/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Cocoa

extension FolderController: NSScrubberDataSource {
  func numberOfItems(for scrubber: NSScrubber) -> Int {
    return self.contents.count
  }
  
  func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView { // TODO: views not displays
    
    let item = self.contents[index]
    
    guard let view: FolderItemView = self.scrubber.makeItem(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "item"),
      owner: nil
      ) as? FolderItemView else { return NSScrubberItemView(frame: .zero) }
    
    guard let itemIcon = item.icon else { return NSScrubberItemView(frame: .zero) }
    guard let itemUrl = item.url else { return NSScrubberItemView(frame: .zero) }
    
    view.isHidden = false
    view.imageTitleView.image = itemIcon
    view.imageTitleView.title = NSControl.ImagePosition.imageOnly != self.imagePosition ? itemUrl.lastPathComponent : ""
    view.setFrameSize(NSControl.ImagePosition.imageOnly != self.imagePosition ? FolderController.largeItemSize :
      FolderController.smallItemSize)
    
    return view
    
  }
}
