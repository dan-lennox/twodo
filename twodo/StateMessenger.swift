//
//  stateMessenger.swift
//  twodo
//
//  Created by Daniel Lennox on 13/04/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Foundation
import Cocoa
import CoreData
import AppKit

class StateMessenger {

  enum MessengerState {
    case firstUse
    case oneItemLeft
    case firstStreak
  }
  var currentState: MessengerState
  var messages: [MessengerState: String]
  
  var currentColor: NSColor
  var onColor: NSColor
  var offColor: NSColor

  init() {
    
    var rFloat: CGFloat = 0.0/255.0
    var gFloat: CGFloat = 189.0/255.0
    var bFloat: CGFloat = 146.0/255.0
    
    self.onColor = NSColor(red: rFloat, green: gFloat, blue: bFloat, alpha: 1.0)
    
    rFloat = 255.0/255.0
    gFloat = 142.0/255.0
    bFloat = 136.0/255.0
    
    self.offColor = NSColor(red: rFloat, green: gFloat, blue: bFloat, alpha: 1.0)

    self.currentState = .firstUse
    self.currentColor = self.offColor
    
    self.messages = [.firstUse: "You suck! But it will get better."]
    self.messages[.oneItemLeft] = "Sure, but can you do both things. Probably not..."
    self.messages[.firstStreak] = "Huh.. well I guess I was wrong.. this time."
  }
  

  func updateState(streak: Int, record: Int, status1: Int, status2: Int) -> () {
    
    self.currentState = .firstUse
    var oneTicked = false
    var bothTicked = false
    self.currentColor = self.offColor
    
    // Establish if only 1 item is ticked.
    if (status1 == 1 && status2 == 0 || status1 == 0 && status2 == 1) {
      oneTicked = true
    }
    
    // If both items ticked. Color is green, otherwise red.
    if (status1 == 1 && status2 == 1) {
      self.currentColor = self.onColor
      bothTicked = true
    }
    
    if (oneTicked == true) {
      self.currentState = .oneItemLeft
    }
    
    if (bothTicked == true && streak == 1) {
      self.currentState = .firstStreak
    }
  }

  func getMessage() -> (message: String, color: NSColor) {
    return (self.messages[self.currentState]!, self.currentColor)
  }
}