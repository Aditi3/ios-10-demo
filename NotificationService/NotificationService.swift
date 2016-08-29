//
//  NotificationService.swift
//  NotificationService
//
//  Created by pwilkniss on 8/16/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UserNotifications
import SharedManager


fileprivate extension UNNotificationContent {
    func toDict() -> [String : String] {
        var dict = [String:String]()
        dict["title"] = self.title
        dict["subtitle"] = self.subtitle
        dict["body"] = self.body
        for item in self.userInfo {
            let key = "\(item.key)", value = "\(item.value)"
            if (key != "aps") {
                dict[key] = value
            }
        }
        return dict
    }
}

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let appGroupName: String = "group.com.clevertap.demo10"

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        CleverTap.setDebugLevel(1277182231)
        var sharedManager = SharedManager(forAppGroup: appGroupName)
        if let userId = sharedManager.userId {
            CleverTap.sharedInstance().onUserLogin(["Identity":userId])
        }
        
        if let bestAttemptContent = bestAttemptContent {
            
            // Modify the notification content here...
            let modifiedTitle = "\(bestAttemptContent.title) [modified]"
            bestAttemptContent.title = modifiedTitle
            
            let userInfo = bestAttemptContent.userInfo
            // check for a media attachment
            guard
                let url = userInfo["mediaUrl"] as? String,
                let _mediaType = userInfo["mediaType"] as? String,
                let mediaType = MediaType(rawValue:_mediaType)
                else {
                    contentHandler(bestAttemptContent)
                    return
                }

            // store the push payload data for use by the main app
            sharedManager.lastPushNotification = bestAttemptContent.toDict()
            
            sharedManager.createNotificationAttachment(forMediaType: mediaType, withUrl: url, completionHandler: { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                    CleverTap.sharedInstance().recordEvent("NotificationAddAttachment", withProps: ["type": mediaType.rawValue, "url":url])
                }
                contentHandler(bestAttemptContent)
            })
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified - time out]"
            contentHandler(bestAttemptContent)
        }
    }
}
