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
class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate
{
  //  @IBOutlet var window: NSWindow!
  
  
    @IBOutlet weak var currentApp: NSApplication!
  
    @IBOutlet weak var detachWindow: NSWindow!
  
    @IBOutlet var popover : NSPopover!
  
    @IBOutlet weak var PopUpViewController: NSViewController!
  
    let icon: IconView;
    
    @IBOutlet weak var item1State: NSButton!
    @IBOutlet weak var item1Text: CustomTextField!
    @IBOutlet weak var item2State: NSButton!
    @IBOutlet weak var item2Text: CustomTextField!
    @IBOutlet weak var item1Box: NSBox!
    @IBOutlet weak var item2Box: NSBox!
  
  
    @IBOutlet weak var currentStreak: NSTextField!
    @IBOutlet weak var longestStreak: NSTextField!
  
    // Todo: new "list item" class that extents 
    // NSManagedObject - Can then extend with setAppearanceTicked, setAppearanceUnticked etc.
    // Check how this all fits in with writing solid MVC apps though, might be the wrong way
    // to do this.
    var listItem1: NSManagedObject!
    var listItem2: NSManagedObject!
    var streakRecorder: NSManagedObject!
  
    var onColor: NSColor!
    var offColor: NSColor!
  
    @IBOutlet weak var heading: NSTextField!
    
    enum State {
      case recordAlmostMatched
      case RecordMatched
      case RecordBeaten
      case NewDay
      case NewDay5Plus
      case OneTicked
      case TwoTicked
    }
  
  var listState: State
  
  var yesterdays_current_streak: Int

  @IBAction func item1Enter(sender: CustomTextField) {
    sender.resignFirstResponder()
    item2Text.becomeFirstResponder()
  }
  
  
  func saveData() {
    let managedContext = self.managedObjectContext!
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
    
    println("Data saved")
    
    if !managedContext.save(&error) {
      println("Could not save \(error), \(error?.userInfo)")
    }
  }
  
  @IBAction func textChecked(sender: NSButton) {
    var color = NSColor.whiteColor()
    
    if sender.state == 1 {
      color = NSColor.redColor()
      if (self.bothItemsTicked()) {
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
          if self.longestStreak.integerValue > self.streakRecorder.valueForKey("longest") as Int {
            self.longestStreak.integerValue--
          }
        }
      }
      
    }
    self.updateTextStatus()
  }
  
  override init()
  {
      let bar = NSStatusBar.systemStatusBar();
      let length: CGFloat = -1
      let item = bar.statusItemWithLength(length);
    
      self.listState = State.NewDay
      self.yesterdays_current_streak = 0
      
      self.icon = IconView(imageName: "icon", item: item);
      item.view = icon;
  
    
    
    
      super.init();
    
      self.initColors()
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
  
  func applicationDidFinishLaunching(aNotification: NSNotification?)
  {
    // Insert code here to initialize your application
    self.loadListItems()
    self.loadStreakRecorder()
    
    
    
    self.updateUI()
    
    // Store yesterdays current streak.
    self.yesterdays_current_streak = self.streakRecorder.valueForKey("current") as Int

    self.currentStreak.integerValue = self.yesterdays_current_streak
    self.longestStreak.integerValue = self.streakRecorder.valueForKey("longest") as Int
    
    
    self.updateStreak()
    self.updateUI() // The two calls to this are kind of crappy. Refactor.. 
    self.updateTextStatus()
    
    self.setState()
    
    self.item1Text.highlighted = false
    

    
  }
  
  func popoverShouldClose(popover: NSPopover) -> Bool {
    println("CALLED THE MAGIC")
    return true;
  }
  
  func detachableWindowForPopover(popover: NSPopover) -> NSWindow? {
    return detachWindow
  }
  
  
  func setState() {
    // No inputs (update style function).
    // Simply looks at the few vars and sets the state based on criteria.
    
    // Sets some application state based on the arrangement of items.
    
    // Messages are then displayed based on state.
  }
    
  func applicationDidBecomeActive(notification: NSNotification) {
      //self.updateUI()
    //self.popover?.open()
    println("became active")
  }
  
  func applicationDidResignActive(notification: NSNotification) {
    println("resigned active")
    // Save our data when the user clicks out of the app.
    self.updateStreak()
      //self.saveData()
    self.saveData()
    
//    self.item1Text.becomeFirstResponder()
    self.icon.isSelected = !self.icon.isSelected
    self.icon.needsDisplay = false
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
  
  func isNewDay() -> Bool {
    var newDay = false
    
    let calendar = NSCalendar.currentCalendar()
    
    // Debug streaks (make everyday a new day):
//    let today:NSDate? = calendar.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: NSDate(), options: nil)
//    let current_date = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: today!)
    
    // Non debug
    let today = NSDate()
    let current_date = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: today)

    let last_use = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: self.streakRecorder.valueForKey("last_use") as NSDate)
    
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
    let managedContext = self.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName:"ListItem")
    
    var error: NSError?
    
    let fetchedResults =
    managedContext.executeFetchRequest(fetchRequest,
        error: &error) as [NSManagedObject]?
    
    if let results = fetchedResults {
      if results.isEmpty {
        
        let entity =  NSEntityDescription.entityForName("ListItem",
            inManagedObjectContext:
            managedContext)
        
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
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
      }
      else {
          for result in results {
              var index = result.valueForKey("index") as Int
              switch index {
              case 1:
                  self.listItem1 = result
              case 2:
                  self.listItem2 = result
              default:
                  println("wrong index")
              }
          }
      }
    } else {
      println("Could not fetch \(error), \(error!.userInfo)")
    }
  }
  
  func updateUI() {
    self.item1Text.stringValue = self.listItem1.valueForKey("text") as String
    self.item1State.state = self.listItem1.valueForKey("state") as Int
    
    self.item2Text.stringValue = self.listItem2.valueForKey("text") as String
    self.item2State.state = self.listItem2.valueForKey("state") as Int

    
    
    //self.currentStreak.integerValue = self.streakRecorder.valueForKey("current") as Int
    //self.longestStreak.integerValue = self.streakRecorder.valueForKey("longest") as Int
  }
  
  func updateTextStatus() {
    if self.item1State.state == 1 {
      self.item1Box.fillColor = self.onColor
      self.item1Text.editable = false
      self.item2Text.becomeFirstResponder()
      self.item1Text.addStrikethrough()
    }
    else {
      self.item1Text.removeStrikethrough()
      self.item1Box.fillColor = self.offColor
      self.item1Text.editable = true
    }
    
    if self.item2State.state == 1 {
      self.item2Box.fillColor = self.onColor
      self.item2Text.editable = false
      self.item1Text.becomeFirstResponder()
      self.item2Text.addStrikethrough()
    }
    else {
      self.item2Box.fillColor = self.offColor
      self.item2Text.editable = true
      self.item2Text.removeStrikethrough()
    }
  }
    
  func loadStreakRecorder() {
    let managedContext = self.managedObjectContext!
    
    let entity =  NSEntityDescription.entityForName("StreakRecorder",
        inManagedObjectContext:
        managedContext)
    
    let fetchRequest = NSFetchRequest(entityName:"StreakRecorder")//returnsObjectsAsFaults:false
    
    var error: NSError?
    
    let fetchedResults =
    managedContext.executeFetchRequest(fetchRequest,
        error: &error) as [NSManagedObject]?
    
    if let results = fetchedResults {
      if results.isEmpty {
        // Initialise if empty
        self.streakRecorder = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        self.streakRecorder.setValue(0, forKey: "current")
        self.streakRecorder.setValue(0, forKey: "longest")
        let current_date = NSDate()
        self.streakRecorder.setValue(current_date, forKey: "last_use");

        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
      }
      else {
        // Load if not
        self.streakRecorder = results[0]
        // Init UI.
        self.currentStreak.integerValue = self.streakRecorder.valueForKey("current") as Int
        self.longestStreak.integerValue = self.streakRecorder.valueForKey("longest") as Int
      }
    } else {
        println("Could not fetch \(error), \(error!.userInfo)")
    }
  }
    
  func applicationWillTerminate(aNotification: NSNotification?)
  {
    // Insert code here to tear down your application
    // This is only called when the user actually quits.
    println("tear down")
    self.saveData()
  }
  
  override func awakeFromNib()
  {
    let edge = NSMinYEdge
    let icon = self.icon
    var rect = icon.frame
    
    println("awake")
    icon.onMouseDown = {
      println("CALLED MOUSE DOWWWWN")
      if (icon.isSelected) {
        println("IS SELECTED")

        
        
        self.popover?.showRelativeToRect(rect, ofView: icon, preferredEdge: edge);
        
        self.PopUpViewController.view.needsDisplay = true
        
        self.currentApp.activateIgnoringOtherApps(true)
        
        self.item1Text.becomeFirstResponder()
//        PopUpViewController.
     
      }
      else {
        self.popover?.close()
      }

    }
  }
  
  
  
    // MARK: - Core Data stack
  
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "danlennox.twodo" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        return appSupportURL.URLByAppendingPathComponent("danlennox.twodo")
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
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
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("twodo.storedata")
            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                coordinator = nil
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
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
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
            if moc.hasChanges && !moc.save(&error) {
                NSApplication.sharedApplication().presentError(error!)
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
            if !moc.save(&error) {
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
        // If we got here, it is time to quit.
        return .TerminateNow
    }

  
    
}


class MenuDelegate: NSObject, NSMenuDelegate {
  func menuWillOpen(menu: NSMenu) {
      println("menu delegate working")
  }
}












