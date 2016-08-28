//
//  SharedManager.swift
//  demo10
//
//  Created by pwilkniss on 8/27/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import Foundation
import UserNotifications

public enum MediaType: String {
    case image = "image"
    case gif = "gif"
    case video = "video"
    case audio = "audio"
}

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
            return [UNNotificationAttachmentOptionsThumbnailTimeKey: 0]
        }
    }
    
    var fileIdentifier: String {
        return self.type.rawValue
    }
    
    var fileExt: String {
        return self.ext
    }
    
    var mediaData: Data? {
        return self.data
    }
}

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

public struct SharedManager {
    
    static var bundle: Bundle? = Bundle(identifier: "com.clevertap.SharedManager")
    
    private var appGroupName: String
    
    private let userIdKey = "userId"
    
    private var sharedUserDefaults: UserDefaults?
    
    public var userId: String? {
        get {
          return self.retrieve(key: userIdKey)
        }
        set(newValue) {
            self.save(value: newValue!, forKey: userIdKey)
        }
    }
    
    private func save(value: String, forKey key: String) {
        sharedUserDefaults?.set(value, forKey: key)
        sharedUserDefaults?.synchronize()
    }
    
    private func retrieve(key: String) -> String? {
        return sharedUserDefaults?.object(forKey: key) as? String
    }
    
    public init(forAppGroup appGroupName: String) {
        self.appGroupName = appGroupName
        sharedUserDefaults = UserDefaults(suiteName: appGroupName)
        sharedUserDefaults?.synchronize()
    }
    
    public func createNotificationAttachment(forMediaType mediaType: MediaType,
                                             withUrl url: String,
                                             completionHandler: ((UNNotificationAttachment?) -> Void)) {
        
        loadAttachment(forMediaType: mediaType, withUrlString: url, completionHandler: completionHandler)
    }
}
