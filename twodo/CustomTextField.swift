//
//  CustomTextField.swift
//  twodo
//
//  Created by Daniel Lennox on 25/02/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Foundation

class CustomTextField: NSTextField {
  
  override func becomeFirstResponder() -> Bool {
    let success: Bool = super.becomeFirstResponder();
    
    if(success) {
      // Strictly spoken, NSText (which currentEditor returns) doesn't
      // implement setInsertionPointColor:, but it's an NSTextView in practice.
      // But let's be paranoid, better show an invisible black-on-black cursor
      // than crash.
      let textField: NSTextView = self.currentEditor() as NSTextView
      textField.insertionPointColor = NSColor.whiteColor()
    }
    return success;
  }
}
