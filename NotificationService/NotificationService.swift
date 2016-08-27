//
//  NotificationService.swift
//  NotificationService
//
//  Created by pwilkniss on 8/16/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UserNotifications
import SharedManager


class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let appGroupName: String = "group.com.clevertap.demo10"

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        CleverTap.setDebugLevel(1277182231)
        let sharedManager = SharedManager(forAppGroup: appGroupName)
        if let userId = sharedManager.userId {
            CleverTap.sharedInstance().onUserLogin(["Identity":userId])
        }
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            // check for a media attachment
            let userInfo = bestAttemptContent.userInfo
            guard
                let url = userInfo["mediaUrl"] as? String,
                let _mediaType = userInfo["mediaType"] as? String,
                let mediaType = MediaType(rawValue:_mediaType)
                else {
                    contentHandler(bestAttemptContent)
                    return
                }
            
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
