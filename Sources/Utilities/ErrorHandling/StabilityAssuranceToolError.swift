//
//  File.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-01-09.
//

import Foundation

enum StabilityAssuranceToolError: Error {
    case missingAttributeArgument(String)
    case invalidFilepath(String)
}

/// StabilityAssuranceToolError service errors localized description
extension StabilityAssuranceToolError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingAttributeArgument(let argument):
            return NSLocalizedString("\(argument) is missing. Verify passed arguments", comment: "Argument Missing")
        case .invalidFilepath(let filepath):
            return NSLocalizedString("File: \(filepath) not found. Verify passed arguments", comment: "Invalid Filepath")
        }
    }
}

