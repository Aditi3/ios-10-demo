
import UserNotifications
import SharedManager
import CleverTapAppEx

@available(iOSApplicationExtension 10.0, *)@available(iOSApplicationExtension 10.0, *)
class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    private lazy var cleverTap: CleverTap = CleverTap.sharedInstance()
    
    private lazy var sharedManager: SharedManager = {
        return SharedManager(forAppGroup: "group.com.clevertap.demo10")
    }()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        CleverTap.setDebugLevel(1)
        if let userId = sharedManager.userId {
           cleverTap.onUserLogin(["Identity":userId])
        }
        
        if let bestAttemptContent = bestAttemptContent {
            
            // demo: store the push payload data for use by the main app
            sharedManager.persistLastPushNotification(withContent: bestAttemptContent)
            
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
            
            sharedManager.createNotificationAttachment(forMediaType: mediaType, withUrl: url, completionHandler: { attachment in
                if let attachment = attachment {
                    bestAttemptContent.attachments = [attachment]
                    self.cleverTap.recordEvent("NotificationAddAttachment", withProps: ["type": mediaType.rawValue, "url":url])
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
