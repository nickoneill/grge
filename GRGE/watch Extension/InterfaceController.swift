//
//  InterfaceController.swift
//  watch Extension
//
//  Created by Nick O'Neill on 3/9/19.
//  Copyright © 2019 Andrew Bonventre. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

//        WCSession.default.sendMessage([:], replyHandler: { (response) in
//            let baseURL = response[UserSettingsKey.baseURL] ?? ""
//            let secret = response[UserSettingsKey.sharedSecret] ?? ""
//
//            // defaults here are separate than the iOS ones, so we need to write them again
//            let defaults = UserDefaults.standard
//            defaults.set(baseURL, forKey: UserSettingsKey.baseURL)
//            defaults.set(secret, forKey: UserSettingsKey.sharedSecret)
//
//        }) { (error) in
//            print("error: \(error)")
//        }
    }

    @IBAction func openGarage() {
        let defaults = UserDefaults()
        let baseURL = defaults.string(forKey: UserSettingsKey.baseURL) ?? ""
        let secret = defaults.string(forKey: UserSettingsKey.sharedSecret) ?? ""

        guard let garageURL = URL(string: baseURL) else {
            presentAlert(withTitle: nil, message: "That's not a url", preferredStyle: .alert, actions: [WKAlertAction(title: "OK", style: .default, handler: {
                // ok
            })])
            return
        }

        GarageAPI.shared.toggleGarage(at: garageURL, withSecret: secret)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
