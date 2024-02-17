//
//  OutputFormat.swift
//
//
//  Created by Andrii Sulimenko on 01.02.2024.
//

import Foundation
import ArgumentParser

// MARK: - Output Format

/// Enum defining different output formats.
enum OutputFormat: String, ExpressibleByArgument {
    /// Output format for console.
    case console
    
    /// Output format for HTML.
    case html
}
