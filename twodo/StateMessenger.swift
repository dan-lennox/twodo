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
    case lostStreak
  }
  var currentState: MessengerState
  //var messages: [MessengerState: String]
  
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
    
    // Max 43 characters.
    //self.messages = [.firstUse: "Everything else can wait.."]
    //self.messages[.oneItemLeft] = "Sure, but can you do both things. Probably not..."
    //self.messages[.firstStreak] = "Huh.. well I guess I was wrong.. this time."
    
    // I'm guessing you'll give up and go to bed now?
    // There will be cake..
    // Well done! The cake is coming.. a few more days perhaps.
    // Nice one! Now try for two days in a row.
    // Match your current record!
    // New record today!
    // 
  }
  

  func updateState(streak: Int, record: Int, status1: Int, status2: Int) -> () {
    
    self.currentState = .firstUse
    var oneTicked = false
    var bothTicked = false
    self.currentColor = self.offColor
    
    if (record > 1) {
      self.currentState = .lostStreak;
    }
    
    // Establish if only 1 item is ticked.
    if (status1 == 1 && status2 == 0 || status1 == 0 && status2 == 1) {
      oneTicked = true
    }
    
    // If both items ticked. Color is green, otherwise red.
    if (status1 == 1 && status2 == 1) {
      self.currentColor = self.onColor
      bothTicked = true
    }
    // Just one item ticked.
    if (oneTicked == true) {
      self.currentState = .oneItemLeft
    }
    // Both item ticked and streak is 1
    if (bothTicked == true && streak == 1) {
      self.currentState = .firstStreak
    }
    // 3 day streak
    // 7 day streak
    // 14 day streak
    // 20 day streak
    // 30 day streak
    // 50 day streak
    // 75 day streak
    // 100 day streak
  }

  func getMessage() -> (message: String, color: NSColor) {
    print(self.currentState);
    var message = "You can do it!"
    switch self.currentState {
      case .firstUse:
        let variations = Config.states.firstUse.messages;
        let randomIndex = Int(arc4random_uniform(UInt32(variations.count)))
        message = Config.states.firstUse.messages[randomIndex]
        break;
      case .lostStreak:
        let variations = Config.states.lostStreak.messages;
        let randomIndex = Int(arc4random_uniform(UInt32(variations.count)))
        message = Config.states.lostStreak.messages[randomIndex]
        break;
      default:
        return ("TODO: Define messages for this state.", self.currentColor)
    }
    
    // We want to do stuff above like
    // self.currentState = Config.states.firstUse
    
    // Add randomisation
    
    
    return (message, self.currentColor)
  }
}