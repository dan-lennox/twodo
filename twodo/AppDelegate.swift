//
//  AppDelegate.swift
//  twodo
//
//  Created by Daniel Lennox on 17/01/2015.
//  Copyright (c) 2015 danlennoxconsulting. All rights reserved.
//

import Cocoa
import CoreData


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
  //  @IBOutlet var window: NSWindow!
    
    @IBOutlet var popover : NSPopover!
    
    let icon: IconView;
    
    @IBOutlet weak var item1State: NSButton!
    @IBOutlet weak var item1Text: NSTextField!
    @IBOutlet weak var item2State: NSButton!
    @IBOutlet weak var item2Text: NSTextField!
    @IBOutlet weak var save: NSButton!

    
    @IBOutlet weak var currentStreak: NSTextField!
    @IBOutlet weak var longestStreak: NSTextField!
  
    // Todo: new "list item" class that extents 
    // NSManagedObject - Can then extend with setAppearanceTicked, setAppearanceUnticked etc.
    // Check how this all fits in with writing solid MVC apps though, might be the wrong way
    // to do this.
    var listItem1: NSManagedObject!
    var listItem2: NSManagedObject!
    var streakRecorder: NSManagedObject!
    
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
    var color = NSColor.blackColor()
    
    if sender.state == 1 {
      color = NSColor.grayColor()
      self.updateStreak()
    }
    else {
        // An item has been unchecked.
        // if the OTHER checkbox is still ticked - not sure how to do this.
        // Then we know both were ticked previously,
        // We need to take back the increase to the streak! As the user has 'undone' a task.
        // - Decrement the current streak and longest (if current > longest).
      
        // We can update the streak current and longest UI
        // but lets only allow actual saving of the streak data if its a new day.
        // Then we can do this here
      
        // if UI current > stored current
        // AND we've unticked something.
        // then decrement the current.
      
      var other: NSButton
      
      if sender.identifier == "item1" {
        other = self.item2State
      }
      else {
        other = self.item1State
      }
      
      if other.state == 1 {
        
        // Issue:
        // Before we decrement we need to know what 0 is. If the current streak
        // is 2, we don't want to decrement down to 1. We only want to decrement down
        // from 3.
        
        println("debug decrements")
        println(self.currentStreak.integerValue)
        println(self.yesterdays_current_streak)
        if self.currentStreak.integerValue >= self.yesterdays_current_streak {
          println("current streak")
          println(self.currentStreak.integerValue)
          println("yesterdays streak")
          println(self.yesterdays_current_streak)
          self.currentStreak.integerValue--
          if self.longestStreak.integerValue > self.streakRecorder.valueForKey("longest") as Int {
            self.longestStreak.integerValue--
          }
        }
      }
      
    }
    if sender.identifier == "item1" {
        self.item1Text.textColor = color
    }
    else {
        self.item2Text.textColor = color
    }
    
//    self.saveData()
  }
  
  override init()
  {
      let bar = NSStatusBar.systemStatusBar();
      
      let item = bar.statusItemWithLength(-1);
    
      self.listState = State.NewDay
    
      self.yesterdays_current_streak = 0
    
      println("called init")
      
      self.icon = IconView(imageName: "icon", item: item);
      item.view = icon;

      super.init();
  }
  

  
  func applicationDidFinishLaunching(aNotification: NSNotification?)
  {
    // Insert code here to initialize your application
    self.loadListItems()
    self.loadStreakRecorder()
    
//    // Color fixes
//    let color = NSColor.blueColor()
//    let placeholder = (self.item1Text.cell() as NSTextFieldCell).attributedStringValue
//    placeholder.setValue(color, forKey: NSForegroundColorAttributeName)
////    let attrs = [NSForegroundColorAttributeName: color, NSFontSizeAttribute: 50.0, NSFontFamilyAttribute: "Comic Sans"]
////    let text: String = (self.item1Text.cell() as NSTextFieldCell).placeholderString!
////    let placeholder: NSAttributedString = NSAttributedString(string: text, attributes: attrs)
//
//    (self.item1Text.cell() as NSTextFieldCell).placeholderAttributedString = placeholder
    
    self.updateUI()
    
    // Store yesterdays current streak.
    self.yesterdays_current_streak = self.streakRecorder.valueForKey("current") as Int
    println("yesterday on init")
    println(self.yesterdays_current_streak)
    self.currentStreak.integerValue = self.yesterdays_current_streak
    self.longestStreak.integerValue = self.streakRecorder.valueForKey("longest") as Int
    
    
    self.updateStreak()
    self.updateUI() // The two calls to this are kind of crappy. Refactor..
    
    
    self.setState()
  }
  
  func setState() {
    // No inputs (update style function).
    // Simply looks at the few vars and sets the state based on criteria.
  }
    
  func applicationDidBecomeActive(notification: NSNotification) {
      //self.updateUI()
  }
  
  func applicationDidResignActive(notification: NSNotification) {
      // Save our data when the user clicks out of the app.
      //self.updateStreak()
      //self.saveData()
    self.saveData()
  }
    
  func updateStreak() {
    
    if (self.bothItemsTicked()) {
  
      // Increment streak
      println("increment streak")
      
      // Lets only save the streak data if it's a new day.
      if self.isNewDay() {
        println("new day")
        self.streakRecorder.setValue(self.currentStreak.integerValue, forKey: "current")
        self.streakRecorder.setValue(self.longestStreak.integerValue, forKey: "longest")
        self.clearLists()
      }
      else {
        println("gotohere")
        // As soon as both items re ticked, we just update the UI for the user
        // to see
        self.currentStreak.integerValue = self.currentStreak.integerValue + 1
        if self.currentStreak.integerValue > self.longestStreak.integerValue {
          // Check if we've beaten our longest ever streak.
          self.longestStreak.integerValue = self.currentStreak.integerValue
        }
      }
      
      
    }
    else if self.isNewDay() {
      println("tried to decrement streak")
      // The streak is broken and it's a new day, reset the streak.
      self.currentStreak.integerValue = 0
      self.streakRecorder.setValue(0, forKey: "current")
      // If it's a new day, streak or no streak, we clear the lists.
      self.clearLists()
      println("reset streak")
    }
    
    //self.saveData()
    println("called update streak")
  }
  
  func isNewDay() -> Bool {
    var newDay = false
    
    let calendar = NSCalendar.currentCalendar()
    
    // Debug streaks (make everyday a new day):
    //let today:NSDate? = calendar.dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: NSDate(), options: nil)
    //let current_date = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: today!)
    
    // Non debug
    let today = NSDate()
    let current_date = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: today)

    let last_use = calendar.components(.CalendarUnitDay | .CalendarUnitMonth, fromDate: self.streakRecorder.valueForKey("last_use") as NSDate)
    
    // If both the day and the month are different, it's a new day.
    if (!(current_date.day == last_use.day && current_date.month == current_date.month)) {
      newDay = true
    }
    // We only need to know it's a new day once right?
    self.streakRecorder.setValue(today, forKey: "last_use")
    return newDay
  }
  
  func bothItemsTicked() -> Bool {
    var ticked = false
    let list1State = self.item1State.integerValue
    let list2State = self.item2State.integerValue
    println("items ticked")
    println(list1State)
    println(list2State)
    if (list1State == 1 && list2State == 1) {
      ticked = true
    }
    return ticked
  }
  
    
  func clearLists() {
    println("cleared lists")
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
    //NSRectEdge is not enumerated yet; NSMinYEdge == 1
    //@see NSGeometry.h
    let edge = 1
    let icon = self.icon
    let rect = icon.frame
    
    icon.onMouseDown = {
      if (icon.isSelected)
      {
        self.popover.showRelativeToRect(rect, ofView: icon, preferredEdge: edge);
        return
      }
      self.popover.close()
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















