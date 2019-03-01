//
//  TouchBarDelegate.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 07/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

class TouchBarDelegate: TouchBarController, NSTouchBarDelegate {
  
  struct WidgetItem {
    
    let `class`: NSTouchBarItem.Type
    
    var object: NSTouchBarItem?
    
  }
  
  static var widgets: [NSTouchBarItem.Identifier: WidgetItem] = [:]
  
  override func awakeFromNib() {
    
    self.appTouchBar.defaultItemIdentifiers =
      
      [
        EscKeyWidget.widgetIdentifier,
        ActiveAppWidget.widgetIdentifier,
        DockWidget.widgetIdentifier
    ]
    
    //        [
    //            NSTouchBarItem.Identifier("EscKey"),
    //            NSTouchBarItem.Identifier("ActiveApp"),
    //            NSTouchBarItem.Identifier("Dock"),
    //            NSTouchBarItem.Identifier("Control"),
    //            NSTouchBarItem.Identifier("Clock"),
    //            NSTouchBarItem.Identifier("")
    //        ]
    
    self.appTouchBar.customizationAllowedItemIdentifiers =
      
      [
        DockWidget.widgetIdentifier,
        EscKeyWidget.widgetIdentifier,
        ActiveAppWidget.widgetIdentifier
    ]
    
    //        [
    //            NSTouchBarItem.Identifier("Dock"),
    //            NSTouchBarItem.Identifier("EscKey"),
    //            NSTouchBarItem.Identifier("ActiveApp"),
    //            NSTouchBarItem.Identifier("NowPlaying"),
    //            NSTouchBarItem.Identifier("Control"),
    //            NSTouchBarItem.Identifier("Weather"),
    //            NSTouchBarItem.Identifier("Clock"),
    //            NSTouchBarItem.Identifier("Lock"),
    //            NSTouchBarItem.Identifier.flexibleSpace,
    //            NSTouchBarItem.Identifier("")
    //        ]
    
    super.awakeFromNib()
    
  }
  
  func touchBar(_ touchBar: NSTouchBar,
                makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
    
    guard var item = TouchBarDelegate.widgets[identifier] else { return nil }
    
    if item.object == nil {
      
      let widgetClass = item.class
      
      let object = widgetClass.init(identifier: identifier)
      
      item.object = object
      
      TouchBarDelegate.widgets[identifier] = item
      
    }
    
    return item.object
    
  }
  
}
