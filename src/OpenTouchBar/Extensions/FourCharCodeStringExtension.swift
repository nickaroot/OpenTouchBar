//
//  FourCharCodeStringExtension.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/01/2019.
//  Copyright © 2019 Nikita Arutyunov. All rights reserved.
//

import Foundation

extension String {
  
  static func fc(from string: String) -> FourCharCode {
    return string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
  }
  
  var fcc: FourCharCode {
    return String.fc(from: self)
  }
  
}
