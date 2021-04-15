//
//  ViewController.swift: finalproject
//  EID: ws8653
//  Course: CS371L
//
//  Created by William on 7/9/20.
//  Copyright © 2020 Suh. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

//global variable for darkmode
struct DarkMode
{
    static var darkMode = false
}
//an event struct to hold all event's properties
struct Event: Equatable{
    var name  = ""
    var description  = ""
    var due  = ""
    var importance = 0
    var timeRequired = 0
    var splitable = false
    var done = 0
    var id = 1
    //initializes values
    init (name: String, description: String, due: String, importance: Int, timeRequired: Int, splitable: Bool )
    {
        self.name = name
        self.description  = description
        self.due = due
        self.importance = importance
        self.timeRequired = timeRequired
        self.splitable = splitable
    }
    //defining equivalence
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.name == rhs.name && lhs.description == rhs.description
        
    }
}
//an task struct that holds necessary properties
struct DateEvent: Equatable{
    var event:Event?
    var name = ""
    var date = ""
    var duration = 0
    static func ==(lhs: DateEvent, rhs: DateEvent) -> Bool {
        return lhs.name == rhs.name && lhs.date == rhs.date && lhs.event == rhs.event
    }
}
//protocol for updating/deleting/adding events
protocol EventManager
{
    func addEvent(event: Event)
    func updateCalendar(eventt: DateEvent)
    func deleteEvent(event: Event)
    func settings(dark: Bool, not: Bool, auto: Bool)
}

class ViewController: UIViewController, EventManager , UNUserNotificationCenterDelegate {
    
    
    var dirty = false
    var notification = true
    var autoSchedule = true

    
    var idCounter = 0;
    var selectedDate = ""

    var events:[Event] = []
    var dateEvents:[DateEvent] = []
    
    let calendarView: CalenderView = {
        let v=CalenderView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    //saves settings from settings page
    func settings(dark: Bool, not: Bool, auto: Bool) {
        DarkMode.darkMode = dark
        self.notification = not
        autoSchedule = auto
        storeSettings()
    }
    //deletes event and updates schedule
    func deleteEvent(event: Event) {
        let e = event
        if let index = events.firstIndex(of: e)
        {
            events.remove(at: index)
        }
        reschedule()
        clearCoreData()
        updateCoreDate()
    }
    //make changes to event and make
    func updateCalendar(eventt: DateEvent) {
        var e = eventt
        e.event!.done = e.duration
        let index2 = events.firstIndex(of: e.event!)
        events[index2!].done += e.duration
        if let index = dateEvents.firstIndex(of: e)
        {
            dateEvents.remove(at: index)
        }
        clearCoreData()
        updateCoreDate()
    }
    //compare function for due dates(used for sorting)
    func compareDueDates(event1: Event, event2: Event) ->Bool
    {
        let temp1 = event1.due.components(separatedBy: "/")
        let temp2 = event2.due.components(separatedBy: "/")
        
        if(Int(temp1[2])! != Int(temp2[2])!)
        {
            return Int(temp1[2])! > Int(temp2[2])!
        }
        else if (Int(temp1[1])! != Int(temp2[1])!)
        {
            return Int(temp1[1])! > Int(temp2[1])!
        }
        else if (Int(temp1[0])! != Int(temp2[0])!)
        {
            return Int(temp1[0])! > Int(temp2[0])!
        }
        return false
    }
    //add new event and reschedule
    func addEvent(event: Event) {
        var temp = event
        temp.id = idCounter
        idCounter += 1
        //add and sort event
        events.append(temp)
        events.sort(by: {
                if $0.importance != $1.importance { // first, compare by last names
                    return $0.importance > $1.importance
                }
                else if($0.due != $1.due )
                {
                    return compareDueDates(event1: $0, event2: $1)
                }
                else
                {
                    return true
                }
            })
        
        scheduleEvent(event: temp)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
               
        let e = NSEntityDescription.insertNewObject(forEntityName: "Eventt", into:context)
               
        // Set the attribute values
        e.setValue(event.name, forKey: "name")
        e.setValue(event.description, forKey: "descriptionn")
        e.setValue(event.due, forKey: "due")
        e.setValue(event.timeRequired, forKey: "timeRequired")
        e.setValue(event.splitable, forKey: "splitable")
        e.setValue(event.importance, forKey: "importance")
        e.setValue(event.done, forKey: "done")
        // Commit the changes
        do {
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    //schedule events
    func scheduleEvent(event: Event)
    {
        if(autoSchedule)
        {
            
            let date = Date()
            let today = Calendar.current
            let dateComponents = event.due.components(separatedBy: "/")
            var tr = event.timeRequired - event.done
            let components = today.dateComponents([.year, .month, .day], from: date)
            let numDays = calculateNumDays(year1: components.year!, month1: components.month!, day1: components.day!, year2: Int(dateComponents[2])!, month2: Int(dateComponents[1])!, day2: Int(dateComponents[0])!)
            var dayIndex  = 0
            var monthIndex  = 0
            var yearIndex = 0
            let factor = tr/numDays
            //if splitable split the work evenly among days
            if(event.splitable)
            {

                //loops until all work is evenly distributed
                while(tr > 0)
                {
                    var temp = DateEvent()
                    temp.name = event.name
                    temp.event = event
                    
                    temp.date = "\(components.day!+dayIndex)/\(components.month!+monthIndex)/\(components.year!+yearIndex)"
  
                    if(tr < factor)
                    {
                        temp.duration = tr
                        tr -= tr
                    }
                    else
                    {
                        temp.duration = factor
                        tr -= factor
                    }
                    dateEvents.append(temp)
                    //handle next month and next year
                    if(dayIndex+components.day! == 30 && components.month! != 2 && components.month! % 2 == 0)
                    {
                        dayIndex = -components.day!
                        monthIndex += 1
                    }
                    else if(dayIndex+components.day! == 28 && components.month! == 2)
                    {
                        dayIndex = -components.day!
                        monthIndex += 1
                    }
                    else if(dayIndex+components.day! == 31 && components.month! != 2 && components.month! % 2 == 1)
                    {
                        dayIndex = -components.day!
                        monthIndex += 1
                    }
                    if(monthIndex == 12)
                    {
                        monthIndex = 0
                        yearIndex += 1
                    }
                    dayIndex += 1
                }
            }
            else
            {
                let tr = event.timeRequired - event.done
                var temp = DateEvent()
                temp.name = event.name
                temp.event = event
                temp.date = event.due
                temp.duration = tr
                dateEvents.append(temp)
                           
            }
        }
    }
    func reschedule()
    {
        let date = Date()
        dateEvents.removeAll()
        let today = Calendar.current
        let components = today.dateComponents([.year, .month, .day], from: date)
        //loop through all the events
        for event in events
        {
            //if splitable split the work evenly among days
            if(event.splitable)
            {
                let dateComponents = event.due.components(separatedBy: "/")
                var tr = event.timeRequired - event.done
                let numDays = calculateNumDays(year1: components.year!, month1: components.month!, day1: components.day!, year2: Int(dateComponents[2])!, month2: Int(dateComponents[1])!, day2: Int(dateComponents[0])!)
                var dayIndex  = 0
                var monthIndex  = 0
                var yearIndex = 0
                let factor = tr/numDays
                //loops until all work is evenly distributed
                while(tr > 0)
                {
                    var temp = DateEvent()
                    temp.name = event.name
                    temp.event = event
                    temp.date = "\(components.day!+dayIndex)/\(components.month!)/\(components.year!)"
                    if(tr < factor)
                    {
                        temp.duration = tr
                        tr -= tr
                    }
                    else
                    {
                        temp.duration = factor
                        tr -= factor
                    }
                    dateEvents.append(temp)
                    //handle next month and next year
                    if(dayIndex+components.day! == 30 && components.month! != 2 && components.month! % 2 == 0)
                    {
                        dayIndex = -components.day!
                        monthIndex += 1
                    }
                    else if(dayIndex+components.day! == 28 && components.month! == 2)
                    {
                        dayIndex = -components.day!
                        monthIndex += 1
                    }
                    else if(dayIndex+components.day! == 31 && components.month! != 2 && components.month! % 2 == 1)
                    {
                        dayIndex = -components.day!
                        monthIndex += 1
                    }
                    if(monthIndex == 12)
                    {
                        monthIndex = 0
                        yearIndex += 1
                    }
                    dayIndex += 1
                }
            }
            else
            {
                let tr = event.timeRequired - event.done
                var temp = DateEvent()
                temp.name = event.name
                temp.event = event
                temp.date = event.due
                temp.duration = tr
                dateEvents.append(temp)
            }
        }
    }
    //function to format the dates
    func DateFormat() -> DateFormatter {
        let x = DateFormatter()
        x.dateFormat = "dd/MM/yyyy"
        x.timeZone = TimeZone(abbreviation: "GMT")
        return x
    }
    //function to convert seconds into days
    func secondsToDays (seconds : Int) -> (Int) {
        return (seconds / 86400)
    }
    //calculates number of days between two dates
    func calculateNumDays(year1 : Int, month1 : Int, day1: Int, year2 : Int, month2 : Int, day2: Int) -> Int
    {
        var dates: Date?
        var today: Date?
        dates = DateFormat().date(from: "\(day2)/\(month2)/\(year2)")
        today = DateFormat().date(from: "\(day1)/\(month1)/\(year1)")
        let timeInterval = -1 * (Int(exactly: (today?.timeIntervalSince(dates!))!) ?? 0)
        return secondsToDays(seconds: timeInterval)
    }
    //creates a new notification to remind user to update events
    func scheduleNotification() {
        //initialize components
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Update Events"
        content.body = "did you forget to update events?"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        //schedule for 12:00AM
        dateComponents.hour = 0
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self

        //calendar view settings
        calendarView.delegate = self
        self.title = "My Calender"
        self.navigationController?.navigationBar.isTranslucent=false
        self.view.backgroundColor=UIColor.white
        view.addSubview(calendarView)
        calendarView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive=true
        calendarView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive=true
        calendarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive=true
        calendarView.heightAnchor.constraint(equalToConstant: 300).isActive=true
        
        //retrieve data and update
        retrieveData()
        clearCoreData()
        updateCoreDate()
        retrieveSettings()
        if(notification)
        {
            scheduleNotification()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //theme settings
        if(DarkMode.darkMode)
        {
            self.view.backgroundColor=UIColor.darkGray
            navigationController?.navigationBar.barTintColor = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.gray]
        }
        else
        {
            self.view.backgroundColor=UIColor.white
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        }
        //if notification is turned off
        if(!notification)
        {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
        }
        else
        {
            let center = UNUserNotificationCenter.current()
            var temp = 0
            center.getPendingNotificationRequests(completionHandler: { requests in
                for _ in requests {
                    temp += 1
                    break;
                }
            })
            if(temp==0)
            {
                scheduleNotification()
            }
        }
        //checks if auto schedule is turned on and if rescheduling is required
        if(autoSchedule)
        {
            if(dirty)
            {
                reschedule()
            }
            dirty = false
        }
        else
        {
            //if auto schedule is turned off wipe dateEvents
            dateEvents.removeAll()
            for event in events
            {
                var temp = DateEvent()
                temp.name = event.name
                temp.event = event
                temp.date = event.due
                temp.duration = event.timeRequired - event.done
                dateEvents.append(temp)
            }
            dirty = true
        }
        calendarView.reload()
    }
    //for calendar layout
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        calendarView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    //function that save settings
    func storeSettings()
    {
        //clear previous settings
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        var fetchedResults: [NSManagedObject]
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            if fetchedResults.count > 0 {
                
                for result:AnyObject in fetchedResults {
                    context.delete(result as! NSManagedObject)
                }
            }
            try context.save()
        } catch {
            // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        //save current settingss
        let e = NSEntityDescription.insertNewObject(forEntityName: "Settings", into:context)
        e.setValue(DarkMode.darkMode, forKey: "darkMode")
        e.setValue(notification, forKey: "notification")
        e.setValue(autoSchedule, forKey: "autoSchedule")
        do {
            try context.save()
        } catch {
                       // if an error occurs
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    //function for updating the coreData
    func updateCoreDate()
    {
        //loop through event
        for event in events
        {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let e = NSEntityDescription.insertNewObject(forEntityName: "Eventt", into:context)
            //set values
            e.setValue(event.name, forKey: "name")
            e.setValue(event.description, forKey: "descriptionn")
            e.setValue(event.due, forKey: "due")
            e.setValue(event.timeRequired, forKey: "timeRequired")
            e.setValue(event.splitable, forKey: "splitable")
            e.setValue(event.importance, forKey: "importance")
            e.setValue(event.done, forKey: "done")
            do {
                try context.save()
            } catch {
                // if an error occurs
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    //function that retrieves settings
    func retrieveSettings()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
                
        var fetchedResults: [NSManagedObject]? = nil

        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        DarkMode.darkMode =  true
        notification = true
        autoSchedule = true
        //loop through the fetched result (there should only be at most 1 element at a time)
        for event in fetchedResults!
        {
            if let dm = event.value(forKey:"darkMode")
            {
                if let notif = event.value(forKey:"notification")
                {
                    if let auto = event.value(forKey:"autoSchedule")
                    {
                        DarkMode.darkMode = dm as? Bool ?? true
                        notification = notif as? Bool ?? true
                        autoSchedule = auto as? Bool ?? true
                    }
                }
            }
        }
    }
    //function for retrieving data from coredata
    func retrieveData()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Eventt")
                
        var fetchedResults: [NSManagedObject]? = nil
                
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        //loop through the fetched result and add to the events array
        for event in fetchedResults!
        {
            if let eventName = event.value(forKey:"name") {
                if let eventDue = event.value(forKey:"due") {
                    if let eventImportance = event.value(forKey:"importance") {
                        if let eventSplitable = event.value(forKey:"splitable") {
                            if let eventDescription = event.value(forKey:"descriptionn") {
                                if let eventTimeRequired = event.value(forKey:"timeRequired") {
                                    if let eventDone = event.value(forKey:"done")
                                    {
                                        var temp =  Event(name: eventName as! String, description: eventDescription as! String, due: eventDue as! String, importance: eventImportance as! Int, timeRequired: eventTimeRequired as! Int, splitable: eventSplitable as! Bool)
                                        temp.done = eventDone as! Int
                                        addEvent(event: temp)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    //function for clearing core data
    func clearCoreData() {
         let appDelegate = UIApplication.shared.delegate as! AppDelegate
         let context = appDelegate.persistentContainer.viewContext
         let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Eventt")
         var fetchedResults: [NSManagedObject]
         do {
             try fetchedResults = context.fetch(request) as! [NSManagedObject]
             if fetchedResults.count > 0 {
                 
                 for result:AnyObject in fetchedResults {
                     context.delete(result as! NSManagedObject)
                     print("\(result.value(forKey:"name")!) has been deleted")
                 }
             }
             try context.save()
         } catch {
             // if an error occurs
             let nserror = error as NSError
             NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
             abort()
         }
     }
    
    //function for preparing segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //checks segue identifer and next view controller's class
        if segue.identifier == "seg1",
            let nextVC = segue.destination as? EventAddViewController
        {
            nextVC.delegate = self
            nextVC.editMode = false
        }
        if segue.identifier == "seg3",
            let nextVC = segue.destination as? DayViewController
        {
            nextVC.events = dateEvents
            nextVC.date = selectedDate
            nextVC.delegate = self
        }
        if segue.identifier == "seg4",
            let nextVC = segue.destination as? ViewAllEventsViewController
        {
            nextVC.events = events
            nextVC.delegate = self
        }
        if segue.identifier == "seg2",
            let nextVC = segue.destination as? SettingViewController
        {
            nextVC.delegate = self
        }
    }
}


