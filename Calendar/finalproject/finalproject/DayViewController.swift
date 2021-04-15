//
//  DayViewController.swift: finalproject
//  EID: ws8653
//  Course: CS371L
//
//  Created by William on 7/9/20.
//  Copyright © 2020 Suh. All rights reserved.
//

import UIKit
class CustomCell: UITableViewCell
{
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var duration: UILabel!
}

class DayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var eventss: UITableView!
    
    var delegate: UIViewController!
    var events:[DateEvent] = []
    var thisDayEvents:[DateEvent] = []
    var date:String = ""
    //table view function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return thisDayEvents.count
    }
    //table view function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! CustomCell
        let temp = thisDayEvents[indexPath.item]
        cell.eventName.text = temp.name
        cell.duration.text = String(temp.duration)
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = thisDayEvents[indexPath.row]
            thisDayEvents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            let eventManager = delegate as! EventManager
            eventManager.updateCalendar(eventt: event)
            eventss.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        eventss.delegate = self
        eventss.dataSource = self
        //get all events related to this day
        for event in events
        {
            if(event.date == date)
            {
                thisDayEvents.append(event)
            }
        }
        self.title = "Day View"

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //set theme
        if(DarkMode.darkMode)
        {
            self.view.backgroundColor = UIColor.darkGray
            eventss.backgroundColor = UIColor.darkGray
            eventss.separatorColor = UIColor.black
        }
        else
        {
            self.view.backgroundColor = UIColor.white
            eventss.backgroundColor = UIColor.white
            eventss.separatorColor = UIColor.lightGray
        }
    }
}
