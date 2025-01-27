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
    
    public var score: Double {
        switch self {
        case .good: return 1.0
        case .accepted: return 0.5
        case .poor: return 0.0
        case .unowned: return 0.0
        }
    }
}
