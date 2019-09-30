//
//  GarageIntentHandler.swift
//  GarageIntent
//
//  Created by Nick O'Neill on 9/28/19.
//  Copyright © 2019 Andrew Bonventre. All rights reserved.
//

import Foundation

class GarageIntentHandler: NSObject, GarageIntentIntentHandling {

  func confirm(intent: GarageIntentIntent, completion: @escaping (GarageIntentIntentResponse) -> Void) {
    guard let defaults = UserDefaults(suiteName: AppGroupName) else {
        completion(GarageIntentIntentResponse(code: .failure, userActivity: nil))
        return
    }

    let secret = defaults.string(forKey: UserSettingsKey.sharedSecret)
    if secret == nil {
        completion(GarageIntentIntentResponse(code: .failure, userActivity: nil))
        return
    }

    guard let baseURL = defaults.string(forKey: UserSettingsKey.baseURL), let _ = URL(string: baseURL) else {
        completion(GarageIntentIntentResponse(code: .failure, userActivity: nil))
        return
    }

    completion(GarageIntentIntentResponse(code: .success, userActivity: nil))
  }

  func handle(intent: GarageIntentIntent, completion: @escaping (GarageIntentIntentResponse) -> Void) {
    guard let defaults = UserDefaults(suiteName: AppGroupName) else {
        completion(GarageIntentIntentResponse(code: .failure, userActivity: nil))
        return
    }

    if let baseURL = defaults.string(forKey: UserSettingsKey.baseURL), let url = URL(string: baseURL), let secret = defaults.string(forKey: UserSettingsKey.sharedSecret) {
        GarageAPI.shared.toggleGarage(at: url, withSecret: secret)

        completion(GarageIntentIntentResponse(code: .success, userActivity: nil))
    } else {

        completion(GarageIntentIntentResponse(code: .failure, userActivity: nil))
    }
  }
}
