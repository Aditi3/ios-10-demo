//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by pwilkniss on 8/22/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    override static func initialize() {
        super.initialize()
        print("initialized")
        CleverTap.setDebugLevel(1277182231)
        //CleverTap.sharedInstance().recordEvent("ShareFOOEventInit")
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CleverTap.setDebugLevel(1277182231)
        CleverTap.sharedInstance().recordEvent("ShareFOOEvent")
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
