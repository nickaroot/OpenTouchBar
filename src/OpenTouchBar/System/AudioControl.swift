//
//  AudioControl.swift
//  OpenTouchBar
//
//  Created by Nikita Arutyunov on 30/12/2018.
//  Copyright © 2018 Nikita Arutyunov. All rights reserved.
//

import CoreAudio
import AudioToolbox

extension System {
  
  static var volume: Float {
    
    get {
      
      var defaultOutputDeviceID = AudioDeviceID(0)
      var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
      
      var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
        mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &getDefaultOutputDevicePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &defaultOutputDeviceID
      )
      
      var volumePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMasterVolume),
        mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      var volume = Float32(0)
      
      AudioObjectGetPropertyData(
        defaultOutputDeviceID,
        &volumePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &volume
      )
      
      return Float(volume)
      
    }
    
    set {
      
      var defaultOutputDeviceID = AudioDeviceID(0)
      var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
      
      var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
        mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &getDefaultOutputDevicePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &defaultOutputDeviceID
      )
      
      var volume = Float32(newValue)
      let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
      
      var volumePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMasterVolume),
        mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, nil, volumeSize, &volume)
      
    }
    
  }
  
  static var mute: Bool {
    
    get {
      
      var defaultOutputDeviceID = AudioDeviceID(0)
      var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
      
      var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
        mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &getDefaultOutputDevicePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &defaultOutputDeviceID
      )
      
      var volumePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioDevicePropertyMute),
        mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      var mute = UInt32(0)
      
      AudioObjectGetPropertyData(
        defaultOutputDeviceID,
        &volumePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &mute
      )
      
      return (mute != 0)
      
    }
    
    set {
      
      var defaultOutputDeviceID = AudioDeviceID(0)
      var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
      
      var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
        mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &getDefaultOutputDevicePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &defaultOutputDeviceID
      )
      
      var mute = UInt32(newValue ? 1 : 0)
      let muteSize = UInt32(MemoryLayout.size(ofValue: mute))
      
      var volumePropertyAddress = AudioObjectPropertyAddress(
        mSelector: AudioObjectPropertySelector(kAudioDevicePropertyMute),
        mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster)
      )
      
      AudioObjectSetPropertyData(defaultOutputDeviceID, &volumePropertyAddress, 0, nil, muteSize, &mute)
      
    }
    
  }
  
}
