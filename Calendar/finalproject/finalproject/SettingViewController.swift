//
//  SettingViewController.swift: finalproject
//  EID: ws8653
//  Course: CS371L
//
//  Created by William on 7/9/20.
//  Copyright © 2020 Suh. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {


    @IBOutlet weak var darkMode: UISwitch!
    
    @IBOutlet weak var notification: UISwitch!
    
    @IBOutlet weak var autoSchedule: UISwitch!
    
    @IBOutlet weak var dmLabel: UILabel!
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    @IBOutlet weak var asLabel: UILabel!
    
    var delegate: UIViewController!
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = delegate as! ViewController
        darkMode.setOn(DarkMode.darkMode, animated: false)
        notification.setOn(vc.notification, animated: false)
        autoSchedule.setOn(vc.autoSchedule, animated: false)
        self.title = "Settings"
    }
    override func viewWillAppear(_ animated: Bool) {
        //set theme
        if(DarkMode.darkMode)
        {
            self.view.backgroundColor = UIColor.darkGray
        }
        else
        {
            self.view.backgroundColor = UIColor.white
        }
    }
    //button to save settings
    @IBAction func saveSettings(_ sender: Any) {
        let eventManager = delegate as! EventManager
        eventManager.settings(dark: darkMode.isOn, not: notification.isOn, auto:  autoSchedule.isOn)
    }
}
