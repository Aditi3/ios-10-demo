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
import MapboxStatic

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var mapImageView: UIImageView!
    
    let appGroupName: String = "group.com.clevertap.demo10"
    
    lazy var sharedManager: SharedManager = {
        return SharedManager(forAppGroup: self.appGroupName)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CleverTap.setDebugLevel(1277182231)
        if let userId = sharedManager.userId {
            CleverTap.sharedInstance().onUserLogin(["Identity":userId])
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        
        sharedManager.persistLastPushNotification(withContent: notification.request.content)
        
        let content = notification.request.content
        
        guard
            let latString = content.userInfo["latitude"] as? String,
            let latitude = Double(latString),
            let lonString = content.userInfo["longitude"] as? String,
            let longitude = Double(lonString)
        else { return }
        
        let mapboxCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let options = SnapshotOptions(
            mapIdentifiers: ["mapbox.light"],
            centerCoordinate: mapboxCoordinate,
            zoomLevel: 12,
            size: CGSize(width: 288, height: 200))
        
        let markerOverlay = Marker(
            coordinate: mapboxCoordinate,
            size: .small,
            iconName: "rocket"
        )
        markerOverlay.color = .purple
        
        options.overlays = [markerOverlay]
        
        let mapboxAccessToken = Bundle.main.infoDictionary!["MGLMapboxAccessToken"] as! String
        
        let snapshot = Snapshot(options: options, accessToken: mapboxAccessToken)
        
        let _ = snapshot.generateImage(completionHandler: { (image, error) in
            self.mapImageView.image = image
        })
        
        CleverTap.sharedInstance().recordEvent("NotificationDidShowLocation", withProps: ["lat": "\(mapboxCoordinate.latitude)", "lon":"\(mapboxCoordinate.longitude)"])
    }

}
