//
//  SharedManager.swift
//  demo10
//
//  Created by pwilkniss on 8/27/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UIKit
import UserNotifications

public enum MediaType: String {
    case image = "image"
    case gif = "gif"
    case video = "video"
    case audio = "audio"
}

@available(iOSApplicationExtension 10.0, *)
fileprivate struct Media {
    private var data: Data
    private var ext: String
    private var type: MediaType
    
    init(forMediaType mediaType: MediaType, withData data: Data, fileExtension ext: String) {
        self.type = mediaType
        self.data = data
        self.ext = ext
    }
    
    var attachmentOptions: [String: Any?] {
        switch(self.type) {
        case .image:
            return [UNNotificationAttachmentOptionsThumbnailClippingRectKey: CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.50).dictionaryRepresentation]
        case .gif:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .video:
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        case .audio:
            return [UNNotificationAttachmentOptionsThumbnailHiddenKey: 1]
        }
    }
    
    var fileIdentifier: String {
        return self.type.rawValue
    }
    
    var fileExt: String {
        if self.ext.characters.count > 0 {
            return self.ext
        } else {
            switch(self.type) {
            case .image:
                return "jpg"
            case .gif:
                return "gif"
            case .video:
                return "mp4"
            case .audio:
                return "mp3"
            }
        }
    }
    
    var mediaData: Data? {
        return self.data
    }
}

@available(iOSApplicationExtension 10.0, *)
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

@available(iOSApplicationExtension 10.0, *)
fileprivate extension UNNotificationAttachment {
    
    static func create(fromMedia media: Media) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileIdentifier = "\(media.fileIdentifier).\(media.fileExt)"
            let fileURL = tmpSubFolderURL.appendingPathComponent(fileIdentifier)
            
            guard let data = media.mediaData else {
                return nil
            }
            
            try data.write(to: fileURL)
            return self.create(fileIdentifier: fileIdentifier, fileUrl: fileURL, options: media.attachmentOptions)
        } catch {
            print("error " + error.localizedDescription)
        }
        return nil
    }
    
    static func create(fileIdentifier: String, fileUrl: URL, options: [String : Any]? = nil) -> UNNotificationAttachment? {
        var n: UNNotificationAttachment?
        do {
            n = try UNNotificationAttachment(identifier: fileIdentifier, url: fileUrl, options: options)
        } catch {
            print("error " + error.localizedDescription)
        }
        return n
    }
}

private func resourceURL(forUrlString urlString: String) -> URL? {
    
    var url = URL(string: urlString)
    
    if (!urlString.hasPrefix("http")) {
        // expect a filename with extension e.g. logo.png
        let components = urlString.components(separatedBy: ".")
        guard let fileName = components.first as String?, let ext = components.last as String? else {
            return nil
        }
        if let localURL = SharedManager.bundle?.url(forResource: fileName, withExtension: ext) {
            url = localURL
        }
    }
    return url
}

@available(iOSApplicationExtension 10.0, *)
private func loadAttachment(forMediaType mediaType: MediaType, withUrlString urlString: String, completionHandler: ((UNNotificationAttachment?) -> Void)) {
    guard let url = resourceURL(forUrlString: urlString) else {
        completionHandler(nil)
        return
    }
    
    do {
        let data = try Data(contentsOf: url)
        let media = Media(forMediaType: mediaType, withData: data, fileExtension: url.pathExtension)
        if let attachment = UNNotificationAttachment.create(fromMedia: media) {
            completionHandler(attachment)
            return
        }
        completionHandler(nil)
    } catch {
        print("error " + error.localizedDescription)
        completionHandler(nil)
    }
}

public class SharedManager: NSObject {
    
    static var bundle: Bundle? = Bundle(identifier: "com.clevertap.SharedManager")
    
    private var appGroupName: String
    
    private let userIdKey = "userId"
    
    private let lastPushNotificationKey = "lastPushNotification"
    
    private var sharedUserDefaults: UserDefaults?
    
    public var userId: String? {
        get {
            return self.retrieve(key: userIdKey)
        }
        set(newValue) {
            if (newValue == nil) {
                self.remove(key: userIdKey)
                
            } else {
                self.save(value: newValue!, forKey: userIdKey)
            }
        }
    }
    
    public var lastPushNotification: [String: String]? {
        get {
            return self.retrieve(key: lastPushNotificationKey)
        }
        set(newValue) {
            self.save(value: newValue!, forKey: lastPushNotificationKey)
        }
    }
    
    private func save(value: String, forKey key: String) {
        sharedUserDefaults?.set(value, forKey: key)
        sharedUserDefaults?.synchronize()
    }
    
    private func save(value: [String: String], forKey key: String) {
        sharedUserDefaults?.set(value, forKey: key)
        sharedUserDefaults?.synchronize()
    }
    
    private func retrieve(key: String) -> String? {
        return sharedUserDefaults?.string(forKey: key)
    }
    
    private func remove(key: String) {
        sharedUserDefaults?.removeObject(forKey: key)
    }
    
    private func retrieve(key: String) -> [String: String]? {
        return sharedUserDefaults?.dictionary(forKey: key) as? [String: String]
    }
    
    public init(forAppGroup appGroupName: String) {
        self.appGroupName = appGroupName
        sharedUserDefaults = UserDefaults(suiteName: appGroupName)
        sharedUserDefaults?.synchronize()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    public func persistLastPushNotification(withContent content: UNNotificationContent) {
        self.lastPushNotification = content.toDict()
    }
    
    @available(iOSApplicationExtension 10.0, *)
    public func createNotificationAttachment(forMediaType mediaType: MediaType,
                                             withUrl url: String,
                                             completionHandler: ((UNNotificationAttachment?) -> Void)) {
        
        loadAttachment(forMediaType: mediaType, withUrlString: url, completionHandler: completionHandler)
    }
    
    public func image(forName name: String) -> UIImage? {
        let imagePath = SharedManager.bundle?.path(forResource: name, ofType: "")
        return (imagePath != nil) ? UIImage(contentsOfFile: imagePath!) : nil
    }
}
