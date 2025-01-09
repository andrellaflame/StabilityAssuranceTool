//
//  OutputFormat.swift
//
//
//  Created by Andrii Sulimenko on 01.02.2024.
//

import Foundation
import ArgumentParser
#if canImport(AppKit)
import AppKit
#endif

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
        } else {
            self = .file(argument)
        }
    }
}

extension OutputFormat {
    /// Outputs the given report based on the output format.
    /// - Parameter report: The string report to be outputted.
    func writeReport(_ report: String) {
        switch self {
        case .console:
            print(report)
        case .html:
            let tempDirectory = FileManager.default.temporaryDirectory
            let htmlFilePath = tempDirectory.appendingPathComponent("report.html")
            
            do {
                try report.write(to: htmlFilePath, atomically: true, encoding: .utf8)
            } catch {
                print("Error writing HTML file: \(error)")
                return
            }
            
#if canImport(AppKit)
            if NSWorkspace.shared.open(htmlFilePath) {
                print("Report is opened in HTML file successfully.")
            } else {
                print("Failed to open HTML file.")
            }
#else
            print("NSWorkspace is not available.")
#endif
            
        case .file(let filePath):
            do {
                try report.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
                print("Report written to file at \(filePath).")
            } catch {
                print("Error writing file: \(error)")
            }
        }
    }
}

