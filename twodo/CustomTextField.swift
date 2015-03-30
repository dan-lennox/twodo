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
      //TODO: Fix up the optional checking here... obviously wrong.
      let editorset: NSTextView? = (self.currentEditor() as? NSTextView);
      if (editorset != nil) {
        // Change the blinking cursor colour
        let textField: NSTextView = (self.currentEditor() as NSTextView)
        textField.insertionPointColor = NSColor.whiteColor()
        // Ditch the highlight on the text.
        let range_zero: NSRange = NSRange(location: 0, length: 0)
        textField.setSelectedRange(range_zero)
        // Move cursor to the end of the line.
        textField.moveToEndOfLine(nil)
      }
    }
    return success;
  }
  
  func addStrikethrough() {
    let strikeThroughText: NSAttributedString = NSAttributedString(string: self.stringValue, attributes : [NSStrikethroughStyleAttributeName: NSUnderlineStyleSingle])
    self.attributedStringValue = strikeThroughText
  }
  
  func removeStrikethrough() {
    let plainText: NSAttributedString = NSAttributedString(string: self.stringValue)
    self.attributedStringValue  = plainText
  }
  
}
