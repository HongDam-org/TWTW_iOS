//
//  Tracker.swift
//  TWTW
//
//  Created by Sean Hong on 12/10/23.
//

import CoreLocation
import UIKit

/// These are the actions for each (non-title) cell:
enum Action: String {
    case schedule = "Schedule"
    case showPins = "Show Location Pins"

    static let all: [Action] = [
        .schedule,
        .showPins
    ]
    
    /// Get the title for this action's view controller
    var title: String {
        switch self {
        case .schedule:
            return "Schedule"
        case .showPins:
            return "Pins"
        }
    }
}
