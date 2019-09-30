//
//  GarageAPI.swift
//  garage
//
//  Created by Nick O'Neill on 3/9/19.
//

import Foundation
import CryptoKit

struct UserSettingsKey {
    static let baseURL = "baseURL"
    static let sharedSecret = "sharedSecret"
}

let AppGroupName = "group.name.nickoneill.grge"

class GarageAPI {
    public static var shared: GarageAPI = {
        return GarageAPI()
    }()

    // don't let anyone else init
    private init(){}

    private var requestPending = false
    private let isolationQueue = DispatchQueue(label: "com.andybons.GRGE.requestPendingQueue",
                                               attributes: .concurrent)

    func toggleGarage(at baseURL: URL, withSecret secret: String) {
        let timeSinceEpoch = String(Int(NSDate().timeIntervalSince1970))
        let key = hmacsha1(str: timeSinceEpoch, key: secret)

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let tQuery = URLQueryItem(name: "t", value: timeSinceEpoch)
        let keyQuery = URLQueryItem(name: "key", value: key)
        components?.queryItems = [tQuery, keyQuery]
        guard let finalURL = components?.url else { return }

        isolationQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.requestPending = true
        }

        URLSession.shared.dataTask(with: finalURL, completionHandler: {
            data, response, error in

            self.isolationQueue.async(flags: .barrier) {
                self.requestPending = false
            }

            if let errorStr = error?.localizedDescription {
                print("error:", errorStr)
//                DispatchQueue.main.async {
//                    self.setMainLabelText(MainViewController.errorText, forDuration: 5.0)
//                }
            } else if let httpResponse = response as? HTTPURLResponse {
                print("Status: \(httpResponse.statusCode)")
            }

            // return error states to UI
        }).resume()
    }

    private func hmacsha1(str: String, key: String) -> String {
        guard let keyBytes = key.data(using: .utf8) else {
            preconditionFailure("can't convert to bytes")

        }
        let key = SymmetricKey(data: keyBytes)

        guard let stringBytes = str.data(using: .utf8) else {
            preconditionFailure("can't convert string to bytes")
        }

        let auth = HMAC<Insecure.SHA1>.authenticationCode(for: stringBytes, using: key)
        var hexBytes: String = ""
        for (_, c) in auth.enumerated() {
            hexBytes += String(format: "%02x", c)
        }

        return hexBytes
    }
}
