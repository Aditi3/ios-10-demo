
import UIKit
import Social
import SharedManager

class ShareViewController: SLComposeServiceViewController {
    
    private lazy var cleverTap: CleverTap = CleverTap.sharedInstance()
    
    private lazy var sharedManager: SharedManager = {
        return SharedManager(forAppGroup: "group.com.clevertap.demo10")
    }()
    
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CleverTap.setDebugLevel(1)
        if let userId = sharedManager.userId {
            cleverTap.onUserLogin(["Identity":userId])
        }
        cleverTap.recordEvent("CustomShareEvent")
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
