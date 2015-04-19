//
//  CustomTextField.swift
//  twodo
//
//  Created by Daniel Lennox on 25/02/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Foundation
import Cocoa
import CoreData
import AppKit

class CustomTextField: NSTextField {
  
  
  override func becomeFirstResponder() -> Bool {
    let success: Bool = super.becomeFirstResponder();
    
    if(success) {
      self.textColor = NSColor.whiteColor()
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
  
  func setInitialAttributes() -> () {
    let attributes = NSMutableAttributedString(string: self.placeholderString!)
    // Cast string to NSString so we can use length.
    let stringValue = self.placeholderString as NSString?
    let range = NSRange(location: 0, length: stringValue!.length)
    // Add the foreground attribute.
    attributes.addAttribute(NSForegroundColorAttributeName, value: NSColor.grayColor(), range: range)
    let font = NSFont(name: "Helvetica", size: 14.0)
    // Add the font size attribute.
    attributes.addAttribute(NSFontAttributeName, value: font!, range: range)
    println(attributes)
    // Save back to the NSTextField.
    self.placeholderAttributedString = attributes
  }
  
  func addStrikethrough() {
    // Grab the current attributes of our string used by the NSTextField.
    let attributes = NSMutableAttributedString(attributedString: self.attributedStringValue)
    // Cast string to NSString so we can use length.
    let string = self.stringValue as NSString
    let range = NSRange(location: 0, length: string.length)
    // Add the strikethrough attribute.
    attributes.addAttribute(NSStrikethroughStyleAttributeName, value: NSUnderlineStyleSingle, range: range)
    // Save back to the NSTextField.
    self.attributedStringValue = attributes
  }
  
  func removeStrikethrough() {
    // Grab the current attributes of our string used by the NSTextField.
    let attributes = NSMutableAttributedString(attributedString: self.attributedStringValue)
    // Cast string to NSString so we can use length.
    let string = self.stringValue as NSString
    let range = NSRange(location: 0, length: string.length)
    // Remove the strikethrough attribute.
    attributes.removeAttribute(NSStrikethroughStyleAttributeName, range: range)
    // Save back to the NSTextField.
    self.attributedStringValue = attributes
  }
}
