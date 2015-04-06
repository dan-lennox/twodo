//
//  CustomView.swift
//  twodo
//
//  Created by Daniel Lennox on 23/03/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Foundation

class CustomViewController: NSViewController {

  var onViewAppeared: () -> ()
  
  required init?(coder: NSCoder) {
    self.onViewAppeared = {}
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidAppear() {
    super.viewDidAppear()
    println("view appeared")
    self.onViewAppeared()
    //self.view.window?.becomeFirstResponder()
    //self.view.window?.makeKeyWindow()
  }
  

}