//
//  IconView.swift
//  twodo
//
//

import Foundation
import Cocoa
import AppKit

class IconView : NSView
{
    private(set) var image: NSImage
    private var item: NSStatusItem
  
    var onMouseDown: () -> ()
    
    var isSelected: Bool {
      didSet {
        //redraw if isSelected changes for bg highlight
        if (isSelected != oldValue) {
          self.needsDisplay = true
          println("is selected true")
        }
      }
    }
    
    init(imageName: String, item: NSStatusItem)
    {
    //  let iconImage = NSImage(named: "icon")
  //    iconImage?.setTemplate(true)
//      item.image = iconImage
        var templateImage = NSImage(named: imageName)!
        templateImage.setTemplate(true)
        self.image = templateImage
        self.item = item
        self.isSelected = false
        self.onMouseDown = {}
        
        let thickness = NSStatusBar.systemStatusBar().thickness
        let rect = CGRectMake(0, 0, thickness, thickness)
        
        super.init(frame: rect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
  override func drawRect(dirtyRect: NSRect) {
    self.item.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: self.isSelected)
    
    let size = self.image.size
    let rect = CGRectMake(2, 2, size.width, size.height)
    
    self.image.drawInRect(rect)

  }
  
  override func mouseDown(theEvent: NSEvent) {
    self.isSelected = !self.isSelected;
    self.onMouseDown();
    println("Mouse down called")
  }
  
}
