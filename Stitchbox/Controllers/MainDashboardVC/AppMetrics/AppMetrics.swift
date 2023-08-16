//
//  AppMetrics.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/15/23.
//

import MetricKit

class AppMetrics: NSObject, MXMetricManagerSubscriber {
    private var receivedMetrics: [MXMetricPayload] = []
    private var receivedDiagnostics: [MXDiagnosticPayload] = []

    override init() {
        super.init()
        receiveReports()
    }

    func receiveReports() {
        let shared = MXMetricManager.shared
        shared.add(self)
    }

    func pauseReports() {
        let shared = MXMetricManager.shared
        shared.remove(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        // For demo purposes, just appending to a list
        receivedMetrics.append(contentsOf: payloads)
        
        // TODO: Process or send the metrics
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        // For demo purposes, just appending to a list
        receivedDiagnostics.append(contentsOf: payloads)
        
        // TODO: Process or send the diagnostics
    }
}
