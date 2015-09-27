//
//  AppDelegate.swift
//  twodo
//
//  Created by Daniel Lennox on 17/01/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Cocoa
import CoreData
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var application: NSApplication!
  @IBOutlet weak var detachWindow: NSWindow!
  @IBOutlet var popover : NSPopover!

  var item: NSStatusItem

  var firstTimeActiveFlag: Bool!

  @IBOutlet weak var headerLabel1: NSTextField!
  
  @IBOutlet weak var item1State: NSButton!
  @IBOutlet weak var item1Text: CustomTextField!
  @IBOutlet weak var item2State: NSButton!
  @IBOutlet weak var item2Text: CustomTextField!
  @IBOutlet weak var item1Box: NSBox!
  @IBOutlet weak var item2Box: NSBox!

  @IBOutlet weak var currentStreak: NSTextField!
  @IBOutlet weak var longestStreak: NSTextField!

  var listItem1: NSManagedObject!
  var listItem2: NSManagedObject!
  var streakRecorder: NSManagedObject!

  var onColor: NSColor!
  var offColor: NSColor!
  var undoneColor: NSColor!
  
  var newDayChecker: NSTimer!

  @IBOutlet weak var heading: NSTextField!
  
  var stateMessenger: StateMessenger!
  
//  var managedObjectContext: NSManagedObjectContext!
  
  @IBOutlet weak var messageBox: NSBox!
  @IBOutlet weak var message: NSTextField!
  
  var yesterdays_current_streak: Int!

  @IBAction func item1Enter(sender: CustomTextField) {
    sender.resignFirstResponder()
    item2Text.becomeFirstResponder()
  }
  
  func saveData() {
    let managedContext = self.managedObjectContext
    var error: NSError?

    self.listItem1.setValue(self.item1Text.stringValue, forKey: "text")
    self.listItem1.setValue(self.item1State.state, forKey: "state")
    
    self.listItem2.setValue(self.item2Text.stringValue, forKey: "text")
    self.listItem2.setValue(self.item2State.state, forKey: "state")
    
    self.streakRecorder.setValue(self.currentStreak.integerValue, forKey: "current");
    self.streakRecorder.setValue(self.longestStreak.integerValue, forKey: "longest");
    
    //Debug: Reset record
    //self.streakRecorder.setValue(0, forKey: "longest");
    
    self.streakRecorder.setValue(NSDate(), forKey: "last_use");
    
    do {
      try managedContext?.save()
    } catch let error1 as NSError {
      error = error1
      print("Could not save \(error), \(error?.userInfo)")
    }
  }
  
  @IBAction func textChecked(sender: NSButton) {
    if sender.state == 1 {
      var empty = false
      // Check to make sure the text field isn't empty.
      // This code here is why you need to refactor, obviously not great.
      if sender.identifier == "item1" {
        let item1String = self.item1Text.stringValue as NSString
        if (item1String.length == 0) {
          empty = true
          // Don't allow empty list items to be checked.
          self.item1State.state = 0
        }
      }
      else {
        let item2String = self.item2Text.stringValue as NSString
        if (item2String.length == 0) {
          empty = true
          // Don't allow empty list items to be checked.
          self.item2State.state = 0
        }
      }
      
      if (self.bothItemsTicked() && !empty) {
        self.currentStreak.integerValue = self.currentStreak.integerValue + 1
      }
      self.updateStreak()
    }
    else {
      var other: NSButton
      
      // Find out the identifier of the other list item.
      if sender.identifier == "item1" {
        other = self.item2State
      }
      else {
        other = self.item1State
      }
      // If the other list item is ticked, and this list item has just been unticked, then we know
      // that both were ticked previously and a task has been "undone" so we should decrement the streak.
      if other.state == 1 {
        // Check the current streak to see if it's bigger than yesterdays. If so then
        // we need to decrement when an item is unchecked.
        if self.currentStreak.integerValue >= self.yesterdays_current_streak {
          self.currentStreak.integerValue--
          // We also then need to decrement the longest streak record if it was broken by today's
          // temporary result.
          if self.longestStreak.integerValue > self.streakRecorder.valueForKey("longest") as! Int {
            self.longestStreak.integerValue--
          }
        }
      }
      
    }
    self.updateTextStatus()
    self.updateMessage()
  }
  
  override init() {
    self.firstTimeActiveFlag = true
    
    let bar = NSStatusBar.systemStatusBar();
    let length: CGFloat = -1
    self.item = bar.statusItemWithLength(length);
    
    let iconImage = NSImage(named: "icon")
    iconImage?.template = true
    self.item.image = iconImage
    
    self.item.button?.action = Selector("StatusItemClicked:")
    self.yesterdays_current_streak = 0
    
    self.stateMessenger = StateMessenger()
    
    super.init();
    self.initColors()
  }
  
  @IBAction func StatusItemClicked(sender: NSStatusBarButton) {
    if !(popover.shown) {
      self.popover?.showRelativeToRect(sender.bounds, ofView: self.item.button!, preferredEdge: NSRectEdge.MinY)
      self.application.activateIgnoringOtherApps(true)
    }
    else {
      self.popover?.close()
      self.application.hide(self)
    }
  }
  
  func initColors() {
    let rFloat: CGFloat = 0.0/255.0
    let gFloat: CGFloat = 189.0/255.0
    let bFloat: CGFloat = 146.0/255.0
    
    self.onColor = NSColor(red: rFloat, green: gFloat, blue: bFloat, alpha: 1.0)
    
    let grey: CGFloat = 41.0/255.0
    
    self.offColor = NSColor(red: grey, green: grey, blue: grey, alpha: 1.0)
  }
  
  func applicationWillFinishLaunching(notification: NSNotification) {
    // Hide the dock item.
    NSApp.setActivationPolicy(.Accessory)
  }
  
  func applicationDidFinishLaunching(aNotification: NSNotification) {
    self.newDayChecker = NSTimer()
    self.newDayChecker = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("checkNewDayEvent"), userInfo: nil, repeats: true)
    
    // Insert code here to initialize your application
    self.loadListItems()
    self.loadStreakRecorder()
    
    self.checkNewDayEvent()
    
    self.item1Text.setInitialAttributes()
    self.item2Text.setInitialAttributes()
  }
  
  func updateMessage() {
    self.stateMessenger.updateState(self.currentStreak.integerValue, record: self.longestStreak.integerValue, status1: self.item1State.state, status2: self.item2State.state)
    
    let message = self.stateMessenger.getMessage()
    self.messageBox.fillColor = message.color
    self.message.stringValue = message.message
  }
    
  func applicationDidBecomeActive(notification: NSNotification) {
    // Make the app resign active on the first time.
    // This is to stop the menubar highlighting before it's clicked.
    if (self.firstTimeActiveFlag == true) {
      self.application.hide(self.application)
      self.firstTimeActiveFlag = false
    }
    else {
      // Highlight the menubar Icon.
      self.item.highlightMode = true
      self.item.button?.highlight(true)
    }
  }
  
  func applicationDidResignActive(notification: NSNotification) {
    // Save our data when the user clicks out of the app.
    self.updateStreak()
    self.saveData()
    // Unhighlight the menubar icon
    self.item.button?.highlight(false)
    self.item.highlightMode = false
    
    self.popover?.close()
  }

  func updateStreak() {
    if (self.bothItemsTicked()) {
      // Lets only save the streak data if it's a new day.
      if self.isNewDay() {
        self.streakRecorder.setValue(self.currentStreak.integerValue, forKey: "current")
        self.streakRecorder.setValue(self.longestStreak.integerValue, forKey: "longest")
        self.clearLists()
      }
      else {
        if self.currentStreak.integerValue > self.longestStreak.integerValue {
          // Check if we've beaten our longest ever streak.
          self.longestStreak.integerValue = self.currentStreak.integerValue
        }
      }
    }
    else if self.isNewDay() {
      // The streak is broken and it's a new day, reset the streak.
      self.currentStreak.integerValue = 0
      self.streakRecorder.setValue(0, forKey: "current")
      // If it's a new day, streak or no streak, we clear the lists.
      self.clearLists()
    }
  }
  
  func checkNewDayEvent() {
    self.updateUI()
    // Store yesterdays current streak.
    self.yesterdays_current_streak = self.streakRecorder.valueForKey("current") as! Int
    
    self.currentStreak.integerValue = self.yesterdays_current_streak
    self.longestStreak.integerValue = self.streakRecorder.valueForKey("longest") as! Int
    
    self.updateStreak()
    self.updateUI() // The two calls to this are kind of crappy. Refactor...
    self.updateTextStatus()
    self.updateMessage()
    self.saveData()
  }
  
  func isNewDay() -> Bool {
    var newDay = false
    
    let calendar = NSCalendar.currentCalendar()
    
    // Debug streaks (make everyday a new day):
//    let today:NSDate? = calendar.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: NSDate(), options: nil)
//    let current_date = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: today!)
    
    // Non debug
    let today = NSDate()
    let current_date = calendar.components([.Day, .Month], fromDate: today)

    let last_use = calendar.components([.Day, .Month], fromDate: self.streakRecorder.valueForKey("last_use") as! NSDate)
    
    // If both the day and the month are different, it's a new day.
    if (!(current_date.day == last_use.day && current_date.month == current_date.month)) {
      newDay = true
      // We only need to know it's a new day once right?
      self.streakRecorder.setValue(today, forKey: "last_use")
    }
    return newDay
  }
  
  func bothItemsTicked() -> Bool {
    var ticked = false
    let list1State = self.item1State.integerValue
    let list2State = self.item2State.integerValue
    if (list1State == 1 && list2State == 1) {
      ticked = true
    }
    return ticked
  }
  
  func clearLists() {
    self.listItem1.setValue("", forKey: "text")
    self.listItem1.setValue(0, forKey: "state")
    self.listItem2.setValue("", forKey: "text")
    self.listItem2.setValue(0, forKey: "state")
  }
  
  func loadListItems() {
    let managedContext = self.managedObjectContext
    let fetchRequest = NSFetchRequest(entityName:"ListItem")
    
    var error: NSError?
    
    do {
      let fetchedResults = try managedContext?.executeFetchRequest(fetchRequest)
      
      if let results = fetchedResults {
        if results.isEmpty {
          
          let entity =  NSEntityDescription.entityForName("ListItem",
            inManagedObjectContext:
            managedContext!)
          
          self.listItem1 = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
          
          self.listItem2 = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
          
          self.listItem1.setValue(1, forKey: "index")
          self.listItem1.setValue("", forKey: "text")
          self.listItem1.setValue(false, forKey: "state")
          
          self.listItem2.setValue(2, forKey: "index")
          self.listItem2.setValue("", forKey: "text")
          self.listItem2.setValue(false, forKey: "state")
          
          var error: NSError?
          do {
            try managedContext!.save()
          } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
          }
        }
        else {
          for result in results {
            let index = result.valueForKey("index") as! Int
            switch index {
            case 1:
              self.listItem1 = result as! NSManagedObject
            case 2:
              self.listItem2 = result as! NSManagedObject
            default:
              print("wrong index")
            }
          }
        }
      } else {
        print("Could not fetch \(error), \(error!.userInfo)")
      }
    } catch let error1 as NSError {
      error = error1
      print("Could not fetch results \(error), \(error?.userInfo)")
    }
  }
  
  func updateUI() {
    self.item1Text.stringValue = self.listItem1.valueForKey("text") as! String
    self.item1State.state = self.listItem1.valueForKey("state") as! Int
    
    self.item2Text.stringValue = self.listItem2.valueForKey("text") as! String
    self.item2State.state = self.listItem2.valueForKey("state") as! Int
  }
  
  func updateTextStatus() {
    self.item1Text.textColor = NSColor.whiteColor()
    self.item2Text.textColor = NSColor.whiteColor()
    
    if self.item1State.state == 1 {
      self.item1Box.fillColor = self.onColor
      self.item1Text.editable = false

      if self.item2State.state == 0 {
        self.item2Text.becomeFirstResponder()
      }
      self.item1Text.addStrikethrough()
    }
    else {
      self.item1Box.fillColor = self.offColor
      self.item1Text.editable = true
      self.item1Text.removeStrikethrough()
    }
    
    if self.item2State.state == 1 {
      self.item2Box.fillColor = self.onColor
      self.item2Text.editable = false
      if self.item1State.state == 0 {
        self.item1Text.becomeFirstResponder()
      }
      self.item2Text.addStrikethrough()
    }
    else {
      self.item2Box.fillColor = self.offColor
      self.item2Text.editable = true
      self.item2Text.removeStrikethrough()
    }
  }
    
  func loadStreakRecorder() {
    let managedContext = self.managedObjectContext
    
    let entity =  NSEntityDescription.entityForName("StreakRecorder",
        inManagedObjectContext:
        managedContext!)
    
    let fetchRequest = NSFetchRequest(entityName:"StreakRecorder")//returnsObjectsAsFaults:false
    
    var error: NSError?
    
    do {
      let fetchedResults = try managedContext?.executeFetchRequest(fetchRequest)
      
      if let results = fetchedResults {
        if results.isEmpty {
          // Initialise if empty
          self.streakRecorder = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
          
          self.streakRecorder.setValue(0, forKey: "current")
          self.streakRecorder.setValue(0, forKey: "longest")
          let current_date = NSDate()
          self.streakRecorder.setValue(current_date, forKey: "last_use");
          
          do {
            try managedContext!.save()
          } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
          }
        }
        else {
          // Load if not
          self.streakRecorder = results[0] as! NSManagedObject
          // Init UI.
          self.currentStreak.integerValue = self.streakRecorder.valueForKey("current") as! Int
          self.longestStreak.integerValue = self.streakRecorder.valueForKey("longest") as! Int
        }
      } else {
        print("Could not fetch \(error), \(error!.userInfo)")
      }
      
    } catch let error1 as NSError {
      error = error1
      print("Could not load results \(error), \(error?.userInfo)")
    }
  }
    
  func applicationWillTerminate(aNotification: NSNotification) {
    self.saveData()
  }
  
  // MARK: - Core Data stack

  var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "danlennox.twodo" in the user's Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
    let appSupportURL = urls[urls.count - 1]
    return appSupportURL.URLByAppendingPathComponent("TwoDo")
  }()

  var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("twodo", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    let fileManager = NSFileManager.defaultManager()
    var shouldFail = false
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."

    // Make sure the application files directory is there
    let propertiesOpt: [NSObject: AnyObject]?
    do {
      propertiesOpt = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
    } catch var error1 as NSError {
      error = error1
      propertiesOpt = nil
    } catch {
      fatalError()
    }
    if let properties = propertiesOpt {
      if !properties[NSURLIsDirectoryKey]!.boolValue {
        failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
        shouldFail = true
      }
    } else if error!.code == NSFileReadNoSuchFileError {
      error = nil
      do {
        try fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
      } catch var error1 as NSError {
        error = error1
      } catch {
        fatalError()
      }
    }
    
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator?
    if !shouldFail && (error == nil) {
      coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("twodo.storedata")
      do {
        try coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil)
      } catch var error1 as NSError {
        error = error1
        coordinator = nil
      } catch {
        fatalError()
      }
    }
    
    if shouldFail || (error != nil) {
      // Report any error we got.
      let dict = NSMutableDictionary()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      if error != nil {
        dict[NSUnderlyingErrorKey] = error
      }
      //error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dic as [NSObject : AnyObject])
      NSApplication.sharedApplication().presentError(error!)
      return nil
    } else {
      return coordinator
    }
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
  
  // MARK: - Core Data Saving and Undo support
  
  @IBAction func saveAction(sender: AnyObject!) {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if let moc = self.managedObjectContext {
      if !moc.commitEditing() {
        NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
      }
      var error: NSError? = nil
      if moc.hasChanges {
        do {
          try moc.save()
        } catch let error1 as NSError {
          error = error1
          NSApplication.sharedApplication().presentError(error!)
        }
      }
    }
  }

  func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    if let moc = self.managedObjectContext {
      return moc.undoManager
    } else {
      return nil
    }
  }
  
  func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
    // Save changes in the application's managed object context before the application terminates.
    if let moc = managedObjectContext {
      if !moc.commitEditing() {
        NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
        return .TerminateCancel
      }
      
      if !moc.hasChanges {
        return .TerminateNow
      }
      
      var error: NSError? = nil
      do {
        try moc.save()
      } catch let error1 as NSError {
        error = error1
        // Customize this code block to include application-specific recovery steps.
        let result = sender.presentError(error!)
        if (result) {
          return .TerminateCancel
        }
        
        let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
        let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
        let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
        let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = info
        alert.addButtonWithTitle(quitButton)
        alert.addButtonWithTitle(cancelButton)
        
        let answer = alert.runModal()
        if answer == NSAlertFirstButtonReturn {
          return .TerminateCancel
        }
      }
    }
    // If we got here, it is time to quit.}
    return .TerminateNow
  }
}