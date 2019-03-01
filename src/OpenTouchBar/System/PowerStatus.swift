//
//  PowerStatus.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

import IOKit.ps

extension System {
  
  struct PowerStatus {
    
    var level: Float
    
    var percents: Int {
      
      return (Int(level * 100))
      
    }
    
    var title: String {
      
      return ("\(percents)%")
      
    }
    
  }
  
  private static var _powerStatus = PowerStatus(level: 0)
  
  static var powerStatus: PowerStatus {
    
    guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue()
      else { return _powerStatus }
    
    guard let powerSources: NSArray = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue()
      else { return _powerStatus }
    
    for powerSource in powerSources {
      
      guard let info: NSDictionary = IOPSGetPowerSourceDescription(
        snapshot,
        powerSource as CFTypeRef
      )?.takeUnretainedValue() else { return _powerStatus }
      
      guard let capacity = info[kIOPSCurrentCapacityKey] as? Int
        else { return _powerStatus }
      
      guard let max = info[kIOPSMaxCapacityKey] as? Int
        else { return _powerStatus }
      
      _powerStatus.level = Float(capacity) / Float(max)
      
      return _powerStatus
      
    }
    
    return _powerStatus
    
  }
  
}
