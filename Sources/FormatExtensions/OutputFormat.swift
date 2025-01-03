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
enum OutputFormat {
    /// Output format for console.
    case console
    /// Output format for HTML.
    case html
    /// Output format for specified filepath
    case file(String)
}

extension OutputFormat: ExpressibleByArgument {
    init?(argument: String) {
        if argument == "console" {
            self = .console
        } else if argument == "html" {
            self = .html
        }
        else if argument.starts(with: "file:") {
            let filePath = String(argument.dropFirst("file:".count))
            self = .file(filePath)
        }
        else {
            return nil
        }
    }
}
