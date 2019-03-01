//
//  Brightness.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

extension System {
  
  private static var _brightness = Float(0)
  
  static var brightness: Float {
    
    get {
      
      var iterator: io_iterator_t = 0
      
      let status = IOServiceGetMatchingServices(
        kIOMasterPortDefault,
        IOServiceMatching("IODisplayConnect"),
        &iterator
      )
      
      if status == kIOReturnSuccess {
        
        var service: io_object_t = 1
        
        while service != 0 {
          
          service = IOIteratorNext(iterator)
          IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &_brightness)
          IOObjectRelease(service)
          
          return _brightness
          
        }
        
      }
      
      return _brightness
      
    }
    
    set {
      
      var iterator: io_iterator_t = 0
      
      let status = IOServiceGetMatchingServices(
        kIOMasterPortDefault,
        IOServiceMatching("IODisplayConnect"),
        &iterator
      )
      
      if status == kIOReturnSuccess {
        
        var service: io_object_t = 1
        
        while service != 0 {
          
          service = IOIteratorNext(iterator)
          IODisplaySetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, newValue)
          IOObjectRelease(service)
          
        }
        
      }
      
    }
    
  }
  
  private static var _maxKeyboardBrightness: Float = 342
  
  private static var _keyboardBrightness = Float(0)
  
  static var keyboardBrightness: Float {
    
    get {
      
      let service = IOServiceGetMatchingService(
        kIOMasterPortDefault,
        IOServiceMatching("AppleHIDKeyboardEventDriverV2")
      )
      
      defer {
        
        IOObjectRelease(service)
        
      }
      
      let ser: CFTypeRef = IORegistryEntryCreateCFProperty(
        service,
        "KeyboardBacklightBrightness" as CFString,
        kCFAllocatorDefault,
        0
      ).takeUnretainedValue()
      
      if let result = ser as? Float {
        _keyboardBrightness = result / _maxKeyboardBrightness
      }
      
      return _keyboardBrightness
      
    }
    
    set { // Not worked with MacBook Pro 2016+
      
      let service = IOServiceGetMatchingService(
        kIOMasterPortDefault,
        IOServiceMatching("AppleHIDKeyboardEventDriverV2")
      )
      
      defer {
        
        IOObjectRelease(service)
        
      }
      
      _keyboardBrightness = newValue * _maxKeyboardBrightness
      
      _keyboardBrightness = newValue > _maxKeyboardBrightness ? _maxKeyboardBrightness : _keyboardBrightness
      
      let cfKeyboardBrightness = CFNumberCreate(kCFAllocatorDefault, CFNumberType.doubleType, &_keyboardBrightness)
      
      IORegistryEntrySetCFProperty(service, "KeyboardBacklightBrightness" as CFString, cfKeyboardBrightness)
      
    }
    
  }
  
}
