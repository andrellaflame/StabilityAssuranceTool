//
//  SATConfiguration+YAML.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-01-16.
//

import Foundation

struct SATConfiguration: Codable {
    let output: String
    let enabledMetrics: [String]?
    let thresholds: [String: MetricThresholds]?
}

struct MetricThresholds: Codable {
    let good: Double
    let accepted: Double
}
