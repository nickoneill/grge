//
//  IntentHandler.swift
//  GarageIntent
//
//  Created by Nick O'Neill on 9/28/19.
//  Copyright © 2019 Andrew Bonventre. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        guard intent is GarageIntentIntent else {
            preconditionFailure("unhandled intent type: \(intent)")
        }

        return GarageIntentHandler()
    }
    
}
