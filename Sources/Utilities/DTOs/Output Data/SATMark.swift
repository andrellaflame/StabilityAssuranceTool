//
//  SATMark.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-01-16.
//

import Foundation

// MARK: - SATMark value
/// `SATMark` enum for evaluated product metrics.
enum SATMark: String, Codable {
    case unowned, good, accepted, poor
}
