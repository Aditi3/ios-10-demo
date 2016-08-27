//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by pwilkniss on 8/16/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import SharedManager

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    let appGroupName: String = "group.com.clevertap.demo10"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CleverTap.setDebugLevel(1277182231)
        let sharedManager = SharedManager(forAppGroup: appGroupName)
        if let userId = sharedManager.userId {
            CleverTap.sharedInstance().onUserLogin(["Identity":userId])
        }
        
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }

}
