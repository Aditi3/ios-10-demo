//
//  InterfaceController.swift
//  WatchApp Extension
//
//  Created by pwilkniss on 9/1/16.
//  Copyright © 2016 CleverTap. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation
import CleverTapWatchOS


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var session: WCSession?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        session = WCSession.default()
        session?.delegate = self
        session?.activate()
        
        if (session != nil) {
            let cleverTap = CleverTapWatchOS(session: session!)
            cleverTap.record(event: "CustomWatchOSEvent", withProps: ["foo": "bar"])
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: WCSessionDelegate
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // no-op for demo purposes
    }

}
