
import UIKit
import UserNotifications
import UserNotificationsUI
import SharedManager
import MapboxStatic

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var mapImageView: UIImageView!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var textLabel: UILabel!
    
    private lazy var cleverTap: CleverTap = CleverTap.sharedInstance()
    
    private lazy var sharedManager: SharedManager = {
        return SharedManager(forAppGroup: "group.com.clevertap.demo10")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CleverTap.setDebugLevel(1277182231)
        if let userId = sharedManager.userId {
            cleverTap.onUserLogin(["Identity":userId])
        }
        self.loadingIndicator.startAnimating()
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
        
        self.textLabel.text = "Location (\(latString), \(lonString))"
        
        let mapboxCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let options = SnapshotOptions(
            mapIdentifiers: ["mapbox.streets"],
            centerCoordinate: mapboxCoordinate,
            zoomLevel: 13,
            size: CGSize(width: 200, height: 200))
        
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
            self.loadingIndicator.stopAnimating()
            self.mapImageView.image = image
        })
        
        cleverTap.recordEvent("NotificationDidShowLocation",
                                               withProps: ["lat": "\(mapboxCoordinate.latitude)", "lon":"\(mapboxCoordinate.longitude)"])
    }
    
    func didReceive(_ response: UNNotificationResponse,
                    completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void){
        
        let action = response.actionIdentifier
        
        switch (action) {
        case "accept":
            self.textLabel.textColor = UIColor.green
            self.textLabel.text = "You accepted!"
        case "decline":
            self.textLabel.textColor = UIColor.red
            self.textLabel.text = "You declined :("
        case "dismiss":
            completion(.dismiss)
        default:
            break
        }
    }

}
