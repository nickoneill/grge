//
//  ContentView.swift
//  garagewatch WatchKit Extension
//
//  Created by Nick O'Neill on 9/29/19.
//  Copyright © 2019 Andrew Bonventre. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Button(action: {
            guard let defaults = UserDefaults(suiteName: AppGroupName) else {
                print("group defaults unavailable")
                return
            }

            if let baseURL = defaults.string(forKey: UserSettingsKey.baseURL), let url = URL(string: baseURL), let secret = defaults.string(forKey: UserSettingsKey.sharedSecret) {
                GarageAPI.shared.toggleGarage(at: url, withSecret: secret)
                print("did that work")
            } else {
                print("no data available")
            }

        }, label: {
            Text("Open Garage")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
