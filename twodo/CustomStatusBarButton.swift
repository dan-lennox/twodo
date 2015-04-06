//
//  CustomStatusBarButton.swift
//  twodo
//
//  Created by Daniel Lennox on 6/04/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Foundation

class CustomStatusBarButton: NSStatusBarButton {
  
  override func mouseDown(theEvent: NSEvent) {
    println("status bar moud down")
  }
}