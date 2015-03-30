//
//  CustomButton.swift
//  twodo
//
//  Created by Daniel Lennox on 20/03/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Foundation
import Cocoa

class CustomButtonCell: NSButtonCell {
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    // Remove the colour change when the button is pressed in (mouse down).
    self.highlightsBy = NSCellStyleMask.NoCellMask
  }
}
