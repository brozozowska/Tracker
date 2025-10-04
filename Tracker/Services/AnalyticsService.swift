//
//  AnalyticsService.swift
//  Tracker
//
//  Created by Сергей Розов on 04.10.2025.
//

import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "d9c544e9-d3a0-4fbb-b299-463cf288be07") else { return }
        AppMetrica.activate(with: configuration)
    }

    func report(event: String, params : [AnyHashable : Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("DID FAIL REPORT EVENT: %@", event)
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
