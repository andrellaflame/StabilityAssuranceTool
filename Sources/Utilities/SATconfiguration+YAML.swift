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
    let metricConfiguration: [String: MetricConfiguration]?
}

struct MetricConfiguration: Codable {
    let thresholds: Thresholds
    let severity: Severity
}

struct Thresholds: Codable {
    let good: Double
    let accepted: Double
}

struct Severity: Codable {
    var poor: MetricSeverity?       = .warning
    var acceptable: MetricSeverity? = .warning
}

enum MetricSeverity: String, Codable {
    case note, warning, error
}
