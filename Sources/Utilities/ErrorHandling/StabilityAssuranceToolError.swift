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
    case invalidData(String)
    case invalidConfiguration(String)
    case metricSeverity
}

/// StabilityAssuranceToolError service errors localized description
extension StabilityAssuranceToolError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .missingAttributeArgument(let argument):
            return NSLocalizedString("\(argument) is missing. Verify passed arguments", comment: "Argument Missing")
        case .invalidFilepath(let filepath):
            return NSLocalizedString("File: \(filepath) not found. Verify passed arguments", comment: "Invalid Filepath")
        case .invalidData(let details):
            return NSLocalizedString("Passed data for evaluation is missing or invalid. Details: \(details).", comment: "Invalid Evaluation Data")
        case .invalidConfiguration(let details):
            return NSLocalizedString("Passed configuration is invalid. Details: \(details).", comment: "Invalid Configuration Data")
        case .metricSeverity:
            return NSLocalizedString("Received result exceeded configured metric severity. Verify your configuration or adjust the source code.", comment: "Metric Severity Exceeded")
        }
    }
}

