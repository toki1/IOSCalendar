//
//  EventAddViewController: finalproject
//  EID: ws8653
//  Course: CS371L
//
//  Created by William on 7/9/20.
//  Copyright © 2020 Suh. All rights reserved.
//

import UIKit

class EventAddViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var descript: UITextView!
    @IBOutlet weak var dueDate: UITextField!
    @IBOutlet weak var importance: UISegmentedControl!
    @IBOutlet weak var timeRequired: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var splitable: UISwitch!
    
    var datePicker: UIDatePicker?
    var delegate: UIViewController!
    var event: Event?
    var editMode:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        dueDate.inputView = datePicker
        let tapGesure = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gestureRecognizer:)))
        //if in edit mode load event info and change some text
        if(editMode!)
        {
            let eve = event!
            timeRequired.text = String(eve.timeRequired)
            dueDate.text = eve.due
            importance.selectedSegmentIndex = eve.importance
            descript.text = eve.description
            name.text = eve.name
            splitable.setOn(eve.splitable, animated: false)
            button.setTitle("Save", for: .normal)
            self.title = "Edit Event"
        }
        else
        {
            self.title = "Create Event"
        }
        view.addGestureRecognizer(tapGesure)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //set theme of the view
        if(DarkMode.darkMode)
        {
            self.view.backgroundColor = UIColor.darkGray
            descript.backgroundColor = UIColor.gray
            dueDate.backgroundColor = UIColor.gray
            importance.backgroundColor = UIColor.gray
            name.backgroundColor = UIColor.gray
            dueDate.backgroundColor = UIColor.gray
            timeRequired.backgroundColor = UIColor.gray
            importance.selectedSegmentTintColor = UIColor.lightGray
        }
        else
        {
            self.view.backgroundColor = UIColor.white
            descript.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
            dueDate.backgroundColor = UIColor.white
            importance.backgroundColor = UIColor.lightGray
            name.backgroundColor = UIColor.white
            dueDate.backgroundColor = UIColor.white
            timeRequired.backgroundColor = UIColor.white
            importance.selectedSegmentTintColor = UIColor.white
        }
    }
    //get rid of popover and keyboard
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)

    }
    //set text from date picker
    @objc func dateChanged(datePicker:UIDatePicker)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M/yyyy"
        dueDate.text = dateFormatter.string(from: datePicker.date)
    }
    //create new event or update event
    @IBAction func saveEventButton(_ sender: Any)
    {
        if(editMode!)
        {
            let eventManager = delegate as! EventManager
            var temp = event!
            temp.description = descript.text
            temp.due = dueDate.text!
            temp.name = name.text!
            temp.splitable = splitable.isOn
            temp.importance  = importance.selectedSegmentIndex + 1
            temp.timeRequired = Int(timeRequired.text!)!

            eventManager.deleteEvent(event: temp)
            eventManager.addEvent(event: temp)
        }
        else
        {
            var newEvent = Event(name: name.text!, description: descript.text!, due: dueDate.text!, importance: Int(importance.selectedSegmentIndex)+1, timeRequired: Int(timeRequired.text!)!, splitable: splitable.isOn)
            let eventManager = delegate as! EventManager
            newEvent.importance = Int(importance.selectedSegmentIndex)
            eventManager.addEvent(event: newEvent)
        }

    }
     

}
