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
    let configuration: [String: MetricConfiguration]?
}

struct MetricConfiguration: Codable {
    let thresholds: Thresholds?
    let severity: Severity?
}

struct Thresholds: Codable {
    let good: Double
    let accepted: Double
}

struct Severity: Codable {
    var poor: MetricSeverity
    var acceptable: MetricSeverity
}

enum MetricSeverity: String, Codable {
    case note, warning, error
}
