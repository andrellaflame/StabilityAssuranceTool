//
//  ProjectSize.swift
//  
//
//  Created by Andrii Sulimenko on 11.01.2024.
//

import Foundation

// MARK: - ProjectSize value

/// `ProjectSize` enum for evaluation adjustment.
enum ProjectSize: String {
    case unowned, small, medium, large
}

extension ProjectSize {
    static func determineScale(for classCount: Int) -> ProjectSize {
        switch classCount {
        case ..<50: return .small
        case ..<200: return .medium
        default: return .large
        }
    }
}
