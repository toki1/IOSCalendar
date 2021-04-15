//
//  ViewAllEventsViewController.swift: finalproject
//  EID: ws8653
//  Course: CS371L
//
//  Created by William on 7/9/20.
//  Copyright © 2020 Suh. All rights reserved.
//

import UIKit

class CustomCell2: UITableViewCell
{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var due: UILabel!
    @IBOutlet weak var progress: UIProgressView!
}

class ViewAllEventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var eventTable: UITableView!
    
    var delegate: UIViewController!
    var events:[Event] = []
    var selectedEvent:Event?
    
    //table view function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    //table view function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell2", for: indexPath) as! CustomCell2
        let event = events[indexPath.item]
        cell.name.text = event.name
        cell.due.text = event.due
        let percentDone = Float(event.done)/Float(event.timeRequired)
        cell.progress.setProgress(percentDone, animated: true)
        cell.textLabel?.numberOfLines=3
        if(DarkMode.darkMode)
        {
            cell.backgroundColor = UIColor.lightGray
        }
        else
        {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
     

    //table view function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "seg5", sender: Any?.self)
    }
    //table view function
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = events[indexPath.row]
            events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let eventManager = delegate as! EventManager
            eventManager.deleteEvent(event: event)
            eventTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTable.delegate = self
        eventTable.dataSource = self
        self.title = "Events"
    }
    override func viewWillAppear(_ animated: Bool)
    {
        //set theme
        if(DarkMode.darkMode)
        {
            self.view.backgroundColor = UIColor.darkGray
            eventTable.backgroundColor = UIColor.darkGray
            eventTable.separatorColor = UIColor.black
        }
        else
        {
            self.view.backgroundColor = UIColor.white
            eventTable.backgroundColor = UIColor.white
            eventTable.separatorColor = UIColor.lightGray
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "seg5",
            let nextVC = segue.destination as? EventAddViewController
        {
            nextVC.editMode = true
            nextVC.event = selectedEvent
            nextVC.delegate = delegate
        }
    }
   
}

