//
//  NotificationService.swift
//  NotificationService
//
//  Created by pwilkniss on 8/16/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UserNotifications

fileprivate enum MediaType: String {
    case image = "image"
    case video = "video"
    case audio = "audio"
    
    static func attachmentOptions(forType type: MediaType) -> [String: Any?] {
        switch(type) {
        case .image:
            return [UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.50).dictionaryRepresentation]
        case .video:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .audio:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        }
    }
}

fileprivate protocol MediaAttachment {
    var fileIdentifier: String { get }
    var attachmentOptions: [String: Any?] { get }
    var mediaData: Data? { get }
}

extension UIImage: MediaAttachment {
    
    var attachmentOptions: [String: Any?] {
        return MediaType.attachmentOptions(forType: .image)
    }
    
    var fileIdentifier: String {
        return "image.png"
    }
    
    var mediaData: Data? {
        guard let data = UIImagePNGRepresentation(self) else {
            return nil
        }
        return data
    }
}

fileprivate extension UNNotificationAttachment {
    
    static func create<T: MediaAttachment>(media: T, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileIdentifier = media.fileIdentifier
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)
            
            guard let data = media.mediaData else {
                return nil
            }
            
            try data.write(to: fileURL)
            return self.create(fileIdentifier: fileIdentifier, fileUrl: fileURL, options: options)
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    static func create(fileIdentifier: String, fileUrl: URL, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        do {
            return try UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
}

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        CleverTap.setDebugLevel(1277182231)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            // check for a media attachment
            let userInfo = bestAttemptContent.userInfo
            guard
                let _mediaType = userInfo["mediaType"] as? String,
                let url = userInfo["mediaUrl"] as? String,
                let mediaType = MediaType(rawValue:_mediaType)
                else {
                    contentHandler(bestAttemptContent)
                    return
                }
            
            // check to see if the url is local or remote
            
            if (!url.hasPrefix("http")) {
                // looking for a filename e.g. image.jpg
                let components = url.components(separatedBy: ".")
                guard let fileName = components.first as String?, let ext = components.last as String? else {
                    contentHandler(bestAttemptContent)
                    return
                }
                let bundle = Bundle(identifier: "com.clevertap.demo10.ns")
                
                if let resourceUrl = bundle?.url(forResource: fileName, withExtension: ext) {
                    if FileManager.default.fileExists(atPath: resourceUrl.path) {
                        if let attachment = UNNotificationAttachment.create(fileIdentifier: fileName, fileUrl: resourceUrl, options: MediaType.attachmentOptions(forType: mediaType)) {
                            bestAttemptContent.attachments = [attachment]
                            CleverTap.sharedInstance().recordEvent("NotificationAddAttachment", withProps: ["type": mediaType.rawValue, "url":url])
                        }
                        
                    }
                }
                contentHandler(bestAttemptContent)
                return
            }
            
            switch(mediaType) {
            case MediaType.image:
                loadImage(urlString: url, completion: {image, error in
                    if image != nil {
                        if let attachment = UNNotificationAttachment.create(media: image!, options: image!.attachmentOptions) {
                            bestAttemptContent.attachments = [attachment]
                            CleverTap.sharedInstance().recordEvent("NotificationAddAttachment", withProps: ["type": mediaType.rawValue, "url":url])
                        }
                    }
                    contentHandler(bestAttemptContent)
                })
                
            case MediaType.video:
                break
                
            case MediaType.audio:
                break
            }
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
    
    func loadImage(urlString:String, completion: @escaping (UIImage?, Error?) -> Void) {
        let imgURL = URL(string: urlString)!
        URLSession.shared
            .dataTask(with: imgURL, completionHandler: {(data, response, error) in
                guard let _ = data else {
                completion(nil, error)
                return
            }
                completion(UIImage(data: data!), nil)
            })
            .resume()
        
    }

}
